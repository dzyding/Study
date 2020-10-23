//
//  DzyPublic.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation
import UIKit

public func RGBA(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/1.0)
}

public func RGB(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor{
    return RGBA(r: r, g: g, b: b, a: 1)
}

func dzy_HexColor(_ hex: Int) -> (UIColor) {
    //一个表示UIColor的16进制 必然是24位。 8位表示一个色值。 这里跟系统用多大的地方储存UIColor没关系
    return UIColor(red: (CGFloat((hex & 0xFF0000) >> 16)) / 255.0,
                   green: (CGFloat((hex & 0xFF00) >> 8)) / 255.0,
                   blue: (CGFloat(hex & 0xFF)) / 255.0,
                   alpha: 1.0)
}

public var Dzy_MainColor: UIColor {
    return BackgroundColor
}

public let KEY_WINDOW = UIApplication.shared.keyWindow

public let dzy_SB = CGRect(x: 0, y: 0, width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))

public let dzy_SH = max(dzy_SB.width,dzy_SB.height)

public let dzy_SW = min(dzy_SB.width,dzy_SB.height)

// 通用的选中状态 key
public let SelectedKey = "selected"

//顶部导航高度
public var NaviH: CGFloat {
    if dzy_SH == 812 || dzy_SH == 896 {
        return 88
    }else {
        return 64
    }
}

//tab导航的高度
public var TabH: CGFloat {
    if dzy_SH == 812 || dzy_SH == 896 {
        return 83
    }else {
        return 49
    }
}

//底部半角矩形的高
public var TabRH: CGFloat {
    if dzy_SH == 812 || dzy_SH == 896 {
        return 34
    }else {
        return 0
    }
}

//是否为x
public var dzy_ifX: Bool {
    if dzy_SH == 812 || dzy_SH == 896 {
        return true
    }else {
        return false
    }
}

//宽度适配
public func UI_W(_ width: CGFloat) -> CGFloat {
    return dzy_SW / 375.0 * width
}

//高度适配
public func UI_H(_ height: CGFloat) -> CGFloat {
    return dzy_SH / 667.0 * height
}

///字体适配
public func dzy_Font(_ size:CGFloat) -> UIFont {
    return ToolClass.CustomFont(UI_W(size))
}

///加粗字体适配
public func dzy_FontBlod(_ size:CGFloat) -> UIFont {
    return UIFont(name: "PingFangSC-Regular", size: UI_W(size)) ?? UIFont.systemFont(ofSize: size)
}

///二级粗字体适配
public func dzy_FontBBlod(_ size:CGFloat) -> UIFont {
    return ToolClass.CustomBoldFont(UI_W(size))
}

public func dzy_FontNumber(_ size: CGFloat) -> UIFont {
    return UIFont(name: "^cw\\EO`W^", size: UI_W(size)) ??
        UIFont.systemFont(ofSize: size)
}

public func dzy_strSize(str:String, font:UIFont, width:CGFloat = dzy_SW) -> CGSize {
    return NSString(string: str).boundingRect(
        with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
        options:[.usesFontLeading,.usesLineFragmentOrigin] ,
        attributes: [NSAttributedString.Key.font : font],
        context: nil).size
}

public func dzy_rect(x: CGFloat = 0 , y: CGFloat = 0, width: CGFloat, height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

public func dzy_log<T>(_ msg: T, file: String = #file, line:Int = #line) {
    #if DEBUG
        guard let fileName:String = file.components(separatedBy: "/").last else {
            print("文件位置错误")
            return
        }
        print("[\(fileName)_line:\(line)]- \(msg)")
    #endif
}
