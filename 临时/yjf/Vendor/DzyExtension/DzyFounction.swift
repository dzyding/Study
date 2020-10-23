//
//  DzyFounction.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation
import UIKit

public func dzy_safe(_ dic: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
    guard let dic = dic else {return nil}
    var keys: [AnyHashable] = []
    var temp = dic
    temp.keys.forEach { (key) in
        if temp[key] is NSNull {
            keys.append(key)
        }
        if let value = dic[key] as? [AnyHashable : Any], //字典
            let result = dzy_safe(value)
        {
            temp.updateValue(result, forKey: key)
        }else if let value = dic[key] as? [Any] { //数组
            var tempArr = value
            value.enumerated().forEach({ (index, x) in
                if x is NSNull {
                    tempArr.remove(at: index)
                }else if let tdic = x as? [AnyHashable : Any],
                    let result = dzy_safe(tdic)
                {
                    tempArr[index] = result
                }
            })
        }
    }
    (0..<keys.count).forEach({ (index) in
        temp.removeValue(forKey: keys[index])
    })
    return temp
}

//MARK: - 最普通的标题，内容，两个选择按钮
public func dzy_normalAlert(_ title: String, msg: String,
                            sureClick:((UIAlertAction) -> Swift.Void)?,
                            cancelClick:((UIAlertAction) -> Swift.Void)?) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action1 = UIAlertAction(title: "是", style: .default, handler: sureClick)
    let action2 = UIAlertAction(title: "否", style: .cancel, handler: cancelClick)
    action1.setTextColor(MainColor)
    alert.addAction(action2)
    alert.addAction(action1)
    return alert
}

//MARK: - 警告和确认
public func dzy_msgAlert(_ title: String, msg: String, handler: (() -> ())? = nil) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "是", style: .cancel) { [unowned alert] (_) in
        handler?()
        alert.dismiss(animated: true, completion: nil)
    }
    alert.addAction(action)
    return alert
}

public func dzy_phoneMsg() -> String {
    //swiftlint:disable:next cyclomatic_complexity
    func getPhone() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        if platform == "iPhone5,1" { return "iPhone5"}
        if platform == "iPhone5,2" { return "iPhone5"}
        if platform == "iPhone5,3" { return "iPhone5C"}
        if platform == "iPhone5,4" { return "iPhone5C"}
        if platform == "iPhone6,1" { return "iPhone5S"}
        if platform == "iPhone6,2" { return "iPhone5S"}
        if platform == "iPhone7,1" { return "iPhone6P"}
        if platform == "iPhone7,2" { return "iPhone6"}
        if platform == "iPhone8,1" { return "iPhone6S"}
        if platform == "iPhone8,2" { return "iPhone6SP"}
        if platform == "iPhone8,4" { return "iPhoneSE"}
        if platform == "iPhone9,1" { return "iPhone7"}
        if platform == "iPhone9,3" { return "iPhone7"}
        if platform == "iPhone9,2" { return "iPhone7P"}
        if platform == "iPhone9,4" { return "iPhone7P"}
        if platform == "iPhone10,1" { return "iPhone8"}
        if platform == "iPhone10,4" { return "iPhone8"}
        if platform == "iPhone10,2" { return "iPhone8P"}
        if platform == "iPhone10,5" { return "iPhone8P"}
        if platform == "iPhone10,3" { return "iPhoneX"}
        if platform == "iPhone10,6" { return "iPhoneX"}
        if platform == "iPhone11,8" { return "iPhoneXR"}
        if platform == "iPhone11,2" { return "iPhoneXS"}
        if platform == "iPhone11,6" { return "iPhoneXSM"}
        if platform == "iPhone11,4" { return "iPhoneXSM"}
        if platform == "iPhone12,1" { return "iPhone11"}
        if platform == "iPhone12,3" { return "iPhone11P"}
        if platform == "iPhone12,5" { return "iPhone11PM"}
        
        if platform == "i386"   { return "iPhoneSimulator"}
        if platform == "x86_64" { return "iPhoneSimulator"}
        
        return platform
    }
    let device = UIDevice.current
    let name = device.name
    // 手机
    let phone = getPhone()
    var result = name + "_" + phone
    // 相同的一个程序里面-相同的vindor-相同的设备 (相同的 vindor 代表着 BundleId 前两部分相同)
    if let identify = device.identifierForVendor?.uuidString {
        result += ("_" + identify)
    }
    return result
}

//MARK: - 高德经纬度转百度经纬度
public func dzy_gdToBaidu(_ gd: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    let pi = 3.14159265358979324 * 3000.0 / 180.0
    let x = gd.longitude
    let y = gd.latitude
    let z = sqrt(x * x + y * y) + 0.00002 * sin(y * pi)
    let theta = atan2(y, x) + 0.000003 * cos(x * pi)
    let result = CLLocationCoordinate2D(
        latitude: z * sin(theta) + 0.006,
        longitude: z * cos(theta) + 0.0065)
    return result
}

//MARK: - TimeSign
public func dzy_TimeSign() -> Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000.0)
}

//MARK: - 通过路径加载图片
public func dzy_imgPath(_ name: String) -> String {
    if let path = Bundle.main.resourcePath?.appending("/" + name) {
        return path
    }else {
        return ""
    }
}

//MARK: - 处理过时差的时间
public func dzy_date8() -> Date {
    let date = Date()
    let interval = NSTimeZone.system.secondsFromGMT(for: date)
    let now      = date.addingTimeInterval(TimeInterval(interval))
    return now
}

//MARK: - String 的range 转到 NSRange
public func dzy_toNSRange(_ range: Range<String.Index>, str: String) -> NSRange {
    if let from = range.lowerBound.samePosition(in: str.utf16),
        let to = range.upperBound.samePosition(in: str.utf16)
    {
        let nsrange = NSRange(
            location: str.utf16.distance(
                from: str.utf16.startIndex, to: from
            ),
            length: str.utf16.distance(from: from, to: to))
        return nsrange
    }else {
        return NSRange(location: 0, length: 0)
    }
}

//MARK: - 生成二维码
public func dzy_QrCode(_ string: String, size: CGFloat) -> UIImage? {
    // 1.创建过滤器
    let filter = CIFilter(name: "CIQRCodeGenerator")
    //2.恢复默认
    filter?.setDefaults()
    //3.给过滤器添加参数
    let data = string.data(using: .utf8)
    filter?.setValue(data, forKeyPath: "inputMessage")
    //4.获取生成的二维码
    if let outImg = filter?.outputImage {
        //5.将CIImage转换为image
        let width = outImg.extent.integral.size.width
        let img = UIImage(ciImage: outImg.transformed(by: CGAffineTransform(scaleX: size / width, y: size / width)))
        return img
    }else {
        return nil
    }
}

//MARK: - 生成单色图片
public func singleColorImg(_ size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContext(size)
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.setFillColor(MainColor.cgColor)
    ctx?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}

//MARK: - 截图
public func viewCopy(_ view:UIView) -> UIImage? {
    // 第二个参数表示是否非透明。如果需要显示半透明效果，需传NO，否则YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage?
    UIGraphicsEndImageContext()
    return image
}

//MARK: - 获取一个类的所有属性名
public func getIvarList(_ anyClass: AnyClass) {
    var count: UInt32 = 0
    let ivars = class_copyIvarList(anyClass, &count)
    if let ivars = ivars {
        for i in 0..<Int(count) {
            let ivar = ivars[i]
            if let cName = ivar_getName(ivar) {
                let ocName = String(cString: cName)
                print(ocName)
            }
        }
        free(ivars)
    }
}
