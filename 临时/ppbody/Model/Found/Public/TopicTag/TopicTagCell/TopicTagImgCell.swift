//
//  TopicTagImgCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicTagImgCell: UITableViewCell {
    
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var endIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var joinLB: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBAction func selectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func setData(_ dic: [String:Any]) {
        endIV.isHidden = dic.intValue("status") != 20
        coverIV.setCoverImageUrl(dic["cover"] as! String)
        titleLB.text = dic["title"] as? String
        nameLB.text = dic["name"] as? String
        joinLB.text = "\(dic["joinNum"] ?? "")人参与挑战"

        if !selectBtn.isHidden {
            selectBtn.isSelected = dic["isSelect"] as! Bool
        }
    }
}
