//
//  ChartViewCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Charts

class LineChartViewCell: UITableViewCell {
    @IBOutlet weak var chartview: LineChartView!
    @IBOutlet weak var titleLB: UILabel!
    
    var listData = [[String:Any]]()
    
    var aveWeight:Double = 0
    var aveFre:Double = 0
    var aveTime:Double = 0
    
    override func awakeFromNib() {
        chartview.delegate = self
        chartview.backgroundColor = CardColor

        chartview.chartDescription?.enabled = false
        chartview.dragEnabled = false
        chartview.setScaleEnabled(false)
        chartview.pinchZoomEnabled = false
        chartview.setViewPortOffsets(left: 10, top: 0, right: 10, bottom: 0)
        chartview.highlightPerTapEnabled = false
        
        chartview.legend.enabled = false
        
        //        chart.leftAxis.enabled = false
        chartview.leftAxis.spaceTop = 0.4
        chartview.leftAxis.spaceBottom = 0.4
        chartview.rightAxis.enabled = false
        chartview.xAxis.enabled = false
    }
    
    func setData(_ dic:[String:Any])
    {
        
        self.titleLB.text = dic["name"] as? String
        listData = dic["list"] as! [[String:Any]]
        
//        let code = dic["code"] as! String
        
        let data = dataWithCount(listData.count)
        setupChart(chartview, data: data)
        
    }
   
    func dataWithCount(_ count: Int) -> LineChartData {
        
        var totalWeight:Double = 0
        var totalFre:Double = 0
        
        let yVals = (0..<count).map { i -> ChartDataEntry in
            let dic = self.listData[i]
            let value1 = (dic.doubleValue("weight") ?? 0) + 30
            totalWeight += value1
            return ChartDataEntry(x: Double(i), y: value1)
        }
        
        let yVals1 = (0..<count).map { i -> ChartDataEntry in
            let dic = self.listData[i]
            let value2 = dic.doubleValue("freNum") ?? 0
            totalFre += value2
            return ChartDataEntry(x: Double(i), y: value2)
        }
        
        aveWeight = totalWeight/Double(self.listData.count)
        aveFre = totalFre/Double(self.listData.count)
        
        let set1 = LineChartDataSet(entries: yVals, label: "kg")
        set1.mode = .cubicBezier
        set1.lineWidth = 1.75
        set1.setColor(YellowMainColor)
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.drawHorizontalHighlightIndicatorEnabled = false
        
        let set2 = LineChartDataSet(entries: yVals1, label: "次")
        set2.mode = .cubicBezier
        set2.lineWidth = 1.75
        set2.setColor( BlueLineColor)
        //        set2.setColors(UIColor.ColorHex("#F22F08"))
        set2.drawValuesEnabled = false
        set2.drawCirclesEnabled = false
        
        return LineChartData(dataSets: [set1, set2])
    }
    
    
    func setupChart(_ chart: LineChartView, data: LineChartData) {
        
 
    
        chart.data = data
        
        chart.animate(xAxisDuration: 0.25, easingOption: .linear)
        
        let ll1 = ChartLimitLine(limit: aveWeight, label: (aveWeight - 30).removeDecimalPoin + "kg")
        ll1.lineWidth = 2
        ll1.lineDashLengths = [8, 2]
        ll1.labelPosition = .topRight
        ll1.valueFont = .systemFont(ofSize: 10)
        ll1.lineColor = UIColor.ColorHex("#4A4A4A")
        ll1.valueTextColor = .white
        
        
        let ll2 = ChartLimitLine(limit: aveFre, label: aveFre.formatStr(f: 0) + "次")
        ll2.lineWidth = 2
        ll2.lineDashLengths = [8,2]
        ll2.labelPosition = .bottomRight
        ll2.valueFont = .systemFont(ofSize: 10)
        ll2.lineColor = UIColor.ColorHex("#4A4A4A")
        ll2.valueTextColor = .white
        
        let leftAxis = chart.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.addLimitLine(ll2)
        
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
    }
    
}

extension LineChartViewCell:ChartViewDelegate
{
    // TODO: Cannot override from extensions
    //extension DemoBaseViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}
