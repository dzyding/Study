//
//  NaString.swift
//  ZAJA_A_iOS
//
//  Created by Nathan_he on 2017/9/7.
//  Copyright © 2017年 ZHY. All rights reserved.
//

import Foundation

extension String {
    subscript(r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound+1)
            
            return String(self[Range(uncheckedBounds: (startIndex, endIndex))])
        }
    }
    
    subscript(start: Int, end: Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: start)
            let endIndex = self.index(self.startIndex, offsetBy: end+1)
            return String(self[Range(uncheckedBounds: (startIndex, endIndex))])
        }
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func urlScheme(scheme:String) -> URL? {
        if let url = URL.init(string: self) {
            var components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = scheme
            return components?.url
        }
        return nil
    }
    
    static func format(decimal:Float, _ maximumDigits:Int = 1, _ minimumDigits:Int = 1) ->String? {
        let number = NSNumber(value: decimal)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = maximumDigits //设置小数点后最多2位
        numberFormatter.minimumFractionDigits = minimumDigits //设置小数点后最少2位（不足补0）
        return numberFormatter.string(from: number)
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16), let to = range.upperBound.samePosition(in: utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }
    
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
   
}

// MARK:- 通讯录
extension String {
    // 判断是否为字母
    func isAlpha() -> Bool {
        if self == "" {
            return false
        }
        for chr in self {
            let chrStr = chr.description
            if (!(chrStr >= "a" && chrStr <= "z") && !(chrStr >= "A" && chrStr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    // 拼音
    func pinyin() -> String {
        let str = NSMutableString(string: self)
        CFStringTransform(str as CFMutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(str as CFMutableString, nil, kCFStringTransformStripDiacritics, false)
        return str.replacingOccurrences(of: " ", with: "")
    }
}

extension String {
    // MARK:- 获取字符串的CGSize
    func getSize(with font: UIFont) -> CGSize {
        return getSize(width: UIScreen.main.bounds.width, font: font)
    }
    // MARK:- 获取字符串的CGSize(指定宽度)
    func getSize(width: CGFloat, font: UIFont) -> CGSize {
        let str = self as NSString
        
        let size = CGSize(width: width, height: CGFloat(Float.greatestFiniteMagnitude))
        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
}
