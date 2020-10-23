//
//  CoachReduceTimePicker.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol CoachReduceTimePickerDelegate {
    func picker(_ picker: CoachReduceTimePicker, didSelectTime start: Int, end: Int)
}

class CoachReduceTimePicker: UIView {
    
    weak var delegate: CoachReduceTimePickerDelegate?

    @IBOutlet private weak var startPicker: UIPickerView!
    
    @IBOutlet private weak var endPicker: UIPickerView!
    /// 所有可用的时间
    private var canUseTimes: [[Int]] = []
    /// 开始时间集合
    private var startTimes: [Int] = []
    /// 结束时间集合
    private var endTimes: [Int] = []
    /// 当前开始时间
    private var sTime: Int = 0
    /// 当前结束时间
    private var eTime: Int = 0
    
    func updateUI(_ canUseTimes: [[Int]]) {
        if canUseTimes.isEmpty {
            startTimes = []
            endTimes = []
            startPicker.reloadAllComponents()
            endPicker.reloadAllComponents()
            return
        }
        self.canUseTimes = canUseTimes
        updateEndTimes(canUseTimes[0][0])
        setStartTimes()
        sTime = startTimes[0]
        eTime = endTimes[0]
        startPicker.reloadAllComponents()
        endPicker.reloadAllComponents()
        startPicker.selectRow(0, inComponent: 0, animated: false)
        endPicker.selectRow(0, inComponent: 0, animated: false)
    }
    
    @IBAction func cancelAciton(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
        }
        delegate?.picker(self, didSelectTime: sTime, end: eTime)
    }
    
    //    MARK: - 设置开始时间数组
    private func setStartTimes() {
        startTimes = []
        canUseTimes.forEach { (timeArr) in
            var temp = timeArr
            temp.removeLast()
            startTimes.append(contentsOf: temp)
        }
    }
    
    //    MARK: - 更新结束时间数组
    private func updateEndTimes(_ selectTime: Int) {
        endTimes = []
        if let index = canUseTimes.firstIndex(where: {$0.contains(selectTime) && $0.last != selectTime}) {
            let tempArr = canUseTimes[index]
            tempArr.forEach { (time) in
                if time > selectTime {
                    endTimes.append(time)
                }
            }
        }
    }
    
    //    MARK: - 刷新结束时间
    private func updateEndPicker() {
        updateEndTimes(sTime)
        eTime = endTimes[0]
        endPicker.reloadAllComponents()
        endPicker.selectRow(0, inComponent: 0, animated: false)
    }
}

extension CoachReduceTimePicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == startPicker ? startTimes.count : endTimes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let arr = pickerView == startPicker ? startTimes : endTimes
        let timeStr = ToolClass.getTimeStr(arr[row])
        if let view = view {
            if let label = view.viewWithTag(1) as? UILabel {
                label.text = timeStr
            }
            return view
        }else {
            let new = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.size.width, height: 30))
            new.backgroundColor = .clear
            let label = UILabel(frame: new.bounds)
            label.text = timeStr
            label.tag = 1
            label.textColor = .white
            label.textAlignment = .center
            label.font = ToolClass.CustomBoldFont(18)
            new.addSubview(label)
            return new
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == startPicker {
            sTime = startTimes[row]
            updateEndPicker()
        }else {
            eTime = endTimes[row]
        }
    }
}
