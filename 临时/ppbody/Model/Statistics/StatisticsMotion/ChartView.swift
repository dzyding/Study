//
//  LineChartView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Charts

class ChartView: UIView
{
    
    @IBOutlet weak var chartview: LineChartView!
    
    let numArr = [10,30,20,40,20,50,60,50,90,30,43,44,20,34,50,40]
    var numNewArr=[Double]()
    
    let weightArr = [50,40,30,40,55,60,60,50,30,40,35,45,65,35,50,40]
    var weightNewArr=[Double]()
    
    class func instanceFromNib() -> ChartView {
        return UINib(nibName: "StatisticsDataView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! ChartView
    }
    
    override func awakeFromNib() {
        
        for i in 0..<(numArr.count-1)*5
        {
            let index = i/5
            numNewArr.append(Double(numArr[index]+(numArr[index+1]-numArr[index])*(i%5)/5))
        }
        
        for i in 0..<(weightArr.count-1)*5
        {
            let index = i/5
            weightNewArr.append(Double(weightArr[index]+(weightArr[index+1]-weightArr[index])*(i%5)/5))
        }
        
        let data = dataWithCount(weightNewArr.count, range: 100)
        
        setupChart(chartview, data: data)
    }
    
    func setupChart(_ chart: LineChartView, data: LineChartData) {
        
        chart.delegate = self
        chart.backgroundColor = CardColor
        
        chart.chartDescription?.enabled = false
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.setViewPortOffsets(left: 10, top: 0, right: 10, bottom: 0)
        chart.highlightPerTapEnabled = false
        
        chart.legend.enabled = false
        
//        chart.leftAxis.enabled = false
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = false
        
        chart.data = data
        
        chart.animate(xAxisDuration: 2.5)
        
        let ll1 = ChartLimitLine(limit: 70, label: "30kg")
        ll1.lineWidth = 2
        ll1.lineDashLengths = [8, 2]
        ll1.labelPosition = .topRight
        ll1.valueFont = .systemFont(ofSize: 10)
        ll1.lineColor = UIColor.ColorHex("#4A4A4A")
        ll1.valueTextColor = .white

        
        let ll2 = ChartLimitLine(limit: 20, label: "20次")
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
    
    func dataWithCount(_ count: Int, range: UInt32) -> LineChartData {
        let yVals = (0..<weightNewArr.count).map { i -> ChartDataEntry in
            let val = weightNewArr[i] + 30
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let yVals1 = (0..<numNewArr.count).map { i -> ChartDataEntry in
            let val = numNewArr[i]
            return ChartDataEntry(x: Double(i), y: val)
        }
        
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
        set2.setColor(BlueLineColor)
        set2.setCircleColor(.white)
        set2.drawValuesEnabled = false
        set2.drawCirclesEnabled = false
        
        return LineChartData(dataSets: [set1, set2])
    }
}

extension ChartView:ChartViewDelegate
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
