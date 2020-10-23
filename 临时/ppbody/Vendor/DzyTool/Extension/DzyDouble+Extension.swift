//
//  DzyDouble+Extension.swift
//  YJF
//
//  Created by edz on 2019/7/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

extension Double {
    var decimalStr: String {
        let tempStr = "\(self)"
        let arr = tempStr.components(separatedBy: ".")
        if arr.count == 2,
            arr[1] != "0"
        {
            var str = arr[1]
            if str.count >= 2 {
                // 如果有两位，并且第二位正好是 0
                let sIndex = str.index(after: str.startIndex)
                let eIndex = str.index(after: sIndex)
                let secondChar = str[sIndex..<eIndex]
                if secondChar == "0" {
                    str = String(str[..<sIndex])
                }
            }
            let count = min(str.count, 2)
            return String(format: "%.\(count)lf", self)
        }else {
            return String(format: "%.0lf", self)
        }
    }
}
