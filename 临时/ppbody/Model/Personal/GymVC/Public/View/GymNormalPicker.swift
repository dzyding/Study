//
//  GymNormalPicker.swift
//  PPBody
//
//  Created by edz on 2019/5/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol GymNormalPickerDelegate {
    func normalPicker(_ picker: GymNormalPicker, didSelectString str: String)
}

class GymNormalPicker: UIView {
    
    weak var delegate: GymNormalPickerDelegate?

    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet private weak var pickView: UIPickerView!
    
    private var datas:[String] = []
    
    private var currentStr: String = ""
    
    func setTitle(_ title: String) {
        titleLB.text = title
    }
    
    func updateUI(_ datas:[String]) {
        self.datas = datas
        pickView.reloadAllComponents()
        pickView.selectRow(0, inComponent: 0, animated: false)
        currentStr = datas.first ?? ""
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        if let sView = superview as? DzyPopView {
            sView.hide()
        }
        delegate?.normalPicker(self, didSelectString: currentStr)
    }
    
}

extension GymNormalPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let str = datas[row]
        if let view = view {
            if let label = view.viewWithTag(1) as? UILabel {
                label.text = str
            }
            return view
        }else {
            let new = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.size.width, height: 30))
            new.backgroundColor = .clear
            let label = UILabel(frame: new.bounds)
            label.text = str
            label.tag = 1
            label.textColor = .white
            label.textAlignment = .center
            label.font = ToolClass.CustomBoldFont(18)
            new.addSubview(label)
            return new
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentStr = datas[row]
    }
}
