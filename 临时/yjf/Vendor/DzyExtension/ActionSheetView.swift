//
//  ActionSheetView.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol ActionSheetViewDelegate {
    func sheetView(_ sheetView: ActionSheetView, didSelectString str: String)
    func sheetView(_ sheetView: ActionSheetView, didClickCancelBtn btn: UIButton)
}

class ActionSheetView: UIView {
    
    weak var delegate: ActionSheetViewDelegate?
    
    private var rowHeight: CGFloat = 45.0
    
    private var datas: [String] = []
    
    private weak var pickerView: UIPickerView?
    
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
        
        let pickerView = UIPickerView(frame: bounds)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = false
        addSubview(pickerView)
        self.pickerView = pickerView
        
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
    
    func checkEmpty() -> Bool {
        return datas.isEmpty
    }
    
    func updateUI(_ datas: [String]) {
        self.datas = datas
        var height = rowHeight * 5.0
        height = IS_IPHONEX ? height + 34.0 : height
        var temp = frame
        temp.size.height = height
        frame = temp
        pickerView?.reloadAllComponents()
        if datas.count > 0 {
            pickerView?.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @objc private func sureAction() {
        let row = pickerView?.selectedRow(inComponent: 0) ?? 0
        delegate?.sheetView(self, didSelectString: datas[row])
    }
    
    @objc private func cancelAction(_ btn: UIButton) {
        delegate?.sheetView(self, didClickCancelBtn: btn)
        if let spView = superview as? DzyPopView {
            spView.hide()
        }
    }
}

extension ActionSheetView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        if let reuingView = view as? ActionSheetCell {
            reuingView.label?.text = datas[row]
            return reuingView
        }else {
            let view = ActionSheetCell(frame: CGRect(
                x: 0,
                y: 0,
                width: ScreenWidth,
                height: rowHeight)
            )
            view.label?.text = datas[row]
            return view
        }
    }
}
