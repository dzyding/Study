//
//  MusicPickHeaderView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SpinKit

protocol MusicPickHeaderViewDelegate:NSObjectProtocol
{
    func tapHeaderView(_ head: MusicPickHeaderView)
    func playPath(_ path: String, start: Float, duration: Float)
    func collectMusicId(_ musicId: Int, isCollect:Bool, index: Int)
}

class MusicPickHeaderView: UITableViewHeaderFooterView
{
    @IBOutlet weak var bgIV: UIImageView!
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var authorLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    var spinkit: RTSpinKitView?
    
    weak var delegate: MusicPickHeaderViewDelegate?
    
    var data: [String:Any]?
    
    var index: Int = 0
    
    override func awakeFromNib() {
        self.bgIV.layer.borderColor = YellowMainColor.cgColor
        self.bgIV.layer.borderWidth = 1
        
        if self.spinkit == nil
        {
            spinkit = RTSpinKitView(style: .styleArc, color: UIColor.white)
            self.addSubview(spinkit!)
            spinkit?.isHidden = true
            spinkit?.snp.makeConstraints({ (make) in
                make.center.equalTo(self.coverIV.snp.center)
            })
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeadAction(_:))))
    }
    
    func reset()
    {
        self.playBtn.isHidden = false
        self.spinkit?.isHidden = true
        
        self.playBtn.isSelected = false
    }
    
    func setData(_ dic: [String:Any], section: Int)
    {
        self.index = section
        self.data = dic
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.nameLB.text = dic["name"] as? String
        self.authorLB.text = dic["author"] as? String
        self.timeLB.text = ToolClass.showDuration(dic["duration"] as! Int)
        
        if let iscollect = dic["isCollect"] as? Int
        {
            self.collectionBtn.isSelected = iscollect == 1 ? true : false
        }
        
        let url = data!["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        let status = MusicPickPlayer.player.getStatus(path)
        switch status {
        case 0:
            self.playBtn.isSelected = false
            spinkit?.isHidden = true
        case 1:
            self.playBtn.isSelected = true
            spinkit?.isHidden = true
        case 2:
            self.playBtn.isHidden = true
            spinkit?.isHidden = false
            spinkit?.startAnimating()
        default:
            break
        }
                
    }
    
    @objc func tapHeadAction(_ tap: UITapGestureRecognizer)
    {
        let url = data!["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        
        if !self.playBtn.isSelected
        {
            if FileManager.default.fileExists(atPath: path)
            {
                delegateAction(tap.view as! MusicPickHeaderView)
                return
            }
            downloadMusic(tap.view as! MusicPickHeaderView)
        }else{
            delegateAction(tap.view as! MusicPickHeaderView)
        }
    }
    
    
    func delegateAction(_ view: MusicPickHeaderView)
    {
        let url = data!["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        let duration = data!["duration"] as! Int
        
        self.delegate?.playPath(path, start: 0, duration: Float(duration))
        self.delegate?.tapHeaderView(view)
        self.playBtn.isSelected = !self.playBtn.isSelected
    }
    
    
    func downloadMusic(_ tap: MusicPickHeaderView)
    {
        spinkit?.startAnimating()
        spinkit?.isHidden = false
        self.playBtn.isHidden = true
        let url = data!["path"] as! String
        
        AliyunUpload.upload.downloadMusic(ToolClass.getOSSObjectname(url)) { (path) in
            
            DispatchQueue.main.sync {
                self.spinkit?.stopAnimating()
                self.spinkit?.isHidden = true
                self.playBtn.isHidden = false
                if path != nil
                {
                    //下载成功
                    self.delegateAction(tap)
                    
                }else{
                    //下载失败
                    ToolClass.showToast("网络异常，请检查", .Failure)
                    self.playBtn.isSelected = false
                }
            }
        }
    }
    @IBAction func collectionAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let musicId = data!["id"] as! Int
        self.delegate?.collectMusicId(musicId, isCollect: sender.isSelected, index: self.index)
    }
}
