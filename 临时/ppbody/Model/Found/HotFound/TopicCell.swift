//
//  TopicCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicCell: UICollectionViewCell {
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var hotIV: UIImageView!
    @IBOutlet weak var tagLB: UILabel!
    @IBOutlet weak var playIV: UIImageView!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var zanNumLB: UILabel!
    
    @IBOutlet weak var supportBtn: UIButton!
    
    
    func setData(_ dic: [String:Any], topic:Bool? = false)
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.titleLB.text = dic["content"] as? String
        
        let user = dic["user"] as! [String:Any]
        self.nameLB.text = user["nickname"] as? String
        self.headIV.setHeadImageUrl(user["head"] as! String)
        
        let video = dic["video"] as? String
        self.playIV.isHidden = (video == nil||video == "") ? true : false
        
        self.zanNumLB.text = (dic["supportNum"] as! Int).compressValue
        
        let isSupport = dic["isSupport"] as? Int
        if isSupport != nil
        {
            self.supportBtn.isSelected = isSupport == 1 ? true : false
        }
        
        let type = user["type"] as! Int
        if type == 20
        {
            self.headIV.layer.borderColor = YellowMainColor.cgColor
            self.headIV.layer.borderWidth = 1
        }else{
            self.headIV.layer.borderColor = nil
            self.headIV.layer.borderWidth = 0
        }
        
        if topic! {
            let tagType = dic["tagType"] as? Int
            if tagType == nil || tagType! < 10
            {
                self.tagLB.isHidden = true
            }else if tagType == 10
            {
                self.tagLB.text = "置顶"
                self.tagLB.isHidden = false
            }else if tagType == 20
            {
                self.tagLB.text = "示范"
                self.tagLB.isHidden = false
            }else if tagType == 30
            {
                self.tagLB.text = "发起人"
                self.tagLB.isHidden = false
            }
        }else{
            let top = dic["top"] as? Int
            if top != nil && top == 10
            {
                self.hotIV.isHidden = false
            }else{
                self.hotIV.isHidden = true
            }
        }
        
    }
    
 
}
