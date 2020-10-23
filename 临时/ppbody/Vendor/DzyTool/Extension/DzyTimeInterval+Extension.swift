//
//  DzyTimeInterval+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

//MARK: - 获取倒计时的年月日
typealias Dzy_CoutDownType = (day: Int, hour: Int, minute: Int, second: Int) //天 时 分 秒

extension TimeInterval {
    func dzy_CoutDownDate() -> (Dzy_CoutDownType) {
        let time = Int(self)
        let dayNum: Int  = time / 86400
        let hourNum: Int = time % 86400 / 3600
        let minuteNum: Int = time % 3600 / 60
        let secondNum: Int = time % 60
        return (day: dayNum, hour: hourNum, minute: minuteNum, second: secondNum)
    }
}
