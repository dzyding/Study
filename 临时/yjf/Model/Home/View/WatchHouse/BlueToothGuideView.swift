//
//  BlueToothGuideView.swift
//  YJF
//
//  Created by edz on 2019/10/18.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class BlueToothGuideView: UIView, InitFromNibEnable {

    @IBAction private func sureAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
    }

}
