//
//  DzyFounction.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation

//MARK: - 最普通的标题，内容，两个选择按钮
public func dzy_normalAlert(_ title: String, msg: String,
                            sureClick:((UIAlertAction) -> Swift.Void)?,
                            cancelClick:((UIAlertAction) -> Swift.Void)?) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action1 = UIAlertAction(title: "是", style: .default, handler: sureClick)
    let action2 = UIAlertAction(title: "否", style: .cancel, handler: cancelClick)
    action1.setTextColor(Dzy_MainColor)
    alert.addAction(action2)
    alert.addAction(action1)
    return alert
}

//MARK: - 警告和确认
public func dzy_msgAlert(_ title: String, msg: String, handler: (() -> ())? = nil) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "是", style: .cancel) { [unowned alert] (action) in
        handler?()
        alert.dismiss(animated: true, completion: nil)
    }
    action.setTextColor(Dzy_MainColor)
    alert.addAction(action)
    return alert
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
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage?
    UIGraphicsEndImageContext()
    return image
}

//MARK: - 图片展示
public func showSingleImage(_ url: String) {
    let type = DzyShowImageType.one(url)
    let showView = DzyShowImageView(type)
    showView.show()
}

public func showMoreImages(_ urls: [String], _ index: Int) {
    let type = DzyShowImageType.more(urls, index)
    let showView = DzyShowImageView(type)
    showView.show()
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
