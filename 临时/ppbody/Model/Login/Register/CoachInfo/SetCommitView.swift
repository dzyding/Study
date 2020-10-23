//
//  SetCommitView.swift
//  PPBody
//
//  Created by Mike on 2018/7/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SetCommitView: UIView {
    
    @IBOutlet weak var btnCommit: UIButton!

   
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        btnCommit.layer.masksToBounds = true
        btnCommit.layer.cornerRadius = 25.0
    }

    class func instanceFromNib() -> SetCommitView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[5] as! SetCommitView
    }
}
