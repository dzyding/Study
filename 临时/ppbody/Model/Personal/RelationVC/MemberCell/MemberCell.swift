//
//  MemberCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/10/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

@objc protocol RelationCellAttentionDelegate:NSObjectProtocol {
    func attentionIndexPath(_ indexPath: IndexPath, isAttention:Bool)
    
    @objc optional func editRemarkName(_ indexPath: IndexPath)
}

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nicknameLB: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var attentionBtn: UIButton!
    @IBOutlet weak var bodyLB: UILabel!
    
    var indexPath:IndexPath!
    
    weak var delegate:RelationCellAttentionDelegate?
    
    @IBAction func attentionAction(_ sender: UIButton) {
        isAttention(!sender.isSelected)
        self.delegate?.attentionIndexPath(self.indexPath, isAttention: sender.isSelected)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
    
        self.delegate?.editRemarkName!(self.indexPath)
    }
    
    func setData(_ dic: [String:Any], indexPath:IndexPath)
    {
        self.indexPath = indexPath
        
        self.headIV.setHeadImageUrl(dic["head"] as! String)
        self.nameLB.text = dic["nickname"] as? String
        
        let isAttention = dic["isAttention"] as! Int
        
        self.isAttention(isAttention == 1 ? true : false)
        
        let remark = dic["remark"] as? String
        if remark != nil{
            self.nameLB.text = remark
            self.nicknameLB.text = "昵称：" + (dic["nickname"] as! String)
            self.nicknameLB.isHidden = false
        }else{
            self.nicknameLB.isHidden = true
        }
        
        let weight = (dic["weight"] as! NSNumber).floatValue.removeDecimalPoint
        
        var bodyData = "体重:" + weight + "kg"
        
        let musclePer = dic["musclePer"] as? String
        if musclePer != nil
        {
            bodyData  = bodyData + "  肌肉比:" + musclePer!
        }
        
        let fatPer = dic["fatPer"] as? String
        if fatPer != nil
        {
            bodyData  = bodyData + "  脂肪比:" + fatPer!
        }
        
        self.bodyLB.text = bodyData
        

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
