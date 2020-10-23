//
//  CoachGymClassNumView.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol CoachGymClassNumViewDelegate {
    func classNumView(_ classNumView: CoachGymClassNumView, didSelectedMoreBtn btn: UIButton)
}

class CoachGymClassNumView: UIView {
    
    weak var delegate: CoachGymClassNumViewDelegate?

    @IBOutlet weak var numLB: UILabel!
    
    func updateUI(_ num: Int) {
        numLB.text = "\(num)"
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        delegate?.classNumView(self, didSelectedMoreBtn: sender)
    }
}
