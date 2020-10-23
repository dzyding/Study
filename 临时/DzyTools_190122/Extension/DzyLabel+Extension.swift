//
//  DzyLabel+Extension.swift
//  HousingMarket
//
//  Created by edz on 2018/11/28.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

extension UILabel {
    // 添加下划线属性
    func addUnderLineStyle() {
        if let text = attributedText {
            let temp = NSMutableAttributedString(attributedString: text)
            temp.addAttributes([
                .underlineStyle : NSUnderlineStyle.single.rawValue
                ], range: NSRange(location: 0, length: temp.length))
            attributedText = temp
        }else if let text = text ,
            let font = font,
            let fontColor = textColor
        {
            let temp = NSMutableAttributedString(string: text)
            temp.addAttributes([
                .underlineStyle : NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : fontColor
                ], range: NSRange(location: 0, length: temp.length))
            attributedText = temp
        }
    }
    
    // 设置下划线属性
    func setUnderLine(_ text: String) {
        let temp = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
            ])
        attributedText = temp
    }
}
