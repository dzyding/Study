//
//  LGymGCDateCell.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymGCDateCell: UIView, InitFromNibEnable {

    @IBOutlet private weak var topLB: UILabel!
    
    @IBOutlet private weak var bottomLB: UILabel!
    
    var handler: ((Int)->())?
    
    func updateUI(_ value: (String, String, Bool)) {
        topLB.text = value.0
        bottomLB.text = value.1
        if value.2 {
            topLB.textColor = .white
            bottomLB.textColor = .white
        }else {
            topLB.textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
            bottomLB.textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        }
    }
    
    @IBAction func clickAction(_ sender: UIButton) {
        handler?(tag)
    }
}
