//
//  DzyAttributeString.swift
//  YJF
//
//  Created by edz on 2019/5/15.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

public let defaultLineSpace: CGFloat = 4.0

struct DzyAttributeString { //这里应该改个名，叫 LineSpace
    
    var str: String = ""
    
    var color: UIColor = .white
    
    var font: UIFont = dzy_Font(14)
    
    var lineSpace: CGFloat?
    
    var innerSpace: CGFloat?
    
    func create() -> NSMutableAttributedString {
        let attStr = NSMutableAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : color
            ])
        
        if let lineSpace = lineSpace {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpace
            attStr.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: style,
                range: NSRange(location: 0, length: str.count)
            )
        }
        if let innerSpace = innerSpace {
            attStr.addAttribute(
                NSAttributedString.Key.kern,
                value: innerSpace,
                range: NSRange(location: 0, length: str.count)
            )
        }
        return attStr
    }
}
