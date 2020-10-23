//
//  StudentCourseDetailCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class StudentCourseDetailCell: ScalingCarouselCell {
    
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var actionLB: UILabel!
    @IBOutlet weak var coreLB: UILabel!
    @IBOutlet weak var targetLB: UILabel!
    
    func setData(_ dic: [String:Any])
    {
        let motion = dic["motion"] as! [String:Any]
        
        self.nameLB.text = motion["name"] as? String
        self.coverIV.setCoverImageUrl(motion["cover"] as! String)
        self.actionLB.text = motion["actionPoint"] as? String
        self.coreLB.text = motion["trainingCore"] as? String
        
        let target = dic["target"] as! [String:Any]
        
        let time = target["time"] as? Int
        
        if time == nil
        {
            let groupNum = target["groupNum"] as! Int
            let freNum = target["freNum"] as! Int
            let weight = (target["weight"] as! NSNumber).floatValue.removeDecimalPoint
            self.targetLB.text = "\(groupNum)组  负重："+weight+"kg  \(freNum)个/组"
        }else{
            self.targetLB.text = "训练时长：" + ToolClass.secondToText(time! * 60)
        }
    }
}
