//
//  TopicAttentionCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicAttentionCell: UITableViewCell {
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var remarkLB: UILabel!
    @IBOutlet weak var nameCenterY: NSLayoutConstraint!
    
    func setData(_ model: StudentUserModel, isSelect: Bool)
    {
        self.headIV.setHeadImageUrl(model.head!)
        self.nameLB.text = model.name
        self.selectBtn.isSelected = isSelect
        
        if model.remark == nil
        {
            self.nameCenterY.constant = 0
            self.remarkLB.isHidden = true
        }else{
            self.nameCenterY.constant = -8
            self.remarkLB.isHidden = false
            self.nameLB.text = model.remark
            self.remarkLB.text = "昵称：" + model.name!
        }
    }
}
