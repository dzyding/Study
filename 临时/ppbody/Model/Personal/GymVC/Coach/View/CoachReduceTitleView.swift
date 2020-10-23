//
//  CoachReduceTitleView.swift
//  PPBody
//
//  Created by edz on 2019/5/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceTitleView: UIView {
    
    var handler: (()->())?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 105, height: 44)
    }

    @IBOutlet weak var titleLB: UILabel!
    
    @IBAction func changeAction(_ sender: UIButton) {
        titleLB.text = titleLB.text == "本周预约" ? "下周预约" : "本周预约"
        handler?()
    }
}
