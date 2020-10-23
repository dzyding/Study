//
//  SimpleAppDelegate.swift
//  ZHYQ-FsZc
//
//  Created by edz on 2019/3/12.
//  Copyright © 2019 dzy. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import AMapFoundationKit

// swiftlint:disable line_length
class SimpleAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //    MARK: - Jpush
    var JPush_Key: String {
        return ""
    }
    
    var jPush: Bool {
        return false
    }
    
    //    MARK: - wx
    var wechatAppId: String {
        return ""
    }
    
    var wechatSecret: String {
        return ""
    }
    
    var wechatPay: Bool {
        return false
    }
    
    var wechatUrl: String {
        return ""
    }
    
    //    MARK: - 微博
    var weiboKey: String {
        return ""
    }
    
    var weiboSecret: String {
        return ""
    }
    
    //    MARK: - 支付宝
    var alipay: Bool {
        return false
    }
    
    //    MARK: - 高德
    var AMap_Key: String {
        return ""
    }
    
    var aMap: Bool {
        return false
    }
    
    //    MARK: - ShareSDK
    var share: Bool {
        return false
    }
    
    //    MARK: - Bugly
    var isBugly: Bool {
        return false
    }
    
    var Bugly_Key: String {
        return ""
    }
    //    MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool{
        UITextViewWorkaround.executeWorkaround()
        #if !targetEnvironment(simulator)
        if jPush {
              registJpush(launchOptions)
        }
        #endif
        
        if aMap {
            AMapServices.shared()?.apiKey = AMap_Key
        }
        
        if wechatPay {
            WXApi.registerApp(wechatAppId,
                              universalLink: wechatUrl)
        }
        
        if share {
            ShareSDK.registPlatforms { [unowned self] (platformsRegister) in
                platformsRegister?.setupWeChat(withAppId: self.wechatAppId, appSecret: self.wechatSecret, universalLink: self.wechatUrl)
                platformsRegister?.setupSinaWeibo(withAppkey: self.weiboKey, appSecret: self.weiboSecret, redirectUrl: HostManager.default.host)
            }
        }
        
        if isBugly {
            Bugly.start(withAppId: Bugly_Key)
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        NSSetUncaughtExceptionHandler { (exception) in
            dzy_log(exception)
        }
        
        window = UIWindow(frame: ScreenBounds)
        window?.rootViewController = baseVC()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if !targetEnvironment(simulator)
        if jPush {
            JPUSHService.registerDeviceToken(deviceToken)
        }
        #endif
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //极光注册失败
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        #if !targetEnvironment(simulator)
        if jPush {
            JPUSHService.handleRemoteNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
        #endif
    }

    // iOS 6
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        #if !targetEnvironment(simulator)
        if jPush {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        #endif
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if wechatPay && url.description.hasPrefix(wechatAppId) {
            return WXApi.handleOpen(url, delegate: self)
        }
        if alipay && url.host == "safepay" {
            AlipaySDK.defaultService()?.processOrder(
                withPaymentResult: url,
                standbyCallback: { [weak self] (result) in
                self?.alipayCheckResult(result)
            })
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if wechatPay {
            return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
        }
        return true
    }

    // 获取 rootVC
    func baseVC() -> UIViewController? {return nil}
    // 前台点击推送
    func clickPushFunc(_ userInfo: Any) {}
    
    //    MARK: - 注册极光
    func registJpush(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        let entity = JPUSHRegisterEntity()
        entity.types =
            Int(JPAuthorizationOptions.alert.rawValue) |
            Int(JPAuthorizationOptions.badge.rawValue) |
            Int(JPAuthorizationOptions.sound.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        JPUSHService.setup(withOption: launchOptions, appKey: JPush_Key, channel: "iOS", apsForProduction: false)
        
        let key = UIApplication.LaunchOptionsKey.remoteNotification
        if launchOptions?[key] != nil {
            DataManager.saveIsPush(true)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // 设置别名
        let userId = DataManager.getUserId()
        guard userId != -99 else {return}
        
        JPUSHService.setAlias("\(userId)yjf", completion: { (_, _, _) in
        }, seq: 1)
    }
    
    //    MARK: - 支付宝支付确认结果
    private func alipayCheckResult(_ data: [AnyHashable : Any]?) {
        guard let result = data?["resultStatus"] as? String else {
            return
        }
        var str: String?
        switch result {
        case "9000":
            NotificationCenter.default.post(name: PublicConfig.Notice_PaySuccess, object: nil)
        case "8000":
            str = "正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态"
        case "4000":
            str = "订单支付失败"
        case "5000":
            str = "支付失败，请勿重复请求！"
        case "6001":
            str = "您取消了支付"
        case "6002":
            str = "网络连接出错"
        case "6004":
            str = "支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态"
        default:
            str = "其它支付错误"
        }
        if let str = str {
            let alert = dzy_msgAlert("提示", msg: str)
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - JPUSHRegisterDelegate
extension SimpleAppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        if let noti = notification,
            noti.request.trigger is UNPushNotificationTrigger {
            //从通知界面直接进入应用
        }else {
            //从通知设置界面进入应用
        }
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userinfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            //前台收到消息
            JPUSHService.handleRemoteNotification(userinfo)
        }
        // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
        completionHandler(Int(JPAuthorizationOptions.alert.rawValue))
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userinfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            //前台点击消息
            clickPushFunc(userinfo)
            JPUSHService.handleRemoteNotification(userinfo)
        }
        completionHandler()
    }
}

extension SimpleAppDelegate: WXApiDelegate {
    func onReq(_ req: BaseReq) {
        dzy_log(req)
    }
    
    func onResp(_ resp: BaseResp) {
        if resp.isKind(of: PayResp.self) {
            switch resp.errCode {
            case 0 :
                print("支付成功")
                NotificationCenter.default.post(name: PublicConfig.Notice_PaySuccess, object: nil)
            default:
                let msg = "支付失败，请您重新支付!"
                let alert = UIAlertController(title: "支付结果", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (_) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }else {
            dzy_log("类型错误")
        }
    }
}
