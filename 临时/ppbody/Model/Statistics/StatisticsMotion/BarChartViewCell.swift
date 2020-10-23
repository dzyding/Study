//
//  BarChartViewCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Charts

class BarChartViewCell: UITableViewCell {
    @IBOutlet weak var chartview: BarChartView!
    @IBOutlet weak var titleLB: UILabel!
    
    
    var listData = [[String:Any]]()
    

    var aveTime:Double = 0
    
    override func awakeFromNib() {
        chartview.delegate = self
        chartview.backgroundColor = CardColor

        chartview.fitBars = true
        chartview.chartDescription?.enabled = false
        chartview.dragEnabled = false
        chartview.setScaleEnabled(false)
        chartview.pinchZoomEnabled = false
        chartview.setViewPortOffsets(left: 10, top: 10, right: 10, bottom: 0)
        chartview.highlightPerTapEnabled = false
        
        chartview.legend.enabled = false
        
        //        chart.leftAxis.enabled = false
        chartview.leftAxis.enabled = false
//        chartview.leftAxis.spaceBottom = 0.4
        chartview.rightAxis.enabled = false
        chartview.xAxis.enabled = false
    }
    
    func setData(_ dic:[String:Any])
    {
        
        self.titleLB.text = dic["name"] as? String
        listData = dic["list"] as! [[String:Any]]
        
        //有氧运动
        let data = dataCardioWithCount(listData.count)
        setupCardioChart(chartview, data: data)
  
    }
    
    func dataCardioWithCount(_ count: Int) -> BarChartData {
        
        
        let yVals = (0..<count).map { i -> BarChartDataEntry in
            let dic = self.listData[i]
            let time = (dic["time"] as! NSNumber).doubleValue
            
            return BarChartDataEntry(x: Double(i), y: time)
        }
        
        
        
        var set1: BarChartDataSet! = nil
        
        set1 = BarChartDataSet(entries: yVals, label: "")
        set1.colors = [YellowMainColor,BlueLineColor]
        set1.drawValuesEnabled = true
        set1.valueFormatter = ChartValueFormatter(unit: "time")
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.setValueTextColor(UIColor.white)

        data.barWidth = 0.2
        
        return data
        
    }
    
    func setupCardioChart(_ chart: BarChartView, data: BarChartData) {
        

        
        chart.data = data
        
        chart.animate(xAxisDuration: 0.25, easingOption: .linear)
        
//        let ll1 = ChartLimitLine(limit: aveTime/60, label: (aveTime/60).removeDecimalPoin + "min")
//        ll1.lineWidth = 2
//        ll1.lineDashLengths = [8, 2]
//        ll1.labelPosition = .rightTop
//        ll1.valueFont = .systemFont(ofSize: 10)
//        ll1.lineColor = UIColor.ColorHex("#4A4A4A")
//        ll1.valueTextColor = .white
//
//        let leftAxis = chart.leftAxis
//        leftAxis.removeAllLimitLines()
//        leftAxis.addLimitLine(ll1)
//
//        leftAxis.drawGridLinesEnabled = false
//        leftAxis.drawZeroLineEnabled = false
//        leftAxis.drawAxisLineEnabled = false
//        leftAxis.drawLabelsEnabled = false
//        leftAxis.drawLimitLinesBehindDataEnabled = true
        
    }
    
}

extension BarChartViewCell:ChartViewDelegate
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
