//
//  PtReservePickerView.swift
//  PPBody
//
//  Created by edz on 2019/4/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol PtReservePickerViewDelegate {
    func picker(_ picker: PtReservePickerView, didSelectSureBtn btn: UIButton)
}

class PtReservePickerView: UIView {
    
    @IBOutlet weak var hourPicker: UIPickerView!
    
    @IBOutlet weak var minPicker: UIPickerView!
    
    fileprivate var hours: [String] = []
    
    fileprivate var mins: [String] = []
    
    var hour: String = ""
    
    var min: String = ""
    
    weak var delegate: PtReservePickerViewDelegate?
    
    var datas: [String : [String]] = [:]

    func setUI(_ datas: [String : [String]]) {
        self.datas = datas
        hours = datas.keys.sorted()
        let firstHour = hours.first ?? ""
        mins = datas[firstHour]?.sorted() ?? []
        hourPicker.reloadAllComponents()
        minPicker.reloadAllComponents()
        hourPicker.selectRow(0, inComponent: 0, animated: false)
        minPicker.selectRow(0, inComponent: 0, animated: false)
        self.hour = firstHour
        self.min = mins.first ?? ""
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
            delegate?.picker(self, didSelectSureBtn: sender)
        }
    }
}

extension PtReservePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hourPicker {
            return hours.count
        }else {
            return mins.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let arr = pickerView == hourPicker ? hours : mins
        if let view = view {
            if let label = view.viewWithTag(1) as? UILabel {
                label.text = arr[row]
            }
            return view
        }else {
            let new = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.size.width, height: 30))
            new.backgroundColor = .clear
            let label = UILabel(frame: new.bounds)
            label.text = arr[row]
            label.tag = 1
            label.textColor = .white
            label.textAlignment = .center
            label.font = ToolClass.CustomBoldFont(18)
            new.addSubview(label)
            return new
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hourPicker {
            hour = hours[row]
            mins = datas[hour]?.sorted() ?? []
            minPicker.reloadAllComponents()
            minPicker.selectRow(0, inComponent: 0, animated: false)
            min = mins.first ?? ""
        }else {
            min = mins[row]
        }
    }
}
