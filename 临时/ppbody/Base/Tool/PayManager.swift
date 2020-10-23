//
//  PayLogic.swift
//  HousingMarket
//
//  Created by 朱帅 on 2019/1/9.
//  Copyright © 2019 远坂凛. All rights reserved.
//

import Foundation

/// 支付方式
enum PayMode {
    case alipay(order: String)
    case wechat(info: [String : Any])
}

class PayManager {
        
    private var dic: [String : Any]?
    
    func start(_ mode: PayMode)  {
        switch mode {
        case .alipay(let order):
            alipayAction(order)
        case .wechat(let info):
            wechatAction(info)
        }
    }
    
    fileprivate func alipayAction(_ info: String) {
        guard info != "" else {
            ToolClass.showToast("非法的URL，请检查", .Failure)
            return
        }
//        let str = info.replacingOccurrences(of: "+", with: " ")
        AlipaySDK.defaultService()?.payOrder(
            info,
            fromScheme: "ppbody",
            callback: { (_) in
                dzy_log("成功")
//                let resultdic = resultDic as? [String:Any]
//                self.tradeNo = resultdic["trade_no"] as? String ?? ""
        })
    }
    
    fileprivate func wechatAction(_ info: [String : Any]) {
        guard let appid     = info.stringValue("appid"),
            let partnerid   = info.stringValue("partnerid"),
            let prepayid    = info.stringValue("prepayid"),
            let noncestr    = info.stringValue("noncestr"),
            let temp        = info.stringValue("timestamp"),
            let timestamp   = UInt32(temp),
            let package     = info.stringValue("package"),
            let sign        = info.stringValue("sign")
        else {
            ToolClass.showToast("非法的支付数据，请检查", .Failure)
            return
        }
        let req = PayReq()
        req.openID = appid
        req.partnerId = partnerid
        req.prepayId = prepayid
        req.nonceStr = noncestr
        req.timeStamp = timestamp
        req.package = package
        req.sign = sign
        WXApi.send(req)
    }
}
