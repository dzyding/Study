//
//  StringExtension.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/24.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import Foundation
import UIKit

extension String {
     // 判断是否为字母
     func isAlpha() -> Bool {
          if self == "" {
               return false
          }
          for chr in self {
               let chrStr = chr.description
               if !(chrStr >= "a" && chrStr <= "z") && !(chrStr >= "A" && chrStr <= "Z")
               {
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
     
     //颜色字符串
     func getColorString(byoriginalstring str: String,
                         desireStr: String,
                         color: UIColor) -> NSAttributedString?
     {
          let location = (str as NSString).range(of: desireStr).location
          if location == NSNotFound{
               return nil
          }else{
               let attributeStr = NSMutableAttributedString(string: str)
               attributeStr.addAttributes([NSAttributedString.Key.foregroundColor:color],
                                          range: NSRange(location: location, length: desireStr.count))
               return attributeStr
          }
     }
    
     //带颜色和下划线的字符串
     func getColorStringWithUnderline(byoriginalstring str: String,
                                      desireStr: String,
                                      color: UIColor,
                                      underlineColor: UIColor) -> NSAttributedString?
     {
          let location = (str as NSString).range(of: desireStr).location
          if location == NSNotFound{
               return nil
          }else{
               let attributeStr = NSMutableAttributedString(string: str)
               attributeStr.addAttributes([NSAttributedString.Key.foregroundColor:color,
                                           NSAttributedString.Key.underlineColor:underlineColor,
                                           NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue],
                                          range: NSRange(location: location, length: desireStr.count))
               
               return attributeStr
          }
     }
}
