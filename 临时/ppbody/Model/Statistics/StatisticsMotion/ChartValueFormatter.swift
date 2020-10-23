//
//  ChartValueFormatter.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Charts

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var unit: String?

    convenience init(unit: String) {
        self.init()
        self.unit = unit
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if unit != nil && unit == "time"
        {
            return ToolClass.secondToText(Int(value))
        }
        return String(format: "%.1f", value)

    }
}
