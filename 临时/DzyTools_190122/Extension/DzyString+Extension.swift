//
//  DzyString+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

extension String {
    var dzy_checkDecimal: Bool {
        if contains("."),
            let last = components(separatedBy: ".").last,
            last.count > 2
        {
            return false
        }else {
            return true
        }
    }
    
    func dzy_dateOperation() -> String {
        var str = self
        str = str.replacingOccurrences(of: "T", with: " ")
        if str.contains(".") {
            str = str.components(separatedBy: ".").first ?? ""
        }
        return str
    }
    
    var dzy_IDCard: Bool {
        if count == 18 {
            return true
        }else {
            return false
        }
    }
}
