//
//  RelationCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


class RelationCell: UITableViewCell {
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var attentionBtn: UIButton!
    
    var indexPath:IndexPath!
    
    weak var delegate:RelationCellAttentionDelegate?
    
    @IBAction func attentionAction(_ sender: UIButton) {
        isAttention(!sender.isSelected)
        
        self.delegate?.attentionIndexPath(self.indexPath, isAttention: sender.isSelected)
    }
    
    func setData(_ dic: [String:Any], indexPath:IndexPath)
    {
        self.indexPath = indexPath
        
        self.headIV.setHeadImageUrl(dic["head"] as! String)
        self.nameLB.text = dic["nickname"] as? String
        
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
