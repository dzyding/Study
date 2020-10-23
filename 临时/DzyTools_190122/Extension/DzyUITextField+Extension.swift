//
//  DzyUITextField+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

extension UITextField {
    func dzy_AccessoryView() -> UIButton {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_W, height: 40))
        view.backgroundColor = UIColor(red: 187.0/255.0, green: 194.0/255.0, blue: 201.0/255.0, alpha: 1)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: Screen_W - 80, y: 5, width: 70, height: 30)
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(Dzy_MainColor, for: UIControlState())
        btn.titleLabel?.font = dzy_FontBlod(14)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = Dzy_MainColor.cgColor
        btn.layer.cornerRadius = 3
        btn.setTitle("确定", for: UIControlState())
        view.addSubview(btn)
        
        inputAccessoryView = view
        return btn
    }
}
