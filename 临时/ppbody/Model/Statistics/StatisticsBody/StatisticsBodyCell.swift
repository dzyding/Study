//
//  StatisticsBodyCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Charts

class StatisticsBodyCell: UITableViewCell {
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var chartview: LineChartView!
    @IBOutlet weak var dotIV: UIImageView!
    @IBOutlet weak var unitLB: UILabel!
 
    var listData = [Double]()
    
    var kgUnit = ["weight","muscle","fat"]
    
    var indexPath:IndexPath!
 
    
    func setData(_ dic:[String:Any], indexPath:IndexPath)
    {
        
        self.indexPath = indexPath
        
        let title = dic.keys.first
        
        self.nameLB.text = ToolClass.getTitleFromLetter(title!)
        
        if kgUnit.contains(title!)
        {
            self.unitLB.text = "kg"
        }else{
            self.unitLB.text = "cm"
        }
        
        listData = dic[title!] as! [Double]
        let data = dataWithCount(listData.count, range: 100)
        
        setupChart(chartview, data: data)
    }
    
    func setupChart(_ chart: LineChartView, data: LineChartData) {
        
        chart.backgroundColor = CardColor
        
        chart.chartDescription?.enabled = false
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.setViewPortOffsets(left: 8, top: 0, right: 8, bottom: 0)
        chart.highlightPerTapEnabled = false
        
        chart.legend.enabled = false
        
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = false
        
        chart.data = data
        
        chart.animate(xAxisDuration: 0.25, easingOption: .linear)
        
        
        let leftAxis = chart.leftAxis

        
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
    }
    
    func dataWithCount(_ count: Int, range: UInt32) -> LineChartData {
        let yVals = (0..<listData.count).map { i -> ChartDataEntry in
            let val = listData[i].format(f: 1)
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let color = self.indexPath.row%2 == 0 ? BlueLineColor : YellowMainColor
        
        let set1 = LineChartDataSet(entries: yVals, label: "kg")
        set1.mode = .cubicBezier
        set1.lineWidth = 1.75
        set1.setColor(color)
        set1.valueTextColor = Text1Color
        set1.drawFilledEnabled = true
        set1.drawValuesEnabled = true
        set1.drawCirclesEnabled = false
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.valueFormatter = ChartValueFormatter()

        
        let gradientColors = [UIColor.clear.cgColor,color.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle:90)

        return LineChartData(dataSets: [set1])
    }
}
