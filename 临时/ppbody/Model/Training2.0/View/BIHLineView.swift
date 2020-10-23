//
//  BIHLineView.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit
import Charts

class BIHLineView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var chartView: LineChartView!
    
    private var min: Double = 99999
    
    private var max: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.setViewPortOffsets(left: 20, top: 0, right: 20, bottom: 0)
        chartView.highlightPerTapEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.xAxis.enabled = true
    }
    
    func updateUI(_ list: [[String : Any]]) {
        let data = lineData(list)
        chartView.data = data
        chartView.animate(xAxisDuration: 0.25,
                          easingOption: .linear)
        
        var lineArr: [ChartLimitLine] = []
        var temp = min
        let x = (max - min) / 3.0
        while temp <= max {
            let line = ChartLimitLine(limit: temp, label: temp.decimalStr + "")
            line.drawLabelEnabled = false
            line.lineWidth = 0.5
            line.lineDashLengths = [4, 5]
            line.lineColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.1)
            temp += x
            lineArr.append(line)
        }
        let leftAxis = chartView.leftAxis
        leftAxis.spaceTop = 0.2
        leftAxis.spaceBottom = 0.2
        leftAxis.removeAllLimitLines()
        lineArr.forEach { (line) in
            leftAxis.addLimitLine(line)
        }
        leftAxis.drawTopYLabelEntryEnabled = false
        leftAxis.drawBottomYLabelEntryEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = false
        
        let xValues = list.compactMap({ value -> String? in
            guard let time = value.stringValue("time"),
                let timeArr = time
                    .components(separatedBy: " ")
                    .first?
                    .components(separatedBy: "-"),
                timeArr.count == 3
            else {return nil}
            return timeArr[1] + "/" + timeArr[2]
        })
        let xAxis = chartView.xAxis
        xAxis.setLabelCount(list.count, force: true)
        xAxis.labelPosition = .bottomInside
        xAxis.valueFormatter = XAxisValueType(xValues)
        xAxis.labelTextColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        xAxis.labelFont = dzy_FontBlod(10)
        xAxis.drawLabelsEnabled = true
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLimitLinesBehindDataEnabled = false
    }
    
    private func lineData(_ list: [[String : Any]]) -> LineChartData {
        let yVals = list.enumerated().map { (index, dic) -> ChartDataEntry in
            let value = dic.doubleValue("num") ?? 0
            min = Swift.min(min, value)
            max = Swift.max(max, value)
            return ChartDataEntry(x: Double(index), y: value)
        }
        let set = LineChartDataSet(entries: yVals, label: "kg")
        set.mode = .cubicBezier
        set.lineWidth = 3
        set.setColor(YellowMainColor)
        set.drawHorizontalHighlightIndicatorEnabled = true
        set.drawValuesEnabled = true
        set.valueTextColor = YellowMainColor
        set.valueFont = dzy_FontBlod(10)
        set.drawCirclesEnabled = true
        set.setCircleColor(.white)
        set.circleRadius = 4.0
        set.circleHoleColor = YellowMainColor
        set.circleHoleRadius = 3.0
        set.drawFilledEnabled = true
        let gColors = [UIColor.clear.cgColor, YellowMainColor.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gColors as CFArray, locations: nil)!
        set.fillAlpha = 1
        set.fill = Fill(linearGradient: gradient, angle:90)
        return LineChartData(dataSets: [set])
    }
}

private class XAxisValueType: IAxisValueFormatter {
    
    let values: [String]
    
    init(_ values: [String]) {
        self.values = values
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index < values.count else {return ""}
        return values[index]
    }
}
