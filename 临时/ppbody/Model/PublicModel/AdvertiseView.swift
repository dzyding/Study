//
//  AdvertiseView.swift
//  PPBody
//
//  Created by edz on 2019/1/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import HBDNavigationBar

enum AdType {
    case img(UIImage)
    case video(String)
}

class AdvertiseView: UIView, AdJumpProtocol {
    
    var actionVC: UINavigationController? {
        return UIApplication.shared
            .keyWindow?
            .rootViewController as? HBDNavigationController
    }
    
    var type: AdType?{
        didSet{
            switch type {
            case .img(let image)?:
                self.voluemBtn.isHidden = true
                setImageView(image)
            case .video(let url)?:
                self.voluemBtn.isHidden = false
                setPlayerView(url)
            case .none: break
                
            }
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var jumpBtn: UIButton!
    @IBOutlet weak var voluemBtn: UIButton!
    @IBOutlet weak var adIV: UIImageView!
    
    var urlData: [String : Any] = [:]
    {
        didSet{
            if let isAdd = urlData["isAdd"] as? Int, isAdd == 1
            {
                self.adIV.isHidden = false
            }else{
                self.adIV.isHidden = true

            }
        }
    }
    
    var avplayer:AVPlayerView?
    
    class func instanceFromNib() -> AdvertiseView {
        return UINib(nibName: "AdvertiseView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AdvertiseView
    }
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func volumeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        avplayer?.player?.volume = sender.isSelected ? 3.0 : 0.0
    }
    
    @IBAction func jumpAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.hide()
        }
    }
    
    @objc func hide() {
        self.avplayer?.cancelLoading()
        self.avplayer?.removeFromSuperview()
        removeFromSuperview()
    }
    
    
    func animationAction()  {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.hide()
        }
    }
    
    func setImageView(_ image: UIImage) {
        let imgView = UIImageView(image: image)
        imgView.isUserInteractionEnabled = true
        imgView.contentMode = .scaleAspectFill
        containerView.addSubview(imgView)
        
        imgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        imgView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .vertical)
        imgView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(jumpDetailAction))
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if let _ = self.superview {
                self.animationAction()
            }
        }
    }
    
    func setPlayerView(_ url: String) {
        avplayer = AVPlayerView()
        avplayer?.delegate = self
        containerView.insertSubview(avplayer!, at: 0)
        avplayer?.setPlayerAdUrl(url: url)
        avplayer?.playerLayer.videoGravity = .resizeAspectFill
        avplayer?.player?.volume = 0.0
        avplayer?.play()
        
        avplayer?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        avplayer?.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(jumpDetailAction))
        )
    }
    
    
    @objc func jumpDetailAction() {
        if DataManager.userInfo() == nil {return}
        guard let value = urlData.intValue("type"),
            let type = AdJumpType(rawValue: value)
        else {return}
        urlData.intValue("id").flatMap({
            adApi($0)
        })
        switch type {
        case .tag:
            if let name = urlData.stringValue("tag") {
                ad_goTagDetail(name, animated: false)
            }
        case .url:
            if var url = urlData.stringValue("url") {
                let auth = DataManager.userAuth()
                if url.contains("?") {
                    url = (auth != "") ? (url + "&uid=\(auth)") : url
                }else {
                    url = (auth != "") ? (url + "?uid=\(auth)") : url
                }
                ad_goWebVC(url, isShare: false, animated: false)
            }
        case .groupBuy:
            urlData.intValue("obId").flatMap({
                ad_goGroupBuyDetail($0, animated: false)
            })
        case .ptExp:
            urlData.intValue("obId").flatMap({
                ad_goPtExpDetail($0, animated: false)
            })
        case .gym:
            urlData.intValue("obId").flatMap({
                ad_goGymDetail($0, animated: false)
            })
        case .longImage:
            urlData.stringValue("url").flatMap({
                ad_goLongImage($0,
                               title: urlData.stringValue("title"),
                               animated: false)
            })
        case .goods:
            ad_goGoodsList(false)
        }
        hide()
    }
    
    //    MARK: - api
    private func adApi(_ aid: Int) {
        let request = BaseRequest()
        request.url = BaseURL.AdSt
        request.dic = [
            "obId" : "\(aid)",
            "type" : "\(10)"
        ]
        request.start { (data, error) in
            
        }
    }
    
    //    MARK: - Class 便捷方法
    static func showImage(_ image: UIImage, urlData: [String : Any]) {
        let v = AdvertiseView.instanceFromNib()
        v.urlData = urlData
        v.type = AdType.img(image)
        
        KEY_WINDOW?.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    static func showVideo(_ video: String, urlData: [String : Any]) {
        let v = AdvertiseView.instanceFromNib()
        v.urlData = urlData
        v.type = AdType.video(video)
        
        KEY_WINDOW?.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension AdvertiseView: AVPlayerUpdateDelegate {
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        if current == total{
            animationAction()
        }
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        
    }
}
