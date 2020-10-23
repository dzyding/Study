//
//  TribeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AttentionView: UIView, ObserverVCProtocol
{
    var observers: [[Any?]] = []
    
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var attentionBtn: UIButton!
    

    var attentionAction:((_ uid: String, _ isAttention: Bool) -> ())?
    
    var dataDic:[String:Any]?
    
    
    class func instanceFromNib() -> AttentionView {
        return UINib(nibName: "AttentionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AttentionView
    }
    
    deinit {
        deinitObservers()
    }
    
    override func awakeFromNib() {
        registObservers([
            Config.Notify_AttentionPersonal
        ]) { [weak self] (nofity) in
            let info = nofity.userInfo
            if info != nil {
                let uid = info?["uid"] as? String
                let uidOrigin = self?.dataDic?["uid"] as? String
                if uid != nil && uid == uidOrigin
                {
                    self?.isAttention(true)
                }
            }
        }
    }
    
    @IBAction func attentionAction(_ sender: UIButton) {
        isAttention(!sender.isSelected)
        
        let uid = self.dataDic!["uid"] as! String
        
        self.attentionAction!(uid, sender.isSelected)
    }
    
    func setData(_ dic: [String:Any])
    {
        self.dataDic = dic
        self.coverIV.setHeadImageUrl(dic["head"] as! String)
        self.titleLB.text = "\(dic["nickname"]!)"
        let isAttention = dic["isAttention"] as! Int
        
        self.isAttention(isAttention == 1 ? true : false)
    }
    
    func isAttention(_ attention: Bool)
    {
        if attention
        {
            self.attentionBtn.isSelected = true
            self.attentionBtn.setTitle("已关注", for: .normal)
            self.attentionBtn.setTitleColor(UIColor.ColorHex("#808080"), for: .normal)
            self.attentionBtn.backgroundColor = UIColor.ColorHex("#393939")
        }else{
            self.attentionBtn.isSelected = false
            self.attentionBtn.setTitle("关注", for: .normal)
            self.attentionBtn.setTitleColor(BackgroundColor, for: .normal)
            self.attentionBtn.backgroundColor = YellowMainColor
        }
        
    }
}
