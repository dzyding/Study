//
//  ToolClass.swift
//  ZAJA
//
//  Created by ZHY on 2016/11/9.
//  Copyright © 2016年 FreeHouse. All rights reserved.
//

import UIKit
import Foundation
import ActionSheetPicker_3_0
import CryptoSwift
import AssetsLibrary
import Photos

class ToolClass {
    
    static let baseQrUrl = "https://www.ppbody.com/download/A"
    
    static let ScreenBounds = UIScreen.main.bounds
    static let ScreenWidth = ScreenBounds.width
    static let ScreenHeight = ScreenBounds.height
    static let ColorLine = UIColor.ColorHex("#3E3E3E")
    static let BackgroundColor = UIColor.ColorHex("#27272C")
    static let CardColor = UIColor.ColorHex("#333237")
    static let YellowMainColor = UIColor.ColorHex("#F8E71C")
    static let BlueLineColor = UIColor.ColorHex("#3afdfe")
    static let TextMainColor = UIColor.ColorHex("#FFFFFF")
    static let Text1Color = UIColor.ColorHex("#999999")
    
    
    static let LINE_HEIGHT = ToolClass.ScreenHeight > 500 ? 0.5 : 1
    static let DefaultHeader = UIImage(named: "person_head_default")
    static let DefaultPic = UIImage(named: "default_image_house")
    
    static func adjustsScrollViewInsetNever(_ controller: UIViewController, _ scrollview: UIScrollView){
        if #available(iOS 11, *) {
            scrollview.contentInsetAdjustmentBehavior =  UIScrollView.ContentInsetAdjustmentBehavior.never
        }else{
            controller.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    //数据字典
    var dataDic = [String:Any]()
    //数据list
    var dataArr = [[String:Any]]()
    
    static func CustomFont(_ size:CGFloat)->UIFont {
        return UIFont(name: "PingFangSC-Thin", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func CustomBoldFont(_ size:CGFloat)->UIFont {
        return UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    


    
    //私钥解密userId
    static func decryptUserId(_ uid: String) ->Int?{
        do {
            let key: [UInt8]  = Array("www.ppbody.com".utf8)
            let iv: [UInt8]  = Array("qx1024pp".utf8)
            
            let encryptedData = Data(base64Encoded: uid, options: [])
        
            let secret: [UInt8] = [UInt8](encryptedData!)
            
            let decryptedByte = try Blowfish(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(secret)
            
            let decrypted = String(bytes: decryptedByte, encoding: .utf8)
            
            let add = decrypted![0,0]
            let ride = decrypted![(decrypted?.count)!-1,(decrypted?.count)!-1]
            let value = decrypted![13,(decrypted?.count)!-14]
            
            return (Int(value)! - Int(add)!) / Int(ride)!
            
        } catch let error as NSError {
            print(error)
        }

        return nil
    }
    
    //加密 userId
    static func encryptUserId(_ userId: Int) ->String?{
        do {
            let key: [UInt8]  = Array("www.ppbody.com".utf8)
            let iv: [UInt8]  = Array("qx1024pp".utf8)
            
            let ride = Int(arc4random_uniform(5) + 1)
            let add = Int(arc4random_uniform(8) + 1)
            
            let value = userId * ride + add
            
            let secret = "\(add)" + randomString(length: 12) + "\(value)" + randomString(length: 12) + "\(ride)"
            
            let msg: Array<UInt8> = Array(secret.utf8)
            let encrypted = try Blowfish(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).encrypt(msg).toBase64()
                        
            return encrypted
            
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    //加密字符串
    static func encryptStr(_ secret: String) ->String?{
        do {
            let key: [UInt8]  = Array("www.ppbody.com".utf8)
            let iv: [UInt8]  = Array("qx1024pp".utf8)
            
            let msg: Array<UInt8> = Array(secret.utf8)
            let encrypted = try Blowfish(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).encrypt(msg).toBase64()
            
            return encrypted
            
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    //解密字符串
    static func decryptStr(_ txt: String) ->String?{
        do {
            let key: [UInt8]  = Array("www.ppbody.com".utf8)
            let iv: [UInt8]  = Array("qx1024pp".utf8)
            
            let encryptedData = Data(base64Encoded: txt, options: [])
            
            let secret: [UInt8] = [UInt8](encryptedData!)
            
            let decryptedByte = try Blowfish(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(secret)
            
            let decrypted = String(bytes: decryptedByte, encoding: .utf8)
            
            return decrypted
            
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    /// 分享 url
    static func shareUrl() -> String? {
        let idStr = DataManager.userAuth()
        guard let userId = ToolClass.decryptUserId(idStr) else {return nil}
        let url = baseQrUrl + "\(userId + 121314)"
        // *1000 是精确到毫秒，不乘就是精确到秒
        var time = Date().timeIntervalSince1970 * 1000
        var timeSp = String(format: "%.lf", time)
        timeSp = String(timeSp.reversed())
        if let reTime = Double(timeSp) {
            time = reTime + 5
            timeSp = String(format: "%013.0lf", time)
            return url + timeSp
        }else {
            return nil
        }
    }
    
    /// 解码 url
    static func decryptShareUrl(_ str: String) -> (Int, Double)? {
        let temp = str.replacingOccurrences(
            of: baseQrUrl,
            with: ""
        )
        let index = temp.index(temp.endIndex, offsetBy: -13)
        let timeStr = String(temp[index...])
        let idStr = String(temp[..<index])
        
        guard let userId = Int(idStr),
            var time = Double(timeStr)
            else {return nil}
        time = time - 5
        var timeSp = String(format: "%013.0lf", time)
        timeSp = String(timeSp.reversed())
        guard let resultTime = Double(timeSp) else {return nil}
        return (userId - 121314, resultTime)
    }
    
    //颜色生成图片
    static func createImage(_ color: UIColor)-> UIImage{
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //MARK: -  从 Int 时间转换成 String
    static func getTimeStr(_ time: Int) -> String {
        let hour = time / 60
        let min  = time % 60
        return String(format: "%02ld:%02ld", hour, min)
    }
    
    static func getIntTime(_ time: String) -> Int {
        let timeArr = time.components(separatedBy: ":")
        guard timeArr.count == 3 else {return 0}
        let hour = Int(timeArr[0]) ?? 0
        let min = Int(timeArr[1]) ?? 0
        return hour * 60 + min
    }
    
    // 相机权限
    static func isRightCamera() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus != .restricted && authStatus != .denied
        
    }
    
    // 相册权限
    static func isRightPhoto() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        return authStatus != .restricted && authStatus != .denied
    }

    
    //判断密码位数
    static func checkPswd(_ pswd: String) -> Bool {
        
        if pswd.count >= 6 && pswd.count <= 16 {
            return true
        }
        return false
    }
    
    //判断手机号是否正确
    static func checkPhone(_ phone : String) -> Bool
    {
        
        let pattern = "^1[0-9]{10}$"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: phone, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, phone.count))
        if res.count > 0 {
            return true
        }
        return false
    }
    //根据屏幕尺寸判断是6，7还是plus
    
    static func isPlus() ->Bool{
        
        if ToolClass.ScreenWidth > 375{
            
            return true
            
        }else{
            
            return false
            
        }
    }
    
    //系统打电话
    static func callMobile(_ mobile: String)
    {
        let urlString = "tel://" + mobile
        if let url = URL(string: urlString) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //时间处理
    static func getStringFormDate(date: Date, format: String) -> String {
        let fmt = DateFormatter.init()
        fmt.dateFormat = format
        return fmt.string(from: date)
    }
    
    static func getDateFormDateStr(date: String, format: String) -> Date {
        let fmt = DateFormatter.init()
        fmt.dateFormat = format
        let date = fmt.date(from: date)
        return date!
    }
    
    //判断身份证信息
    static func checkIDCard(_ card : String) -> Bool
    {
        let pattern = "\\d{14}[[0-9],0-9xX]"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: card, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, card.count))
        if res.count > 0 {
            return true
        }
        return false
    }
    
    /// GCD延时操作
    ///   - after: 延迟的时间
    ///   - handler: 事件
    static func dispatchAfter(after: Double, handler:@escaping ()->())
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            handler()
        }
    }
    
    //Show Toast with Title
    static func showToast(_ title : String, _ style : Toaster.Style) {
        DispatchQueue.main.async {
            let toastAlertView = UINib(nibName: "ToastAlertView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ToastAlertView
            toastAlertView.titleLB.text = title
            toastAlertView.backgroundColor = style == .Success ? toastAlertView.Success_Color : toastAlertView.Failure_Color
            
            let toast = Toast(view: toastAlertView, dismissAfter: 2.0, height: IS_IPHONEX ? 88:64)
            Toaster.sharedInstance
                .prepareToast(toast,
                              withPriority: .immediate)
        }
    }
    
    //Loadingview
    static func showToast(_ style : Toaster.Style) -> Toast
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ToolClass.ScreenWidth, height: IS_IPHONEX ? 88:64))
        view.backgroundColor = ToolClass.YellowMainColor
        
        let loader = Loader(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 15.0))
        loader.center = CGPoint(x: view.center.x, y: view.center.y+5)
        view.addSubview(loader)
        loader.startAnimating()
        let toast = Toast(view: view, height: IS_IPHONEX ? 88:64)
        Toaster.sharedInstance.prepareToast(toast, withPriority: .immediate)
        return toast
    }
    
    static func controller2 (view:UIView)->UIViewController?{
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.next , let vc = nextResponder as? UIViewController{
                return vc
            }
            next = next?.superview
        }while next != nil
        return nil
    }
    
    static func parantViewController(vc:UIViewController) -> UIViewController
    {
        var parent: UIViewController? = vc
        repeat{
            let parentVC = parent?.parent
            if parentVC == nil
            {
                return parent!
            }
            parent = parentVC!
        }while parent != nil
        
        return parent!
    }
    
    static func randomInRange (range: Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return  Int(arc4random_uniform(count)) + range.lowerBound
    }
    
    // To JSON
    static func toJSONString(dict: Any)->String{
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let strJson=String(data: data, encoding: .utf8)
            return strJson!
        } catch let error as NSError {
            print(error)
        }
        return ""
    }
    
    // String or Data to Dictionary
    static func getDictionaryFromJSONString(jsonString:String, data:Data? = nil) -> [String:Any]{
        
        var jsonData:Data = jsonString.data(using: .utf8)!
        
        if data != nil {
            jsonData = data!
        }
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! [String:Any]
        }
        return  [String:Any]()
    }
    
    //String to Array
    static func getArrayFromJSONString(jsonString:String) -> [Any]{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! [Any]
        }
        return  [Any]()
    }
    
    static func getJsonDataFromString<T>(_ str: String) -> [T] {
        if let jsonData = str.data(using: .utf8),
            let arr = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [T]
        {
            return arr
        }else {
            return []
        }
    }
    
    static func setActionSheetStyle(alert: ActionSheetStringPicker) {
        
        alert.pickerBackgroundColor = UIColor.ColorHex("#444444")
        alert.toolbarButtonsColor = UIColor.white
        alert.toolbarBackgroundColor =  UIColor.ColorHex("#2f2f2f")
        alert.tapDismissAction = .cancel
        alert.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: ToolClass.CustomFont(15)]
        alert.setTextColor(UIColor.white)
        alert.show()
    }
    
    static func setActionSheetStyle(alert: ActionSheetDatePicker) {
        alert.locale = Locale.init(identifier: "zh")
        alert.toolbarButtonsColor = UIColor.white
        alert.toolbarBackgroundColor = UIColor.ColorHex("#2f2f2f")
        alert.pickerBackgroundColor = UIColor.ColorHex("#444444")
        alert.tapDismissAction = .cancel
        alert.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: ToolClass.CustomFont(15)]
        alert.pickerTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: ToolClass.CustomFont(15)]
        alert.setTextColor(UIColor.white)
        alert.show()
    }
    
    //行间距的text
    static func rowSpaceText(_ text: String, _ font: Int) ->NSMutableAttributedString
    {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let emojiStr = NSString(format: "%@", text)
        
        
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle:paragraphStyle,NSAttributedString.Key.font:ToolClass.CustomFont(CGFloat(font)),NSAttributedString.Key.foregroundColor:ToolClass.Text1Color], range: NSRange(location: 0,length: (emojiStr.length)))
        
        return attributedString
    }
    
    //行间距的text
    static func rowSpaceText(_ text: String, system font: Int, color:UIColor = Text1Color) ->NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let emojiStr = NSString(format: "%@", text)
        
        attributedString.addAttributes([
            NSAttributedString.Key.paragraphStyle : paragraphStyle,
            NSAttributedString.Key.font : ToolClass.CustomFont(CGFloat(font)),
            NSAttributedString.Key.foregroundColor : color
        ], range: NSRange(location: 0,length: (emojiStr.length)))
        
        return attributedString
    }
    
    
    //压缩图片的尺寸
    // MARK: - 降低质量
    static func resetSizeOfImageData(source_image: UIImage!, maxSize: Int) -> Data {
        
        //先判断当前质量是否满足要求，不满足再进行压缩
        var finallImageData = source_image.jpegData(compressionQuality: 1.0)
        let sizeOrigin      = finallImageData?.count
        let sizeOriginKB    = sizeOrigin! / 1024
        if sizeOriginKB <= maxSize {
            return finallImageData!
        }
        
        //先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        let newImage = self.newSizeImage(size: defaultSize, source_image: source_image)
        
        finallImageData = newImage.jpegData(compressionQuality: 1.0)
        
        //保存压缩系数
        let compressionQualityArr = NSMutableArray()
        let avg = CGFloat(1.0/250)
        var value = avg
        
        var i = 250
        repeat {
            i -= 1
            value = CGFloat(i)*avg
            compressionQualityArr.add(value)
        } while i >= 1
        
        /*
         调整大小
         说明：压缩系数数组compressionQualityArr是从大到小存储。
         */
        //思路：使用二分法搜索
        finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: newImage, sourceData: finallImageData!, maxSize: maxSize)
        //如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData?.count == 0 {
            //每次降100分辨率
            if defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width-100, height: defaultSize.height-100)
            let image = self.newSizeImage(size: defaultSize, source_image: UIImage.init(data:newImage.jpegData(compressionQuality: compressionQualityArr.lastObject as! CGFloat)!)!)
            finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: image, sourceData: image.jpegData(compressionQuality: 1.0)!, maxSize: maxSize)
        }
        
        return finallImageData!
    }
    
    // MARK: - 调整图片分辨率/尺寸（等比例缩放）
    static func newSizeImage(size: CGSize, source_image: UIImage) -> UIImage {
        var newSize = CGSize(width: source_image.size.width, height: source_image.size.height)
        let tempHeight = newSize.height / size.height
        let tempWidth = newSize.width / size.width
        
        if tempWidth > 1.0 && tempWidth >= tempHeight {
            newSize = CGSize(width: source_image.size.width / tempWidth, height: source_image.size.height / tempWidth)
        } else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width: source_image.size.width / tempHeight, height: source_image.size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        source_image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // MARK: - 二分法
    static func halfFuntion(arr: [CGFloat], image: UIImage, sourceData finallImageData: Data, maxSize: Int) -> Data? {
        var tempFinallImageData = finallImageData
        
        var tempData = Data.init()
        var start = 0
        var end = arr.count - 1
        var index = 0
        
        var difference = Int.max
        while start <= end {
            index = start + (end - start)/2
            
            tempFinallImageData = image.jpegData(compressionQuality: arr[index])!
            
            let sizeOrigin = tempFinallImageData.count
            let sizeOriginKB = sizeOrigin / 1024
            
            
            if sizeOriginKB > maxSize {
                start = index + 1
            } else if sizeOriginKB < maxSize {
                if maxSize-sizeOriginKB < difference {
                    difference = maxSize-sizeOriginKB
                    tempData = tempFinallImageData
                }
                end = index - 1
            } else {
                break
            }
        }
        return tempData
    }
    
    /**
     将字符串替换*号
     - parameter str:        字符
     - parameter startindex: 开始字符索引
     - parameter endindex:   结束字符索引
     - returns:
     替换后的字符串
     */
    static func stringByX(str:String,startindex:Int,endindex:Int) -> String{
        //开始字符索引
        let startIndex = str.index(str.startIndex, offsetBy: startindex)
        //结束字符索引
        let endIndex = str.index(str.startIndex, offsetBy: endindex)
        let range = startIndex..<endIndex
        var s = String()
        for _ in 0..<endindex - startindex{
            s += "*"
        }
        return str.replacingCharacters(in: range, with: s)
    }
    
    //将时间显示为（几分钟前，几小时前，几天前）
    static func compareCurrentTime(date:String) -> String {
        var date = date
        if !date.contains(" ") {
            date += " 00:00:00"
        }
        //将时间戳转换为日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let timeDate = formatter.date(from: date) else {return ""}
        
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(timeDate)
        //        var temp:Double = 0
        var result:String = ""
        
        if timeInterval < 0
        {
            result = "提前"
        }else if timeInterval/60 < 1 {
            result = "刚刚"
        }else if (timeInterval/60) < 15{
            //            temp = timeInterval/60
            result = "15分钟前"
        }else if timeInterval/(60 * 60) < 2 {
            //            temp = timeInterval/(60 * 60)
            result = "2小时前"
        }else if timeDate.isToday {
            result = "今天"
        }else if timeDate.isYesterday {
            //            temp = timeInterval / (24 * 60 * 60)
            result = "昨天"
        }else if (timeDate.year == currentDate.year)
        {
            result = "\(timeDate.month)-\(timeDate.day)"
        }else{
            formatter.dateFormat = "yyyy-MM-dd"
            result = formatter.string(from: timeDate)
        }
        return result
    }
    /**
     MD5加密字符串
     */
    static func md5(_ text: String) -> String{
        
        let str = text.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(text.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        //        let hash = NSMutableString()
        
        
        let encrypt = String.init(format: "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1],result[2], result[3],result[4], result[5],result[6], result[7],result[8], result[9],result[10], result[11],result[12], result[13],result[14], result[15])
        
        result.deallocate()
        return encrypt
    }
    
    //md5 加密Data
    static func md5(_ data: Data) -> String
    {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  data.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(data.count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
    
    
    
    //密码加密
    static func encryptPassword(_ password: String) -> String
    {
        return md5(password + "ZAJA")
    }
    
    /**
     
     根据Dictionary 获取名字
     */
    static func getNameFromDic(_ dic: [String:Any]) -> String
    {
        var name = ""
        
        let nickname = dic["nickname"] as? String
        let username = dic["username"] as? String
        
        
        if nickname != ""{
            name = nickname!
        }else if username != ""{
            name = username!
        }else{
            name = ToolClass.stringByX(str: dic["mobile"] as! String, startindex: 3, endindex: 8)
        }
        
        return name
    }
    
    
    
    //根据手机尺寸更改UI尺寸
    static func changeSizeAsPhone(_ size : CGFloat) -> CGFloat{
        
        return size / 375 * ScreenWidth
        
    }
    
    
    //添加下划线
    static func addUnderLineBtn(_ button : UIButton,_ title : String,_ color : UIColor){
        
        
        let str = title
        let attri = NSMutableAttributedString(string: "")
        let attrs = [NSAttributedString.Key.foregroundColor.rawValue:color,NSAttributedString.Key.underlineStyle : 1] as! [NSAttributedString.Key:Any]
        let setStr = NSMutableAttributedString.init(string: str, attributes: attrs)
        
        attri.append(setStr)
        
        button.setAttributedTitle(attri, for: .normal)
        
    }
    
    
    
    //给视图添加投影
    static func addShadowForView(_ view : UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 0.5
        view.layer.shadowOpacity = 0.15
    }
    
    
    
    
    //获取rootViewController
    static func rootViewController() ->UIViewController{
        let window = UIApplication.shared.keyWindow
        return window!.rootViewController!
    }
    
    //随机数目
    static func randomCustom(min: Int, max: Int) -> Int {
        if max == 1 {
            return Int(arc4random() % UInt32(2))
        }else {
            let y = arc4random() % UInt32(max) + UInt32(min)
            return Int(y)
        }
    }
    
    
    //获取拼音首字母（大写字母）
    static func findFirstLetterFromString(aString: String) -> String {
        //转变成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        
        //将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil,      kCFStringTransformToLatin, false)
        
        //去掉声调
        let pinyinString = mutableString.folding(options:          String.CompareOptions.diacriticInsensitive, locale:   NSLocale.current)
        
        //将拼音首字母换成大写
        let strPinYin = polyphoneStringHandle(nameString: aString,    pinyinString: pinyinString).uppercased()
        
        //截取大写首字母
        let firstString = strPinYin[..<strPinYin.index(strPinYin.startIndex, offsetBy: 1)]
        
        //判断首字母是否为大写
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? String(firstString) : "#"
    }
    
    //多音字处理，根据需要添自行加
    static func polyphoneStringHandle(nameString: String, pinyinString: String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        return pinyinString
    }
    
    //把秒转成优雅显示  00:30
    static func showDuration(_ duration: Int) -> String
    {
        let min = duration / 60
        let second = duration % 60
        
        let minStr = min < 10 ? "0\(min)" : "\(min)"
        let secondStr = second < 10 ? "0\(second)" : "\(second)"
        
        return minStr + ":" + secondStr
    }
    
    //截取url本地路劲
    static func getMusicLocalPath(_ url: String) -> String
    {
        
        let array = url.components(separatedBy: "/")
        
        if array.count < 2
        {
            return url
        }
        return NSTemporaryDirectory() + array[array.count-2] + "/" + array[array.count-1]
    }
    
    //获取url oss objectname
    static func getOSSObjectname(_ url: String) -> String
    {
        
        let array = url.components(separatedBy: "/")
        
        if array.count < 2
        {
            return url
        }
        return array[array.count-2] + "/" + array[array.count-1]
    }
    
    //获取视频的第一帧
    static func getCoverFromVideo(_ path: String) -> UIImage
    {
        let url = URL(fileURLWithPath: path)
        let avAsset = AVAsset(url: url)
        
        //生成视频截图
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        let frameImg = UIImage(cgImage: imageRef)
        return frameImg
    }
    
    //秒转时间
    static func secondToText(_ second: Int) -> String{
        if second < 60
        {
            return "\(second)秒"
        }else if second < 60 * 60
        {
            let min = Float(second) / 60.0
            return min.removeDecimalPoint + "分钟"
        }else{
            let hour = Float(second) / 3600.0
            return hour.removeDecimalPoint + "小时"
        }
    }
    
    //根据部位获取相应的code
    static func getPlanCode(_ title:String)->String {
        switch title {
        case "胸部":
            return "MG10000"
        case "背部":
            return "MG10001"
        case "肩部":
            return "MG10002"
        case "腹部":
            return "MG10003"
        case "手臂":
            return "MG10004"
        case "臀腿":
            return "MG10005"
        case "有氧":
            return "MG10006"
        default:
            return ""
        }
    }
    
    //英文翻译成中文
    static func getTitleFromLetter(_ letter:String) -> String
    {
        switch letter {
        case "weight":
            return "体重"
        case "muscle":
            return "骨骼肌"
        case "fat":
            return "体脂肪"
        case "bust":
            return "胸围"
        case "arm":
            return "臂围"
        case "waist":
            return "腰围"
        case "hipline":
            return "臀围"
        case "thigh":
            return "腿围"
        default:
            return letter
        }
    }
    
    //是否为有氧运动
    static func isCardio(_ code: String) -> Bool
    {
        if code.contains("MG10006")
        {
            return true
        }else{
            return false
        }
    }
    
    //根据动作获取组别
    static func planCodeFromMotion(_ code: String) -> String
    {
        return code[0,6]
    }
    
    //是否有消息未读
    static func isMessageNoRead(_ message:[String:Any]) -> Int {
        var noReadNum = 0
        if let followNum = message.intValue("followNum"),
            followNum > 0
        {
            noReadNum += followNum
        }
        if let topicSupportNum = message.intValue("topicSupportNum"),
            topicSupportNum > 0
        {
            noReadNum += topicSupportNum
        }
        if let topicDirectNum = message.intValue("topicDirectNum"),
            topicDirectNum > 0
        {
            noReadNum += topicDirectNum
        }
        if let topicCommentNum = message.intValue("topicCommentNum"),
            topicCommentNum > 0
        {
            noReadNum += topicCommentNum
        }
        return noReadNum
    }
    
    //移除控制器的里面的某一个controller
    static func removeChildController(_ controller: UIViewController, removeClass: AnyClass)
    {
        let childs = controller.navigationController?.children
        
        //移除子试图
        for vc in childs!
        {
            if vc.classForCoder == removeClass
            {
                vc.view.removeFromSuperview()
                vc.removeFromParent()
                break
            }
            
        }
    }
}
