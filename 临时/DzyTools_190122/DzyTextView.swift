//
//  DzyTextView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/9/22.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

class DzyTextView: UIView {
    
    var placeholder: String
    
    weak var textField: UITextField?
    
    weak var textView: UITextView?
    
    init(_ placeholder: String, frame: CGRect) {
        self.placeholder = placeholder
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func initSubViews() {
        let textView = UITextView()
        textView.layer.cornerRadius = 3
        textView.layer.borderColor = RGB(r: 212.0, g: 212.0, b: 212.0).cgColor
        textView.layer.borderWidth = 1
        textView.returnKeyType = .done
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.font = dzy_Font(14)
        addSubview(textView)
        self.textView = textView
        
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = dzy_Font(14)
        textField.isUserInteractionEnabled = false
        addSubview(textField)
        self.textField = textField
        
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(UI_H(6))
            make.right.equalTo(0)
            make.left.equalTo(10)
            make.height.equalTo(UI_H(20))
        }
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
    func getTextField() -> UITextField {
        return textField!
    }
}
