//
//  TPPSetTimeView.swift
//  PPBody
//
//  Created by edz on 2020/6/11.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TPPSetTimeView: UIView, InitFromNibEnable {

    @IBOutlet weak var minPickerView: UIPickerView!
    
    @IBOutlet weak var secondPickerView: UIPickerView!
    
    private var cMinRow: Int = 0
    
    private var cSecondRow: Int = 0
    
    private var minInit = false
    
    private var secondInit = false

    var currentTF: UITextField?
    
    func updateUI(min: Int, second: Int) {
        cMinRow = min
        cSecondRow = second
        minPickerView.selectRow(min, inComponent: 0, animated: false)
        secondPickerView.selectRow(second, inComponent: 0, animated: false)
        if let label = minPickerView.view(forRow: min, forComponent: 0) as? UILabel {
            label.textColor = YellowMainColor
        }
        if let label = secondPickerView.view(forRow: second, forComponent: 0) as? UILabel {
            label.textColor = YellowMainColor
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        currentTF?.text = String(format: "%02ld:%02ld", cMinRow, cSecondRow)
        (superview as? DzyPopView)?.hide()
    }
    
}

extension TPPSetTimeView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == minPickerView ? 100 : 60
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 45.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let label = pickerView
            .view(forRow: row,
                  forComponent: component) as? UILabel
        {
            label.textColor = YellowMainColor
            if pickerView == minPickerView {
                cMinRow = row
            }else {
                cSecondRow = row
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var color = UIColor.white
        if pickerView == minPickerView && !minInit {
            color = YellowMainColor
            minInit = true
        }else if pickerView == secondPickerView && !secondInit {
            color = YellowMainColor
            secondInit = true
        }
        if let label = view as? UILabel {
            label.text = "\(row)"
            label.textColor = color
            return label
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 40))
        label.textColor = color
        label.font = dzy_FontNumber(36)
        label.textAlignment = .center
        label.text = "\(row)"
        return label
    }
}
