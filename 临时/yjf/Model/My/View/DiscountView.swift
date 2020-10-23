//
//  DiscountView.swift
//  YJF
//
//  Created by edz on 2019/8/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DiscountView: UIView {

    @IBOutlet weak var leftLB: UILabel!

    @IBOutlet weak var rightLB: UILabel!
    
    func updateUI(_ str: String) {
        let arr = str.components(separatedBy: ":")
        leftLB.text = arr.first
        if let value = arr.last,
            let result = Double(value)
        {
            rightLB.text = String(format: "%.1lf折", result * 10)
        }
    }
}
