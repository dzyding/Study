//
//  SmartQaServiceCell.swift
//  YJF
//
//  Created by edz on 2019/8/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SmartQaServiceCell: UITableViewCell {

    @IBOutlet weak var textLB: UILabel!

    func updateUI(_ str: String?) {
        if let str = str {
            //            请点击这里
            let attStr = NSMutableAttributedString(string: str, attributes: [
                NSAttributedString.Key.font : dzy_Font(14),
                NSAttributedString.Key.foregroundColor : Font_Dark
                ])
            
            if let range = str.range(of: "请点击这里") {
                attStr.addAttribute(
                    NSAttributedString.Key.foregroundColor,
                    value: MainColor,
                    range: dzy_toNSRange(range, str: str)
                )
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = defaultLineSpace
            attStr.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: style,
                range: NSRange(location: 0, length: str.count)
            )
            textLB.attributedText = attStr
        }else {
            textLB.text = nil
        }
    }
}
