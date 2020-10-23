//
//  LBInputView.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol LBInputViewDelegate {
    func lbInputView(_ inputView: LBInputView, didSelctedBtn btn: UIButton)
}

/// 不可点击选择的输入框
class LBInputView: UIView, HouseInfoInput {
    
    weak var delegate: LBInputViewDelegate?
    
    private weak var label: UILabel?
    
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
        delegate?.lbInputView(self, didSelctedBtn: sender)
    }
    
    private func setUI() {
        let label = UILabel()
        label.font = dzy_Font(14)
        label.textColor = dzy_HexColor(0xA3A3A3)
        addSubview(label)
        self.label = label
        
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
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(0)
            make.right.equalTo(-10)
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
        label?.text = text
        btn?.isSelected = false
    }
    
    func getText() -> String {
        return label?.text ?? ""
    }
    
    func closeAcion() {
        btn?.isSelected = false
    }
}
