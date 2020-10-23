//
//  BlueToothOpenView.swift
//  YJF
//
//  Created by edz on 2019/8/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class BlueToothOpenView: UIView {

    @IBOutlet private weak var msgLB: UILabel!
    
    func updateUI(_ str: String) {
        msgLB.text = str
    }
}
