//
//  TopicTagCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicTagCell: UITableViewCell {
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var joinLB: UILabel!
    
    func setData(_ dic: [String:Any])
    {
        self.nameLB.text = dic["name"] as? String
        self.joinLB.text = "\(dic["joinNum"] ?? "")人参与挑战"
    }
}
