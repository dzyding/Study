//
//  VideoTopicDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import DynamicButton
import Alamofire

typealias OnPlayerReady = () -> Void

class VideoTopicDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var playerContentView: UIView!
    
    weak var delegate:TopicDetailActionDelegate?
    
    @IBOutlet weak var playBtn: UIButton!
    
    
    var tid:String = ""
    var dataTopic:[String:Any]?
    
    var vid = ""
    
    var indexPath:IndexPath!
    
    lazy var playerView:AVPlayerView = {[weak self] in
        let pv = AVPlayerView()
        pv.delegate = self
        return pv
    }()
    
    var isPlayerReady = false
    
    var onPlayerReady:OnPlayerReady?
    
    var lastTapTime:TimeInterval = 0
    
    var dataRequest:DataRequest?
    
    lazy var controllerview: ControllerView = {[weak self] in
        
        let controllerview = ControllerView.instanceFromNib()
        controllerview.delegate = self
        
        return controllerview
    }()
    
    override func awakeFromNib() {
        insertSubview(controllerview, belowSubview: playBtn)
        controllerview.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-SafeBottom)
        }
        
        //单击监听
//        let
//        tapSingle=UITapGestureRecognizer(target:self,action:#selector(tapSingleDid))
//        tapSingle.numberOfTapsRequired = 1
//        tapSingle.numberOfTouchesRequired = 1
//        //双击监听
//        let tapDouble=UITapGestureRecognizer(target:self,action:#selector(tapDoubleDid(_:)))
//        tapDouble.numberOfTapsRequired = 2
//        tapDouble.numberOfTouchesRequired = 1
        //声明点击事件需要双击事件检测失败后才会执行
//        tapSingle.require(toFail: tapDouble)
        self.controllerview.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(handleGesture(sender:))))
//        self.controllerview.addGestureRecognizer(tapDouble)
        
        playerContentView.addSubview(playerView)
        
        playerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }

    func setData(_ dic: [String:Any], indexPath:IndexPath) {
        self.indexPath = indexPath
        self.dataTopic = dic
        tid = dic["tid"] as! String
        
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        
        self.vid = dic["video"] as! String
        
        self.controllerview.setData(dic)
        self.playBtn.isHidden = true
        self.coverIV.isHidden = false
        
        self.controllerview.startLoadingPlayItemAnim(true)

        getUrlFromVid(self.vid)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.playerView.cancelLoading()
        self.dataRequest?.cancel()
        isPlayerReady = false
    }
    
    func getUrlFromVid(_ vid: String) {
        if AlivideoPlayCache.cache.videoCache.keys.contains(where: { (key) -> Bool in
            return key == vid
        })
        {
            let dic = AlivideoPlayCache.cache.videoCache[vid] as! [String:Any]
            let requestTime = dic["time"] as! Date
            let second = Date().timeIntervalSince(requestTime)
            if second/60 > 4 //大于4分钟需要重新获取client
            {
                getVideoODUrl(vid)
            }else{
                let url = dic["url"] as! String
                self.playerView.setPlayerSourceUrl(url: url)
  
            }
        }else{
            getVideoODUrl(vid)
        }
    }
    
    func getVideoODUrl(_ vid: String) {
        let request = BaseRequest()
        request.dic = ["vid":vid]
        request.url = BaseURL.GetVideoURL
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            let videoInfo = data!["videoInfo"] as! [String:Any]
            
            let playURL = videoInfo["playURL"] as! String
            
            let requestTime = Date()
            let dic:[String : Any] = ["url":playURL,"time":requestTime]
            
            AlivideoPlayCache.cache.videoCache[vid] = dic
            
            self.playerView.setPlayerSourceUrl(url: playURL)

        }
        dataRequest = request.currentRequest
    }
    
    func play() {
        if self.playBtn.isHidden && isPlayerReady
        {
            self.playerView.play()
            self.playBtn.isHidden = true

        }
    }
    
    func pause() {
        self.playerView.pause()
    }
    
    func replay() {
        self.playBtn.isHidden = true

        self.playerView.replay()
    }
    
    func cancelLoading()
    {
        self.playerView.cancelLoading()
    }
  
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        let time = CACurrentMediaTime()
        //判断当前点击时间与上次点击时间的时间间隔
        if (time - lastTapTime) > 0.25 {
            //推迟0.25秒执行单击方法
            self.perform(#selector(tapSingleDid), with: nil, afterDelay: 0.25)
        } else {
            //取消执行单击方法
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tapSingleDid), object: nil)
            //执行连击显示爱心的方法
            tapDoubleDid(sender)
        }
        //更新上一次点击时间
        lastTapTime = time
    }
    
    @objc func tapSingleDid(){
        showPauseViewAnim(rate: playerView.rate())
        playerView.updatePlayerState()
    }
    
    @objc func tapDoubleDid(_ tap:UITapGestureRecognizer){
        ControllerLikeAnimation.likeAnimation.createAnimationWithTouch(tap)
        if !self.controllerview.supportBtn.isSelected
        {
            self.controllerview.supportAction(self.controllerview.supportBtn)
        }
    }
    
    //点击效果
    func showPauseViewAnim(rate:CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.playBtn.alpha = 0.0
            }) { finished in
                self.playBtn.isHidden = true
            }
        } else {
            playBtn.isHidden = false
            playBtn.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
            playBtn.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.playBtn.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { finished in
            }
        }
    }
    
    deinit {
        print("VideoTopicDetailCell deinit=====")
//        self.playerView.cancelLoading()
    }

}

extension VideoTopicDetailCell: ControllerViewActionDelegate
{
    func giftAction() {
        self.delegate?.giftAction(indexPath)
    }
    
    func commentShowAction() {
        self.delegate?.commentShowAction(tid,indexPath: self.indexPath)
    }
    
    func detailAction() {
        self.delegate?.detailAction(self.dataTopic!)
    }
    
    func commentAction() {
        self.delegate?.commentAction(tid, indexPath: self.indexPath)
    }
    
    func shareAction() {
        self.delegate?.shareAction(tid,indexPath: self.indexPath)
    }
    
    func supportAction(_ isSelect: Bool) {
        self.delegate?.supportAction(tid, isSupport: isSelect,indexPath: self.indexPath)
    }
    
    func personalPage() {
        self.delegate?.personalPage(indexPath: self.indexPath)
    }
}

extension VideoTopicDetailCell: AVPlayerUpdateDelegate
{
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            self.coverIV.isHidden = true
            self.controllerview.startLoadingPlayItemAnim(false)
            
            self.isPlayerReady = true
            self.onPlayerReady?()
            
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
}
