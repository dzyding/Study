//
//  PersonalTotalStatisView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PersonalTotalStatisView: UIView {
    
    @IBOutlet weak var xiongLB: UILabel!
    @IBOutlet weak var xiongHeight: NSLayoutConstraint!
    
    @IBOutlet weak var beiLB: UILabel!
    @IBOutlet weak var beiHeight: NSLayoutConstraint!
    
    @IBOutlet weak var jianLB: UILabel!
    @IBOutlet weak var jianHeight: NSLayoutConstraint!
    
    @IBOutlet weak var fuLB: UILabel!
    @IBOutlet weak var fuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var shoubiLB: UILabel!
    @IBOutlet weak var shoubiHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tuntuiLB: UILabel!
    @IBOutlet weak var tuntuiHeight: NSLayoutConstraint!
    
    @IBOutlet weak var youyangLB: UILabel!
    
    var offset:CGFloat = 300
    
    class func instanceFromNib() -> PersonalTotalStatisView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[5] as! PersonalTotalStatisView
    }
    
    func setData(_ dic:[String:Any])
    {
        
        let xiongNum = dic["MG10000"] as! Int
        self.xiongLB.text = "\(xiongNum)"
        
        let beiNum = dic["MG10001"] as! Int
        self.beiLB.text = "\(beiNum)"
        
        let jianNum = dic["MG10002"] as! Int
        self.jianLB.text = "\(jianNum)"
        
        let fuNum = dic["MG10003"] as! Int
        self.fuLB.text = "\(fuNum)"
        
        let shoubiNum = dic["MG10004"] as! Int
        self.shoubiLB.text = "\(shoubiNum)"
        
        let tuntuiNum = dic["MG10005"] as! Int
        self.tuntuiLB.text = "\(tuntuiNum)"
        
        let youyangNum = dic["MG10006"] as! Int
        self.youyangLB.text = "有氧运动总时长：" + ToolClass.secondToText(youyangNum)
        
        var maxNum = CGFloat(max(xiongNum,beiNum,jianNum,fuNum,shoubiNum,tuntuiNum))
        
        maxNum = (maxNum / offset + 1) * offset
        
        UIView.animate(withDuration: 0.25) {
            self.xiongHeight.constant = CGFloat(xiongNum)/maxNum * 110
            self.beiHeight.constant = CGFloat(beiNum)/maxNum * 110
            self.jianHeight.constant = CGFloat(jianNum)/maxNum * 110
            self.fuHeight.constant = CGFloat(fuNum)/maxNum * 110
            self.shoubiHeight.constant = CGFloat(shoubiNum)/maxNum * 110
            self.tuntuiHeight.constant = CGFloat(tuntuiNum)/maxNum * 110
            self.layoutIfNeeded()
        }
        
    }
}
