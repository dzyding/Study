//
//  CoachReduceCourseAlertView.swift
//  PPBody
//
//  Created by edz on 2019/7/27.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceCourseAlertView: UIView {

    @IBOutlet weak var msgLB: UILabel!
    
    var handler: (()->())?
    
    func updateUI(_ name: String) {
        msgLB.text = "是否核销一节“\(name)”课程？"
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        if let popView = superview as? DzyPopView {
            popView.hide()
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        handler?()
    }
}
