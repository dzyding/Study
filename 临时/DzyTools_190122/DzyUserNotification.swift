//
//  DzyUserNotification.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/4/10.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

///检查是否允许通知
public func checkNotification(_ result:@escaping (Bool) -> ()) {
    if #available(iOS 10.0, *) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            //不允许 和 还未选择
            if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined  {
                result(false)
            }else {
                result(true)
            }
        }
    }else {
        if let setting = UIApplication.shared.currentUserNotificationSettings,
            setting.types != UIUserNotificationType(rawValue: 0)
        {
            result(true)
        }else {
            result(false)
        }
    }
}

///前往App设置界面
public func goToAppSetting() {
    //url = "prefs:root=---.SSA"  为跳转到手机通用的 通知的设置 界面
    if let url = URL(string: UIApplicationOpenSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                //UIApplicationOpenURLOptionUniversalLinksOnly 只有安装了app才跳转，没安装就不会跳转浏览器之类的
                UIApplication.shared.open(url, completionHandler: nil)
            }else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
