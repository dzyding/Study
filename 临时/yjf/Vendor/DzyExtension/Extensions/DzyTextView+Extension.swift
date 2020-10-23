//
//  DzyTextView+Extension.swift
//  ZHYQ-FsZc
//
//  Created by edz on 2019/2/18.
//  Copyright © 2019 dzy. All rights reserved.
//

import Foundation

extension UITextView {
    func addInputView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = UIColor(red: 187.0/255.0, green: 194.0/255.0, blue: 201.0/255.0, alpha: 1)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth - 80, y: 5, width: 70, height: 30)
        btn.backgroundColor = .clear
        btn.setTitleColor(MainColor, for: .normal)
        btn.titleLabel?.font = dzy_Font(14)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = MainColor.cgColor
        btn.layer.cornerRadius = 3
        btn.setTitle("确定", for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        view.addSubview(btn)
        
        inputAccessoryView = view
    }
    
    @objc func btnClick() {
        resignFirstResponder()
    }
}
