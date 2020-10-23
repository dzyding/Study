//
//  ToolClass.swift
//  ZAJA
//
//  Created by ZHY on 2016/11/9.
//  Copyright © 2016年 FreeHouse. All rights reserved.
//

import UIKit
import Foundation

// swiftlint:disable force_try force_cast shorthand_operator type_body_length legacy_constructor file_length
class ToolClass {
    static func adjustsScrollViewInsetNever(_ controller: UIViewController, _ scrollview: UIScrollView){
        if #available(iOS 11, *) {
            scrollview.contentInsetAdjustmentBehavior =  UIScrollView.ContentInsetAdjustmentBehavior.never
        }else{
            controller.automaticallyAdjustsScrollViewInsets = false
        }
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
    
    //颜色生成图片
    static func createImage(_ color: UIColor) -> UIImage{
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
        let res = regex.matches(
            in: phone,
            options: NSRegularExpression.MatchingOptions(rawValue:0),
            range: NSMakeRange(0, phone.count)
        )
        if res.count > 0 {
            return true
        }
        return false
    }

    //系统打电话
    static func callMobile(_ mobile: String)
    {
        let urlString = "tel://" + mobile
        if let url = URL(string: urlString) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:])
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
    static func checkIDCard(_ card : String) -> Bool {
        let pattern = "\\d{14}[[0-9],0-9xX]"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(
            in: card,
            options: NSRegularExpression.MatchingOptions(rawValue:0),
            range: NSMakeRange(0, card.count)
        )
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
    static func showToast(_ title : String, _ style : Toaster.Style)
    {
        let toastAlertView = UINib(
            nibName: "ToastAlertView",
            bundle: nil)
            .instantiate(
                withOwner: nil,
                options: nil
            )[0] as! ToastAlertView
        toastAlertView.titleLB.text = title
        toastAlertView.backgroundColor = style == .Success ? toastAlertView.Success_Color : toastAlertView.Failure_Color
        
        let toast = Toast(view: toastAlertView, dismissAfter: 2.0, height: IS_IPHONEX ? 88:64)
        Toaster.sharedInstance.prepareToast(toast, withPriority: .immediate)
    }
    
    static func controller2 (view:UIView) -> UIViewController? {
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.next,
                let vc = nextResponder as? UIViewController
            {
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
            if parentVC == nil {
                return parent!
            }
            parent = parentVC
        }while parent != nil
        
        return parent!
    }
    
    static func randomInRange (range: Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return  Int(arc4random_uniform(count)) + range.lowerBound
    }
    
    // To JSON
    static func toJSONString(dict: Any) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let strJson = String.init(data: data, encoding: .utf8)
            return strJson!
            
        } catch let error as NSError {
            print(error)
        }
        return ""
    }
    
    // String to Dictionary
    static func getDictionaryFromJSONString(jsonString:String) -> [String:Any]{
        let jsonData:Data = jsonString.data(using: .utf8)!
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
        return [Any]()
    }
    
    //行间距的text
    static func rowSpaceText(
        _ text: String,
        system font: Int
    ) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let emojiStr = NSString(format: "%@", text)
        attributedString.addAttributes([
            NSAttributedString.Key.paragraphStyle:paragraphStyle,
            NSAttributedString.Key.font:UIFont.systemFont(ofSize:CGFloat(font)),
            NSAttributedString.Key.foregroundColor:Font_Dark
            ],
            range: NSRange(location: 0, length: (emojiStr.length))
        )
        return attributedString
    }
    ///传入base64的字符串，可以是没有经过修改的转换成的以data开头的，也可以是base64的内容字符串，然后转换成UIImage
   static func base64StringToUIImage(base64String:String) -> UIImage? {
        var str = base64String
        // 1、判断用户传过来的base64的字符串是否是以data开口的，如果是以data开头的，那么就获取字符串中的base代码，然后在转换，如果不是以data开头的，那么就直接转换
        if str.hasPrefix("data:image") {
            guard let newBase64String = str.components(separatedBy: ",").last else {
                return nil
            }
            str = newBase64String
        }
        // 2、将处理好的base64String代码转换成NSData
        guard let imgNSData = NSData(base64Encoded: str, options: NSData.Base64DecodingOptions()) else {
            return nil
        }
        // 3、将NSData的图片，转换成UIImage
        guard let codeImage = UIImage(data: imgNSData as Data) else {
            return nil
        }
        return codeImage
    }
    
    //压缩图片的尺寸
    // MARK: - 降低质量
    static func resetSizeOfImageData(source_image: UIImage, maxSize: Int) -> Data {
        //先判断当前质量是否满足要求，不满足再进行压缩
        var finallImageData = source_image.jpegData(compressionQuality: 1.0)
        let sizeOrigin      = finallImageData?.count ?? 0
        let sizeOriginKB    = sizeOrigin / 1024
        if sizeOriginKB <= maxSize {
            return finallImageData ?? Data()
        }

        //先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        let newImage = newSizeImage(source_image: source_image)
        
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
        finallImageData = halfFuntion(
            arr: compressionQualityArr.copy() as! [CGFloat],
            image: newImage,
            sourceData: finallImageData!,
            maxSize: maxSize
        )
        //如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData?.count == 0 {
            //每次降100分辨率
            if defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width-100, height: defaultSize.height-100)
            let image = self.newSizeImage(
                source_image: UIImage(
                    data: newImage.jpegData(
                        compressionQuality: compressionQualityArr.lastObject as! CGFloat)!
                    )!
            )
            finallImageData = self.halfFuntion(
                arr: compressionQualityArr.copy() as! [CGFloat],
                image: image,
                sourceData: image.jpegData(compressionQuality: 1.0)!,
                maxSize: maxSize
            )
        }

        return finallImageData!
    }
    
    // MARK: - 调整图片分辨率/尺寸（等比例缩放）
    static func newSizeImage(source_image: UIImage) -> UIImage {
        // 最大多少像素
        let maxImageSize:CGFloat = 1500
        //整分辨率
        var newSize = source_image.size
        let maxValue = max(newSize.width, newSize.height)
        let n = maxImageSize / maxValue
        newSize = CGSize(width: newSize.width * n, height: newSize.height * n)
        UIGraphicsBeginImageContext(newSize)
        source_image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? source_image
        UIGraphicsEndImageContext()
        return newImage
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
    static func stringByX(str:String, startindex:Int, endindex:Int) -> String{
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
        //将时间戳转换为日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeDate = formatter.date(from: date)
        
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(timeDate!)
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
        }else if (timeDate?.isToday)! {
            result = "今天"
        }else if (timeDate?.isYesterday)! {
            //            temp = timeInterval / (24 * 60 * 60)
            result = "昨天"
        }else if timeDate?.year == currentDate.year {
            result = "\(timeDate?.month ?? 0)-\(timeDate?.day ?? 0)"
        }else{
            formatter.dateFormat = "yyyy年-MM月-dd日"
            result = formatter.string(from: timeDate!)
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
        
        let encrypt = String(
            format: "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7], result[8], result[9],
            result[10], result[11], result[12], result[13], result[14], result[15])
        result.deallocate()
        return encrypt
    }
    
    //md5 加密Data
    static func md5(_ data: Data) -> String {
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
    static func addUnderLineBtn(
        _ button : UIButton,
        _ title : String,
        _ color : UIColor)
    {
        let str = title
        let attri = NSMutableAttributedString(string: "")
        let attrs = [
            NSAttributedString.Key.foregroundColor.rawValue:color,
            NSAttributedString.Key.underlineStyle : 1
            ] as! [NSAttributedString.Key : Any]
        let setStr = NSMutableAttributedString.init(string: str, attributes: attrs)
        attri.append(setStr)
        button.setAttributedTitle(attri, for: .normal)
    }
    
    //给视图添加投影
    static func addShadowForView(_ view : UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize.zero
        view.layer.masksToBounds = false
    }
    
    //获取rootViewController
    static func rootViewController() -> UIViewController{
        let window = UIApplication.shared.keyWindow
        return window!.rootViewController!
    }
    
    //随机数目
    static func randomCustom(min: Int, max: Int) -> Int {
        let y = arc4random() % UInt32(max) + UInt32(min)
        return Int(y)
    }
    
    //获取拼音首字母（大写字母）
    static func findFirstLetterFromString(aString: String) -> String {
        //转变成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        //将中文转换成带声调的拼音
        CFStringTransform(
            mutableString as CFMutableString,
            nil,
            kCFStringTransformToLatin, false
        )
        //去掉声调
        let pinyinString = mutableString.folding(
            options : String.CompareOptions.diacriticInsensitive,
            locale : NSLocale.current
        )
        
        //将拼音首字母换成大写
        let strPinYin = polyphoneStringHandle(
            nameString: aString,
            pinyinString: pinyinString
            ).uppercased()
        
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
    
    static func AddImageHeader(imagebase64str:String) -> String {
        let head = "data:imag/png;base64,"
        if imagebase64str.contains(head)  == true{
            print("自带")
            return imagebase64str
        }else{
            print("非自带")
            return head + imagebase64str
        }
    }

   static func localizeTime(dateString:String, formatter:String) -> String {
        var datestr = String()
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "zh_CN")
        inFormatter.dateFormat = formatter
        let date = inFormatter.date(from: dateString)
        datestr = inFormatter.string(from: date!)
        return datestr
    }
    
    static func getFormatPlayTime(secounds:TimeInterval) -> String{
        if secounds.isNaN{
            return "00:00"
        }
        var Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min>=60 {
            Hour = Int(Min / 60)
            Min = Min - Hour*60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "00:%02d:%02d", Min, Sec)
    }
    
    static func GetAllCells(tableView:UITableView) -> [IndexPath]{
        let section = tableView.numberOfSections
        var cells:[IndexPath] = []
        for i in 0 ..< section{
            let rows = tableView.numberOfRows(inSection: i)
            for row in 0 ..< rows {
                let indexpath = IndexPath(row: row, section: i)
                cells.append(indexpath)
            }
        }
        return cells
    }
    
    static func labelSizeFromText(_ str:String, size:CGFloat) -> CGFloat{
        let attribute = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: size)]
        return (str as NSString).size(withAttributes: attribute).width
    }
}
