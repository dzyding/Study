//
//  DzyNSLayoutConstraint+Extension.swift
//  HousingMarket
//
//  Created by edz on 2018/11/30.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    func setMultiplier(_ value: CGFloat) {
        setValue(value, forKey: "multiplier")
    }
}
