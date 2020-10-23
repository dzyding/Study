//
//  MyGymCoachView.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol MyGymCoachViewDelegate {
    func coachView(_ coachView: MyGymCoachView,
                   didClickReserveBtn btn: UIButton)
    
    func coachView(_ coachView: MyGymCoachView,
                   didClickClassesBtn btn: UIButton)
}

class MyGymCoachView: UIView {
    
    @IBOutlet weak var nameLB: UILabel!
    // 交叉预约
    @IBOutlet weak var jxyyIV: UIImageView!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var goBtn: UIButton!
    
    weak var delegate: MyGymCoachViewDelegate?
    
    @IBAction func orderAction(_ sender: UIButton) {
        delegate?.coachView(self, didClickReserveBtn: sender)
    }
    
    @IBAction func classesAction(_ sender: Any) {
        delegate?.coachView(self, didClickClassesBtn: sender as! UIButton)
    }
    
    func setUI(_ data: [String : Any]) {
        let classNum = data.intValue("classNum") ?? 0
        nameLB.text = data.stringValue("ptName")
        numLB.text = "\(classNum)"
        jxyyIV.isHidden = data.intValue("multi") == 0
        let isOpen = data.intValue("isOpen") ?? 0
        if isOpen == 1 && classNum != 0 {
            goBtn.setImage(UIImage(named: "gym_go"), for: .normal)
            goBtn.isUserInteractionEnabled = true
        }else {
            goBtn.setImage(UIImage(named: "gym_go_no"), for: .normal)
            goBtn.isUserInteractionEnabled = false
        }
    }
}
