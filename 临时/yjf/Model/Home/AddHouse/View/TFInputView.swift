//
//  TFInputView.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol TFInputViewDelegate {
    func tfInputView(_ inputView: TFInputView, didSelectBtn btn: UIButton)
    func tfInputView(_ inputView: TFInputView, didEndEditing textField: UITextField)
}

/// 可点击选择的输入框
class TFInputView: UIView, HouseInfoInput {
    
    weak var delegate: TFInputViewDelegate?
    
    private weak var textField: UITextField?
    
    private weak var btn: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    @objc private func openAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.tfInputView(self, didSelectBtn: sender)
    }
    
    private func setUI() {
        let textField = UITextField()
        textField.font = dzy_Font(14)
        textField.textColor = dzy_HexColor(0xA3A3A3)
        textField.delegate = self
        addSubview(textField)
        self.textField = textField
        
        let line = UIView()
        line.backgroundColor = dzy_HexColor(0xE5E5E5)
        addSubview(line)
        
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "watch_down"), for: .normal)
        btn.setImage(UIImage(named: "watch_up"), for: .selected)
        btn.addTarget(self, action: #selector(openAction(_:)), for: .touchUpInside)
        btn.contentHorizontalAlignment = .right
        addSubview(btn)
        self.btn = btn
        
        textField.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.right.equalTo(0)
            make.height.equalTo(35)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1)
        }
        
        btn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(self)
            make.right.equalTo(0)
        }
    }
    
    //    MARK: - HouseInfoInput
    func setText(_ text: String?) {
        textField?.text = text
        btn?.isSelected = false
    }
    
    func getText() -> String {
        return textField?.text ?? ""
    }
    
    func closeAcion() {
        btn?.isSelected = false
    }
}

extension TFInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.tfInputView(self, didEndEditing: textField)
    }
}
