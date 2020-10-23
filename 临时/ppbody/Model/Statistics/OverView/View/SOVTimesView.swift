//
//  SOVTimesView.swift
//  PPBody
//
//  Created by edz on 2020/1/2.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class SOVTimesView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let calendar = Calendar.current
    // 第几列，第几个，月份
    private var monthValues: [(column: Int, num: Int, month: Int)] = []
    // 日期 训练次数
    private var daysValues: [(date: String, num: Int)] = []
    // 最大值
    private var maxValue: Int = 0
    
    func initUI(_ list: [[String : Any]]) {
        getTimeValues(list)
        // 宽高
        let value: CGFloat = 15.0
        // 间隔
        let padding: CGFloat = 2.0
        // 左间距
        let pleft: CGFloat = 0.0
        assert(monthValues.count == 6)
        (0..<6).forEach { (index) in
            let n = CGFloat(monthValues[index].column - 1)
            let x = pleft + n * (value + padding) + padding
            let label = getLabel("\(monthValues[index].month)月")
            var frame = label.frame
            frame.origin.x = x
            label.frame = frame
        }
        if let num = monthValues.first?.num {
            let max = num + maxValue
            (1...(max / 7)).forEach { (index) in
                let last = index * 7
                let list = daysValues[(last - 7)..<last]
                let v = getView(list)
                stackView?.addArrangedSubview(v)
                v.snp.makeConstraints { (make) in
                    make.width.equalTo(15)
                }
            }
        }
    }
    
    private func getTimeValues(_ list: [[String : Any]]) {
        let firstDay = getTheWeekDayForTheMonthLastDay()
        let firstMonth = calendar
            .component(.month, from: firstDay.1)
        // 第几列，第几个(从0开始), 几月份
        let firstNum = getIndexForWeekDay(firstDay.0)
        monthValues = [(1, firstNum, firstMonth)]
        daysValues = [(String, Int)].init(repeating: ("-1", -1), count: firstNum)
        // 总月份
        var totalMonth = 0
        // 当月最后一天
        let day = firstDay.1
        // 当前月份
        var cmonth = calendar.component(.month, from: day)
        // 当前年份
        var cyear = calendar.component(.year, from: day)
        // 变量
        var addcom = DateComponents()
        var x = 0
        while totalMonth < 6 {
            addcom.day = x
            guard let tdate = calendar
                .date(byAdding: addcom, to: day)
            else {continue}
            let dateStr = tdate.description
                .components(separatedBy: " ").first ?? ""
            if let value = list.first(where: {$0.stringValue("addTime") == dateStr})
            {
                daysValues.append((dateStr, value.intValue("trainingNum") ?? 0))
            }else {
                daysValues.append((dateStr, 0))
            }
            let month = calendar.component(.month, from: tdate)
            let year = calendar.component(.year, from: tdate)
            if cmonth - month == 1 || cyear - year == 1 {
                cmonth = month
                cyear = year
                if totalMonth < 5 {
                    let weekday = calendar
                        .component(.weekday, from: tdate)
                    let month = calendar
                        .component(.month, from: tdate)
                    let num = abs(x) + firstNum
                    let column = num / 7 + 1
                    monthValues.append(
                        (column,
                        getIndexForWeekDay(weekday),
                        month)
                    )
                }
                totalMonth += 1
            }
            x -= 1
        }
        maxValue = abs(x)
    }
    
    /// 通过当天的星期几获取对应的 index
    private func getIndexForWeekDay(_ weekday: Int) -> Int {
        return weekday == 1 ? 0 : 8 - weekday
    }
    
    /// 获取当月第一天是星期几
    private func getTheWeekDayForTheMonthLastDay() -> (Int, Date) {
        let today = Date()
        var acom = DateComponents()
        var x = 0
        var result = (0, Date())
        while x <= 31 {
            x += 1
            acom.day = x
            guard let date = calendar
                .date(byAdding: acom, to: today)
            else {continue}
            if calendar.component(.day, from: date) == 1 {
                x -= 1
                acom.day = x
                if let rdate = calendar
                    .date(byAdding: acom, to: today)
                {
                    result.0 = calendar
                        .component(.weekday, from: rdate)
                    result.1 = rdate
                }
                break
            }
        }
        return result
    }
    
    private func getLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = dzy_Font(10)
        label.sizeToFit()
        scrollView?.addSubview(label)
        return label
    }
    
    private func getView(_ list: ArraySlice<(date: String, num: Int)>) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2.0
        (0...6).forEach { (index) in
            let lindex = list.index(list.startIndex, offsetBy: index)
            var num = CGFloat(list[lindex].num)
            num = min(num, 100)
            let color = num > 0 ?
                RGBA(r: 248, g: 231, b: 28, a: num / 100.0) :
                RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.1)
            let view = UIView()
            view.backgroundColor = color
            stackView.addArrangedSubview(view)
        }
        return stackView
    }
}
