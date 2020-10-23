//
//  BlueToothOpenSuccessView.swift
//  YJF
//
//  Created by edz on 2019/8/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class BlueToothOpenSuccessView: UIView {
    
    @IBAction func sureAction(_ sender: UIButton) {
        if let pop = superview as? DzyPopView {
            pop.hide()
        }
    }
}
