//
//  AttPriceProtocol.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

protocol AttPriceProtocol {
    func attPriceStr(_ price: Double,
                     signFont: UIFont,
                     priceFont: UIFont,
                     fontColor: UIColor) -> NSMutableAttributedString
    
    func attPriceStr(_ price: Double,
                     info: String,
                     signFont: UIFont,
                     priceFont: UIFont) -> NSMutableAttributedString
}

extension AttPriceProtocol {
    func attPriceStr(_ price: Double,
                     signFont: UIFont = dzy_Font(10),
                     priceFont: UIFont = dzy_Font(18),
                     fontColor: UIColor = YellowMainColor)
        -> NSMutableAttributedString
    {
        let attStr = NSMutableAttributedString(
            string: "¥" +  price.decimalStr,
            attributes: [
                NSAttributedString.Key.font : priceFont,
                NSAttributedString.Key.foregroundColor : fontColor
        ])
        attStr.addAttributes([
            NSAttributedString.Key.font : signFont,
        ], range: NSRange(location: 0, length: 1))
        return attStr
    }
    
    func attPriceStr(_ price: Double,
                    info: String,
                    signFont: UIFont,
                    priceFont: UIFont) -> NSMutableAttributedString
    {
        let str = "¥" +  price.decimalStr + info
        let attStr = NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedString.Key.font : priceFont,
                NSAttributedString.Key.foregroundColor : YellowMainColor
        ])
        if let temp = str.range(of: price.decimalStr) {
            let range = dzy_toNSRange(temp, str: str)
            attStr.addAttributes([
                NSAttributedString.Key.font : signFont,
            ], range: range)
        }
        return attStr
    }
}
