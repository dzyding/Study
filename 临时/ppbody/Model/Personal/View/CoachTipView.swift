//
//  CoachTipView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/10/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class CoachTipView: UIView {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var contentView: UIView!
    var authAction:(()->())?

    class func instanceFromNib() -> CoachTipView {
        return UINib(nibName: "CoachTipView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CoachTipView
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        
        animation.duration = animation.settlingDuration // 动画持续时间
        animation.repeatCount = 1 // 重复次数
        animation.autoreverses = false // 动画结束时执行逆动画
        animation.mass = 1
        animation.stiffness = 100
        animation.damping = 13
        animation.initialVelocity = 8
        animation.fillMode = CAMediaTimingFillMode.removed
        animation.isRemovedOnCompletion = true
        
        animation.fromValue = 0.1
        animation.toValue = 1
        
        self.contentView.layer.add(animation, forKey: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func authCoach(_ sender: UIButton) {
        self.authAction!()
    }
}
