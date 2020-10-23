//
//  DepositHelper.swift
//  YJF
//
//  Created by edz on 2019/7/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

enum DepositType {
    /// 买方看房押金
    case buy_look
    /// 买方交易收支
    case buy_flow
    /// 买方交易保证金
    case buy_deposit
    
    /// 卖方门锁押金
    case sell_lock
    /// 卖方交易收支
    case sell_flow
    /// 卖方交易保证金
    case sell_deposit
    
    private var orange: UIColor {
        return dzy_HexColor(0xFD7E25)
    }
    
    private var green: UIColor {
        return dzy_HexColor(0x26CC85)
    }
    
    func title() -> String {
        switch self {
        case .buy_look:
            return "看房押金"
        case .sell_lock:
            return "门锁押金"
        case .buy_flow, .sell_flow:
            return "交易收支"
        case .buy_deposit, .sell_deposit:
            return "交易保证金"
        }
    }
    
    func detail(_ price: Double, takePrice: Double?) -> NSAttributedString? {
        var sign = "+"
        var color = green
        if price > 0 {
            sign = "+"
            color = green
        }else if price < 0 {
            sign = "-"
            color = orange
        }else {
            sign = ""
            color = green
        }
        switch self {
        case .buy_look:
            let priceStr = sign + price.decimalStr
            let totalStr = "看房押金" + priceStr + "元!"
            return attribute(totalStr, priceStr: priceStr, color: color)
        case .sell_lock:
            let priceStr = sign + price.decimalStr
            let totalStr = "门锁押金" + priceStr + "元!"
            return attribute(totalStr, priceStr: priceStr, color: color)
        case .buy_flow, .sell_flow:
            let priceStr = sign == "-" ?
                price.decimalStr : (sign + price.decimalStr)
            var totalStr = "您当前的交易收支为" + priceStr + "元!"
            if let takePrice = takePrice {
                totalStr += "\n（其中\(takePrice.decimalStr)元处于结算中）"
                return attribute(totalStr, priceStr: priceStr, takepriceStr: takePrice.decimalStr, color: color)
            }else {
                return attribute(totalStr, priceStr: priceStr, color: color)
            }
        case .buy_deposit, .sell_deposit:
            let priceStr = sign + price.decimalStr
            let totalStr = "交易保证金" + priceStr + "元!"
            return attribute(totalStr, priceStr: priceStr, color: color)
        }
    }
    
    private func attribute(_ totalStr: String,
                           priceStr: String,
                           takepriceStr: String? = nil,
                           color: UIColor) -> NSAttributedString
    {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8.0
        
        let attStr = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font : dzy_Font(14),
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0x646464),
            NSAttributedString.Key.paragraphStyle : style
            ])
        
        if let range = totalStr.range(of: priceStr) {
            let nsrange = dzy_toNSRange(range, str: totalStr)
            attStr.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color, range: nsrange)
        }
        if let takepriceStr = takepriceStr,
            let range = totalStr.range(of: takepriceStr, options: .backwards) {
            let nsrange = dzy_toNSRange(range, str: totalStr)
            attStr.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color, range: nsrange)
        }
        return attStr
    }
}

enum DepositFunType: Int {
    /// 退看房押金
    case reLook = 1
    /// 退买方交易保证金
    case reBuyDeposit
    /// 盈余结算
    case reBuyFlow
    /// 补缴
    case payBuyFlow
    
    /// 退门锁押金
    case reLock
    /// 退卖方交易保证金
    case reSellDeposit
    /// 盈余结算
    case reSellFlow
    /// 补缴
    case paySellFlow
}
