//
//  DzyButton+Extension.swift
//  HousingMarket
//
//  Created by dzy_PC on 2018/11/27.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

extension UIButton {
    // 添加下划线属性
    func addUnderLineStyle() {
        if let text = attributedTitle(for: .normal) {
            let temp = NSMutableAttributedString(attributedString: text)
            temp.addAttributes([
                .underlineStyle : NSUnderlineStyle.single.rawValue
                ], range: NSRange(location: 0, length: temp.length))
            setAttributedTitle(temp, for: .normal)
        }else if let text = title(for: .normal) ,
            let font = titleLabel?.font,
            let fontColor = titleColor(for: .normal)
            {
            let temp = NSMutableAttributedString(string: text)
            temp.addAttributes([
                .underlineStyle : NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : fontColor
                ], range: NSRange(location: 0, length: temp.length))
            setAttributedTitle(temp, for: .normal)
        }
    }
    
    // 设置下划线属性
    func setUnderLine(_ text: String) {
        let temp = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
            ])
        setAttributedTitle(temp, for: .normal)
    }
}
