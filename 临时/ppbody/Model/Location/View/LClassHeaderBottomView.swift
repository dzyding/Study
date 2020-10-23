//
//  LClassHeaderBottomView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LClassHeaderBottomView: UIView, InitFromNibEnable {
    
    var shopHandler: ((UIButton)->())?
    
    var evaluateHandler: ((UIButton)->())?

    @IBAction private func shopListAction(_ sender: UIButton) {
        shopHandler?(sender)
    }
    
    @IBAction private func evaluateAction(_ sender: UIButton) {
        evaluateHandler?(sender)
    }

}
