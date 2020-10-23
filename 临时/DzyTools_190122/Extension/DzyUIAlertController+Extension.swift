//
//  DzyUIAlertController+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

extension UIAlertAction {
    func setTextColor(_ color: UIColor) {
        if #available(iOS 9.0, *) {
            self.setValue(color, forKey: "titleTextColor")
        }
    }
}

extension UIAlertController {
    func setTitleColor(_ color: UIColor, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.foregroundColor : color
            ])
        setValue(attStr, forKey: "attributedTitle")
    }
    
    func setTitleFont(_ font: UIFont, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.font : font
            ])
        setValue(attStr, forKey: "attributedTitle")
    }
    
    func setTitleColor(_ color: UIColor, font: UIFont, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.font            : font,
            NSAttributedStringKey.foregroundColor : color
            ])
        setValue(attStr, forKey: "attributedTitle")
    }
    
    func setMsgColor(_ color: UIColor, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.foregroundColor : color
            ])
        setValue(attStr, forKey: "attributedMessage")
    }
    
    func setMsgFont(_ font: UIFont, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.font : font
            ])
        setValue(attStr, forKey: "attributedMessage")
    }
    
    func setMsgColor(_ color: UIColor, font: UIFont, str: String) {
        let attStr = NSAttributedString(string: str, attributes: [
            NSAttributedStringKey.font            : font,
            NSAttributedStringKey.foregroundColor : color
            ])
        setValue(attStr, forKey: "attributedMessage")
    }
}
