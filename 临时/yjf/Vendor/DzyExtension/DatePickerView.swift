//
//  DatePickerView.swift
//  YJF
//
//  Created by edz on 2019/5/31.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol DatePickerViewDelegate {
    func datePicker(_ datePicker: DatePickerView, didSelectDateString str: String)
    func datePicker(_ datePicker: DatePickerView, didClickCancelBtn btn: UIButton)
}

class DatePickerView: UIView {
    
    weak var delegate: DatePickerViewDelegate?
    
    private weak var picker: UIDatePicker?
    
    private var rowHeight: CGFloat = 45.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //swift:disable:next function_body_length
    private func setUI() {
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(Font_Dark, for: .normal)
        cancelBtn.titleLabel?.font = dzy_Font(15)
        cancelBtn.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        addSubview(cancelBtn)
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(MainColor, for: .normal)
        sureBtn.titleLabel?.font = dzy_Font(15)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        addSubview(sureBtn)
        
        let pickerView = UIDatePicker(frame: bounds)
        pickerView.datePickerMode = .date
        pickerView.locale = Locale(identifier: "zh_CN")
        addSubview(pickerView)
        self.picker = pickerView
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowHeight)
        }
        
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(0)
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowHeight)
        }
        
        let bottom: CGFloat = IS_IPHONEX ? -34.0 : 0
        pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(rowHeight)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottom)
        }
    }
    
    @objc private func sureAction() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = picker?.date {
            let str = formatter.string(from: date)
            delegate?.datePicker(self, didSelectDateString: str)
        }
    }
    
    @objc private func cancelAction(_ btn: UIButton) {
        delegate?.datePicker(self, didClickCancelBtn: btn)
        if let spView = superview as? DzyPopView {
            spView.hide()
        }
    }
}
