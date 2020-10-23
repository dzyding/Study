//
//  DzyString+Extension.swift
//  YJF
//
//  Created by edz on 2019/7/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

extension String.StringInterpolation {
    public enum OptionalStyle {
        /// 保留2位有效位数，最后一位的0则不显示
        case price
        /// 不保留小数
        case toInt
    }
    
    public mutating func appendInterpolation<T>(
        _ value: T?,
        optStyle style: String.StringInterpolation.OptionalStyle
    ) {
        switch style {
        case .price:
            if let value = value as? Double {
                appendInterpolation(value.decimalStr)
            }else {
                appendLiteral("0")
            }
        case .toInt:
            if let value = value as? Double {
                appendInterpolation(String(format: "%.0lf", value))
            }else {
                appendLiteral("0")
            }
        }
    }
    
    public mutating func appendInterpolation<T:CVarArg>(_ value: T?, format: String) {
        if let value = value {
            appendInterpolation(String(format: format, value))
        }else {
            appendLiteral("")
        }
    }
}
