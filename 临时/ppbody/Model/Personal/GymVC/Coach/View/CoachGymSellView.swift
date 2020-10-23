//
//  CoachGymSellView.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol CoachGymSellViewDelegate {
    func sellView(_ sellView: CoachGymSellView, didSelectMoreBtn btn: UIButton)
}

class CoachGymSellView: UIView {
    
    weak var delegate: CoachGymSellViewDelegate?

    @IBOutlet weak var currentLB: UILabel!
    
    @IBOutlet weak var goalLB: UILabel!
    
    @IBOutlet weak var currentView: UIView!
    
    @IBOutlet weak var goalVIew: UIView!
    
    @IBOutlet weak var currentWidthLC: NSLayoutConstraint!
    
    func updateUI(_ info: [String : Any]) {
        let current = info.intValue("complete") ?? 0
        let target  = info.intValue("target") ?? 0
        currentLB.text = "\(current)"
        goalLB.text    = "任务指标\(target)"
        if target == 0 {
            // target 为0就是就默认 70%
            let width = (goalVIew.frame.width - 2.0) * 0.7
            currentWidthLC.constant = width
            goalLB.isHidden = true
        }else {
            goalLB.isHidden = false
            var x = CGFloat(current) / CGFloat(target)
            x = min(x, 1.0)
            let width = (goalVIew.frame.width - 2.0) * x
            currentWidthLC.constant = width
        }
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        delegate?.sellView(self, didSelectMoreBtn: sender)
    }
}
