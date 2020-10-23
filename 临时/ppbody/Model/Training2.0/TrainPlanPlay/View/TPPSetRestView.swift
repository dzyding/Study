//
//  TPPSetRestView.swift
//  PPBody
//
//  Created by edz on 2020/1/15.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

protocol TPPSetRestViewDelegate: class {
    func restView(_ restView: TPPSetRestView,
                  didSetTime time: Int,
                  isAll: Bool)
}

class TPPSetRestView: UIView, InitFromNibEnable {
    
    weak var delegate: TPPSetRestViewDelegate?

    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var mMsgLB: UILabel!
    @IBOutlet weak var mMinLB: UILabel!
    @IBOutlet weak var mSecondLB: UILabel!
    
    
    @IBOutlet weak var minPicker: UIPickerView!
    
    @IBOutlet weak var secondPicker: UIPickerView!
    
    @IBOutlet weak var switchBtn: UISwitch!
    
    private var cMinRow: Int = 0
    
    private var cSecondRow: Int = 0
    
    private var minInit = false
    
    private var secondInit = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [mTitleLB, mMinLB, mSecondLB].forEach { (label) in
            label?.font = dzy_FontBlod(15)
        }
        mMsgLB.font = dzy_FontBlod(12)
        minPicker.selectRow(0, inComponent: 0, animated: true)
        secondPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
        delegate?.restView(self,
                           didSetTime: cMinRow * 60 + cSecondRow,
                           isAll: switchBtn.isOn)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
    }
}

extension TPPSetRestView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == minPicker ? 10 : 60
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
            if pickerView == minPicker {
                cMinRow = row
            }else {
                cSecondRow = row
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var color = UIColor.white
        if pickerView == minPicker && !minInit {
            color = YellowMainColor
            minInit = true
        }else if pickerView == secondPicker && !secondInit {
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
        label.font = dzy_FontBBlod(36)
        label.textAlignment = .center
        label.text = "\(row)"
        return label
    }
}
