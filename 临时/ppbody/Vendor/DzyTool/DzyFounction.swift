//
//  DzyFounction.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation

//MARK: - 最普通的标题，内容，两个选择按钮
public func dzy_normalAlert(_ title: String,
                            msg: String,
                            sureClick:((UIAlertAction) -> Swift.Void)?,
                            cancelClick:((UIAlertAction) -> Swift.Void)?)
    -> UIAlertController
{
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    if #available(iOS 13.0, *) {
        alert.overrideUserInterfaceStyle = .light
    }
    let action1 = UIAlertAction(title: "是", style: .default, handler: sureClick)
    let action2 = UIAlertAction(title: "否", style: .cancel, handler: cancelClick)
    action1.setTextColor(Dzy_MainColor)
    alert.addAction(action2)
    alert.addAction(action1)
    return alert
}

//MARK: - 警告和确认
public func dzy_msgAlert(_ title: String,
                         msg: String,
                         color: UIColor = Dzy_MainColor,
                         handler: (() -> ())? = nil)
    -> UIAlertController
{
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    if #available(iOS 13.0, *) {
        alert.overrideUserInterfaceStyle = .light
    }
    let action = UIAlertAction(title: "是", style: .cancel) { [unowned alert] (action) in
        handler?()
        alert.dismiss(animated: true, completion: nil)
    }
    action.setTextColor(Dzy_MainColor)
    alert.addAction(action)
    return alert
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

public func dzy_toRange(_ range: NSRange, str: String) -> Range<String.Index>? {
    guard let from16 = str.utf16.index(str.utf16.startIndex, offsetBy: range.location, limitedBy: str.utf16.endIndex) else { return nil }
    guard let to16 = str.utf16.index(from16, offsetBy: range.length, limitedBy: str.utf16.endIndex) else { return nil }
    guard let from = String.Index(from16, within: str) else { return nil }
    guard let to = String.Index(to16, within: str) else { return nil }
    return from ..< to
}

//MARK: - 高德经纬度转百度经纬度
public func dzy_gdToBaidu(_ gd: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    let z = sqrt(gd.longitude * gd.longitude + gd.latitude * gd.latitude) + 0.00002 * sqrt(gd.latitude * Double.pi)
    let theta = atan2(gd.latitude, gd.longitude) + 0.000003 * cos(gd.longitude * Double.pi)
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

//MARK: - 图片高度
func dzy_imgHeight(_ name: String,
                   width: CGFloat = dzy_SW) -> CGFloat
{
    guard let size = UIImage(named: name)?.size else {return 0}
    return width / size.width * size.height
}

//MARK: - 处理过时差的时间
public func dzy_date8() -> Date {
    let date = Date()
    let interval = NSTimeZone.system.secondsFromGMT(for: date)
    let now      = date.addingTimeInterval(TimeInterval(interval))
    return now
}

//MARK: - 计算当前星期几
public func dzy_weekNum(_ time: Date) -> Int {
    let calendar = Calendar(identifier: .chinese)
//    if let timeZone = TimeZone(secondsFromGMT: 8 * 3600) {
//        calendar.timeZone = timeZone
//    }
    let num = calendar.component(.weekday, from: time)
    return num
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

//MARK: - 截图
public func viewCopy(_ view:UIView) -> UIImage? {
    // 第二个参数表示是否非透明。如果需要显示半透明效果，需传NO，否则YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(view.frame.size, true, UIScreen.main.scale)
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
