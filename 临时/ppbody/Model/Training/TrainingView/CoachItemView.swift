//
//  CoachItemView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class CoachItemView: UIView
{
    
    @IBOutlet weak var headIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var planNameLB: UILabel!
    @IBOutlet weak var planContentLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    
    class func instanceFromNib() -> CoachItemView {
        return UINib(nibName: "TrainingItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! CoachItemView
    }
    
    
    func setData(_ dic: [String:Any])
    {
        let user = dic["coach"] as! [String:Any]
        
        self.headIV.setHeadImageUrl(user["head"] as! String)
        self.nameLB.text = "\(user["nickname"]!)"
        
        self.planNameLB.text = dic["planName"] as? String
        self.planContentLB.text = dic["planContent"] as? String
        self.timeLB.text = dic["timeLine"] as? String
    }
}
