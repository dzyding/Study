//
//  SearchPersonalCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol SearchPersonalCellAttentionDelegate:NSObjectProtocol {
    func attentionIndexPath(_ indexPath: IndexPath, isAttention:Bool)
}

class SearchPersonalCell: UITableViewCell {
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var attentionBtn: UIButton!
    var indexPath:IndexPath!
    
    weak var delegate:SearchPersonalCellAttentionDelegate?
    
    @IBAction func attentionAction(_ sender: UIButton) {
        isAttention(!sender.isSelected)
        
        self.delegate?.attentionIndexPath(self.indexPath, isAttention: sender.isSelected)
    }
    
    func setData(_ dic:[String:Any], indexPath:IndexPath)
    {
        self.indexPath = indexPath
        
        self.headIV.setHeadImageUrl(dic["head"] as! String)
        self.nameLB.text = dic["nickname"] as? String
        
        let isAttention = dic["isAttention"] as! Int
        
        let type = dic["type"] as! Int
        self.typeLB.isHidden = type == 20 ? false : true
        
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
