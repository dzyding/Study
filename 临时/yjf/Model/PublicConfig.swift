//
//  PublicConfig.swift
//  YJF
//
//  Created by edz on 2019/4/26.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation
import ZKProgressHUD

extension Dictionary where Dictionary.Key == String {
    /// 判断房源是否已成交
    func isOrderSuccess() -> Bool {
        return self.intValue("status") != 10
    }
}

struct PublicConfig {
//    "staffImgNum": 12,
//    "staffLoginNum": -1,
    
    public enum SysConfigKey: String {
        /// 用户登陆有效期
        case user_loginNum = "userLoginNum"
        
        /// 图片大小
        case imageSize = "imgSize"
        
        /// 门锁最远距离
        case lockDistance = "houseDistance"
        
        /// 房源展示图片数量
        case house_showImageCount = "imgNum"
        /// 房源详情，卖家报价数量
        case house_sellPriceNum = "sellTotalNum"
        /// 房源详情，默认显示竞买数量（pageSize）
        case house_buyPriceNum = "buyTotalNum"
        /// 卖家上传房屋图片数量
        case addHouse_imageNum = "userImgNum"
        
        /// 看房，卖家超时到语音确认之间的时间间隔
        case lookHouse_sellerOverTime = "sellLookNumByOP"
        /// 看房，报告房屋状况的图片数量，报告房屋损毁的图片数量
        case look_report_imageNum = "lookImgNum"
        /// 看房，超时时间
        case lookHouse_exceedTime = "exceedTime"
        /// 看房，超时费率
        case lookHouse_exceedPrice = "exceedPrice"
    }
    
    /// 添加报价成功
    static let Notice_AddPriceSuccess = Notification.Name("AddPriceSuccess")
    /// 撤销报价成功
    static let Notice_UndoPriceSuccess = Notification.Name("UndoPriceSuccess")
    /// 成交成功
    static let Notice_BuySuccess = Notification.Name("BuySuccess")
    /// 添加房源成功
    static let Notice_AddHouseSuccess = Notification.Name("AddHouseSuccess")
    /// 支付成功
    static let Notice_PaySuccess = Notification.Name("PaySuccess")
    /// 优显退款成功
    static let Notice_TopRefundSuccess = Notification.Name("TopRefundSuccess")
    /// 撤销房源成功
    static let Notice_UndoHouseSuccess = Notification.Name("UndoHouseSuccess")
    /// 缴纳买方保证金成功
    static let Notice_PayBuyDepositSuccess = Notification.Name("PayBuyDepositSuccess")
    /// 缴纳卖方保证金、门锁押金成功
    static let Notice_PaySellDepositSuccess = Notification.Name("PaySellDepositSuccess")
    /// 更新交易流水
    static let Notice_UpdateDepositFlow = Notification.Name("UpdateDepositFlow")
    /// 切换城市成功
    static let Notice_ChangeCitySuccess = Notification.Name("ChangeCitySuccess")
    /// 切换城市成功
    static let Notice_InitCitySuccess = Notification.Name("InitCitySuccess")
    /// 登陆超时
    static let Notice_TokenTimeOut = Notification.Name("TokenTimeOut")
    
    static let Pay_Notice_Deposit = "为了完成后续操作，建议您缴纳保证金"
    static let Pay_Notice_Lock    = "很抱歉，请先缴纳门锁押金"
    static let Pay_Notice_Look    = "很抱歉，请先缴纳看房押金"
    
    /// 提示框
    static let Msg_Pwd = "请输入至少6位，含数字/字母/符号中至少两种"
    
    static func homeHeaderSearchPlaceholder() -> NSMutableAttributedString {
        return PublicConfig.basePlaceHolder(" 您想在哪里买房？")
    }
    
    static func priceCurveSearchPlaceholder() -> NSMutableAttributedString {
        return PublicConfig.basePlaceHolder(" 请输入小区关键字")
    }
    
    static func publicSearchPlaceholder() -> NSMutableAttributedString {
        return PublicConfig.basePlaceHolder(" 请输入关键字")
    }
    
    /// 押金 限定时间 每分钟金额 保证金 保证金
    static let buyerDepositMsg = """
    买方自助看房规则：

        买方自助看房，须向易间房交易平台（下称平台）支付看房押金%@元。单次看房时间限定为%ld分钟，开门计时开始，锁门计时结束。买方看房超时，平台将按每分钟%@元的标准收取超时费。
    买方看房期间，不得损坏房屋及房屋内现有的电器、家具等财物，否则，照价赔偿。买方看房结束，要注意关灯、关水、关窗、关门，确保房屋安全。
    买方可以随时申请退还看房押金，在不存在看房超时、不存在损坏房屋及房屋内财物等情况下，平台将于七个工作日之内依据原支付通道原路退还全部押金。如存在上述情况，平台在扣除相关超时费用、赔偿费用以后退还剩余的押金。
    买方在到达看房现场时，如果有其他买方正在看房，请在门外稍候，依次看房。

    买方参与竞价规则：
       
        买方在参与易间房交易平台（下称平台）交易竞价之前，请确认您本人或者您的委托人具有当地购房资格，否则，将承担不利法律后果。在向平台交纳%@元交易保证金以后，买方可以参与平台交易竞价。
    在竞价过程中，当买方看到了能够接受的卖方报价时，可以选择成交。同理，买方报出的价格也会随时被卖方选择成交。此时，该房屋被平台锁定，不再接受竞价，平台将为买卖双方安排后续签订买卖合同事宜。
    如果在平台通知的时间里，买方不到平台指定的签约服务中心与卖方签订买卖合同，平台将没收买方所交纳的%@元交易保证金，其中一半用于赔偿平台损失，另一半用于赔偿参与签约的卖方的损失。
    在达成成交意向之前，买方可以随时申请退还上述保证金。接到申请后，平台将于七个工作日之内依据原支付通道原路全额退还。
    买方承诺，在买卖双方签订正式房屋买卖合同之时，愿意向平台交纳房屋成交价百分之一的佣金，而平台的服务将一直延续到协助买方办理该房屋的的交易过户手续；
    买方同时承诺，在办理上述手续过程中，承担国家规定的应该由买方缴纳的有关税费。
    """
    
    /// 门锁押金 每天的租金1 拆装费200 保证金 保证金
    static let sellerDepositMsg = """
    智能门锁安装规则：
       
        为了方便买方随时看房，尽快成交，卖方可向易间房交易平台（下称平台）申请安装智能门锁。卖方在交纳%@元门锁押金以后，平台将安排专人到卖方指定的房屋安装智能门锁。智能门锁通过扫码或者输入密码等方式开锁，可提供24小时看房服务。
    智能门锁安装以后，平台将天按照每%@元的标准收取门锁租金，同时一次性收取 %@元的门锁装卸费用。如果该房屋在平台一直没有成交，卖方可以随时申请拆卸智能门锁，平台在对上述费用进行结算以后，将于七个工作日之内依据原支付通道原路把剩余的押金退还给卖方。
     
    卖方参与竞价规则：
       
        卖方在参与易间房交易平台（下称平台）竞价之前，请确认您本人或者您的委托人是该房屋的产权所有人，该房屋无查封等产权纠纷，否则，将承担不利法律后果。
    在交纳%@元交易保证金以后，卖方可以参与平台交易竞价。在竞价过程中，当卖方看到了能够接受的买方报价时，可以选择成交。同理，卖方报出的价格也会随时被买方选择成交。此时，该房屋被平台锁定，不再接受竞价，平台将为买卖双方安排后续签订买卖合同事宜。
    如果在平台通知的时间里，卖方不到平台指定的签约服务中心与买方签订买卖合同，平台将没收卖方所交纳的%@元交易保证金，其中一半用于赔偿平台损失，另一半用于赔偿参与签约的买方的损失。
    在达成成交意向之前，卖方可以随时申请退还上述保证金。接到申请后，平台将于七个工作日之内依据原支付通道原路全额退还。
    卖方承诺，在买卖双方签订正式房屋买卖合同之时，愿意向平台交纳房屋成交价百分之一的佣金，而平台的服务将一直延续到协助卖方办理该房屋的交易过户手续；卖方同时承诺，在办理上述手续过程中，承担国家规定的应该由卖方缴纳的有关税费。
    """
    
    /// 优显信息
    static let topMsg = """
        卖方在付费以后可以参与房源优先显示。优显页面分别为首页、搜索结果页。优显方式是：所有参与优显的房源在上述相应页面依次滚动显示。房源优显收费标准为每天%@元，用户应以%@元的倍数交纳费用。房源优显在用户交费的第二天生效，费用用完即止，再付费再参与。如遇收费标准调整，用户按交费当时的标准执行。
    """
    
    private static func basePlaceHolder(_ str: String) -> NSMutableAttributedString {
        let attach = NSTextAttachment()
        attach.image = UIImage(named: "home_search")
        attach.bounds = CGRect(x: 10, y: -1, width: 12, height: 12)
        let imgSrt = NSAttributedString(attachment: attach)
        let attStr = NSMutableAttributedString(string: str, attributes: [
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0xA3A3A3),
            NSAttributedString.Key.font : dzy_Font(13)
            ])
        attStr.insert(imgSrt, at: 0)
        attStr.addAttributes([NSAttributedString.Key.kern : 15], range: NSRange(location: 0, length: 2))
        return attStr
    }
    
    /// 获取系统配置
    static func sysConfigIntValue(_ key: SysConfigKey) -> Int? {
        if let strValue = DataManager.sysConfig()?.stringValue(key.rawValue) {
            return Int(strValue)
        }else {
            return DataManager.sysConfig()?.intValue(key.rawValue)
        }
    }
    
    static func sysConfigDoubleValue(_ key: SysConfigKey) -> Double? {
        if let strValue = DataManager.sysConfig()?.stringValue(key.rawValue) {
            return Double(strValue)
        }else {
            return DataManager.sysConfig()?.doubleValue(key.rawValue)
        }
    }
    
    static func sysConfigStringValue(_ key: SysConfigKey) -> String? {
        if let intValue = DataManager.sysConfig()?.intValue(key.rawValue) {
            return String(intValue)
        }else {
            return DataManager.sysConfig()?.stringValue(key.rawValue)
        }
    }
    
    /// 更新城市配置
    static func updateCityConfig(_ complete: @escaping ([String : Any]?)->()) {
        let request = BaseRequest()
        request.url = BaseURL.cityConfig
        request.dic = ["city" : RegionManager.city()]
        request.start { (data, error) in
            complete(data)
        }
    }
    
    /// 更新系统配置
    static func updateSysConfig(_ complete: (([String : Any]?)->())? = nil) {
        let request = BaseRequest()
        request.url = BaseURL.sysConfig
        request.dic = ["city" : RegionManager.city()]
        request.start { (data, error) in
            DataManager.saveSysConfig(data?.dicValue("sysConfig"))
            complete?(data)
        }
    }
}

enum UserAllType: String {
    /// 买家培训
    case buyTrain = "buyTrainType"
    /// 买家看房押金
    case buyLookHouse = "buyLookType"
    /// 买家交易保证金
    case buyDeposit = "buyCashType"
    /// 卖家培训
    case sellTrain = "sellTrainType"
    /// 卖家交易保证金
    case sellDeposit = "sellCashType"
    /// 卖家门锁押金
    case sellLook = "sellLookType"
}

enum UserOperateType: Int {
    /// 双因子
    case twoFactor = 10
//    /// 买房诚意
//    case buySincerity = 20
//    /// 卖房诚意
//    case sellSincerity = 30
    /// 购房资格
    case buyZiGe = 40
    /// 售房确认
    case sellVerify = 50
    /// 修改密码
    case updatePwd = 60
    /// 忘记密码（设置密码）
    case setPwd = 70
    /// 修改电话
    case updatePhone = 80
}

struct PublicFunc {
    /// 更新用户信息
    static func updateUserDetail(_ handler: @escaping (_ userInfo: [String : Any]?, _ tradeInfo: [String : Any]?, _ data: [String : Any]) -> ()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.userDetail
        request.isUser = true
        request.start { (data, _) in
            if let data = data {
                let user = data.dicValue("user")
                let info = data.dicValue("amount")
                let isPwd = data.intValue("isPassword")
                DataManager.saveUser(user)
                DataManager.saveIsPwd(isPwd == 1)
                handler(user, info, data)
            }
        }
    }
    
    /// 获取未读消息
    static func unreadMsgNumApi(_ handler: @escaping (Int) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.userDetail
        request.isUser = true
        request.start { (data, _) in
            if let data = data {
                let user = data.dicValue("user")
                let isPwd = data.intValue("isPassword")
                DataManager.saveUser(user)
                DataManager.saveIsPwd(isPwd == 1)
                handler(data.intValue("userUnReadNum") ?? 0)
            }
        }
    }
    
    /// 后台线程上传图片 (如果上传失败，会再上传一次)
    static func bgUploadApi(_ imgData: Data, success: @escaping (String?)->()) {
        var count: Int = 0
        let request = BaseRequest()
        request.url = BaseURL.uploadPic
        request.dic = ["img" : imgData]
        request.uploadImg { (data, _) in
            if data == nil && count == 0 {
                PublicFunc.uploadApi(imgData, success: { (url, _) in
                    success(url)
                })
                count += 1
            }else {
                success(data)
            }
        }
    }
    
    /// 普通上传
    static func uploadApi(
        _ imgData: Data,
        isHud: Bool = false,
        success: @escaping (String?, String?)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.uploadPic
        request.dic = ["img" : imgData]
        if isHud {
            ZKProgressHUD.show()
        }
        request.uploadImg { (data, error) in
            ZKProgressHUD.dismiss()
            success(data, error)
        }
    }
    
    /// 切换身份 10 买家 20 卖家
    static func changeIdentityApi(_ type: Int, handler:((Bool)->())? = nil) {
        let request = BaseRequest()
        request.url = BaseURL.changeIdentity
        request.dic = ["userType" : type]
        request.isUser = true
        request.start { (data, _) in
            handler?(data != nil)
        }
    }
    
    /// 跳过交易流程培训
    static func jumpTrainApi(_ type: Int) {
        let request = BaseRequest()
        request.url = BaseURL.jumpTrain
        request.dic = ["type" : type]
        request.isUser = true
        request.start { (_, _) in
            
        }
    }
    
    /// 查看各种状态
    static func checkPayOrTrain(
        _ type: UserAllType,
        userId: Int? = nil,
        success: @escaping (Bool, [String : Any]?)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.payOrTrainType
        if let userId = userId {
            request.dic = ["userId" : userId]
        }else {
            request.isUser = true
        }
        request.start { (data, _) in
            success(data?.intValue(type.rawValue) == 1, data)
        }
    }
    
    // 发送验证码 登录 20，认证 30， 其他的都是 10
    static func sendVerCodeApi(
        _ mobile: String, type: Int,
        result: @escaping ([String : Any]?, String?) -> ()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.sendVerCode
        request.dic = [
            "valid"  : "600",
            "type"   : type,
            "mobile" : mobile
        ]
        request.start { (data, error) in
            result(data, error)
        }
    }
    
    // 用户行为留存
    static func userOperFooter(_ type: UserOperateType,
                               houseId: Int? = nil,
                               msg: [String : Any] = [:],
                               isUser: Bool = false) {
        var temp = msg
        if isUser {
            temp["userId"] = DataManager.getUserId()
        }
        
        let key = "msg"
        switch type {
        case .sellVerify:
            temp[key] = "房产未查封、拥有出售资格"
        case .buyZiGe:
            temp[key] = "买方购房资格确认书"
        case .updatePhone:
            temp[key] = "修改手机号"
        case .updatePwd:
            temp[key] = "修改密码"
        case .setPwd:
            temp[key] = "设置密码"
        case .twoFactor:
            break
        }
        var dic: [String : Any] = [
            "type" : type.rawValue,
            "phoneModel" : dzy_phoneMsg(),
            "content" : ToolClass.toJSONString(dict: temp)
        ]
        if let houseId = houseId {
            dic["houseId"] = houseId
        }
        let request = BaseRequest()
        request.url = BaseURL.userOperFooter
        request.dic = dic
        request.isUser = true
        request.start { (_, _) in
            
        }
    }

    //MARK: -  密码检测
    static func encryptPwd(_ pwd: String) -> String? {
        let regEx = #"^(?![\d]+$)(?![a-zA-Z]+$)(?!^.*[\u4E00-\u9FA5].*$)(?![^\da-zA-Z]+$).\S{5,15}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        if predicate.evaluate(with: pwd) {
            var result = String((pwd + "Qx1024").reversed())
            result = ToolClass.md5(result).lowercased()
            result = ToolClass.md5(result).lowercased()
            return result
        }else {
            return nil
        }
    }
}
