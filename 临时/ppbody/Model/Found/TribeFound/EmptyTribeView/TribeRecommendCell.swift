//
//  TribeRecommendCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/17.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeRecommendCell: UITableViewCell
{
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var cityLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var sloganLB: UILabel!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nicknameLB: UILabel!
    @IBOutlet weak var dataLB: UILabel!
    
    func setData(_ dic: [String:Any])
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.cityLB.text = dic["city"] as? String
        self.nameLB.text = dic["name"] as? String
        self.sloganLB.text = dic["slogan"] as? String
        
        let memberNum = dic["memberNum"] as! Int
        let topicNum = dic["topicNum"] as! Int
        self.dataLB.text = "成员:\(memberNum)  话题量:\(topicNum)"
        
        let user = dic["user"] as! [String:Any]
        self.headIV.setHeadImageUrl(user["head"] as! String)
        self.nicknameLB.text = user["nickname"] as? String
    }
}
