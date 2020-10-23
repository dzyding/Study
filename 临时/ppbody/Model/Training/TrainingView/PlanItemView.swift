//
//  PlanItemView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PlanItemView: UIView
{
    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    
    class func instanceFromNib() -> PlanItemView {
        return UINib(nibName: "TrainingItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlanItemView
    }
    
    override func awakeFromNib() {
        
    }
    
    func setData(_ dic: [String:Any])
    {
        let user = dic["user"] as! [String:Any]
        
        self.head.setHeadImageUrl(user["head"] as! String)
        self.nameLB.text = "\(user["nickname"]!)"
        
        self.timeLB.text = dic["timeLine"] as? String
    }
}
