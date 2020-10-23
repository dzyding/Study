//
//  DzyTextField+Extension.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        if let placeholder = placeholder,
            let font = font
        {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : color
                ])
        }else if let attPlaceholder = attributedPlaceholder {
            let temp = NSMutableAttributedString(attributedString: attPlaceholder)
            temp.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: color,
                              range: NSRange(location: 0, length: attPlaceholder.length))
        }
    }
    
    /// 默认判断小数
    func checkIsOnlyNumber(_ decimal: Bool = true) {
        if var text = text,
            text.count > 0
        {
            var count = 0
            let arr = (0..<10)
                .reduce(decimal ? [Character(".")] : [Character]())
            { (temp: [Character], value: Int) -> [Character] in
                return temp + [Character("\(value)")]
            }
            while count < text.count {
                let index = text.index(text.startIndex, offsetBy: count)
                if !arr.contains(text[index]) {
                    text.remove(at: index)
                }else {
                    count += 1
                }
            }
            self.text = text
        }
    }
}
