//
//  DataManager.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/21.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit

//extension UserDefaults {
//
//    private static var base:UserDefaults {
//        return UserDefaults.standard
//    }
//
//    static var name: String? {
//        set {base.set(newValue, forKey: #function)}
//        get {return base.string(forKey: #function)}
//    }
//}

class DataManager: NSObject {
   static let version = "_v1"

    /// 存储用户信息
    static func saveUser(_ user: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(dzy_safe(user), forKey: "user" + version)
        userDefaults.synchronize()
    }
    
    /// 获取用户信息
    static func user() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "user" + version)
    }
    
    /// 是否设置过密码
    static func saveIsPwd(_ isPwd: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isPwd, forKey: "ispwd" + version)
        userDefaults.synchronize()
    }
    
    /// 判断是否设置过密码
    static func isPwd() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "ispwd" + version)
    }
    
    /// 是否从推送进入
    static func saveIsPush(_ isPush: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isPush, forKey: "ispush" + version)
        userDefaults.synchronize()
    }
    
    static func isPush() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "ispush" + version)
    }
    
    /// 储存成交信息
    static func saveDealMsg(_ data: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "dzy_deal" + version)
        userDefaults.synchronize()
    }
    
    /// 成交信息
    static func dealMsg() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "dzy_deal" + version)
    }
    
    /// 储存竞价信息
    static func saveBidMsg(_ data: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "dzy_bid" + version)
        userDefaults.synchronize()
    }
    
    /// 竞价信息
    static func bidMsg() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "dzy_bid" + version)
    }
    
    /// 撤销竞价信息
    static func saveUndoMsg(_ dic: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(dic, forKey: "dzy_undo" + version)
        userDefaults.synchronize()
    }
    
    /// 获取
    static func undoMsg() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "dzy_undo" + version)
    }
    
    /// 流程培训相关的入口
    static func saveTrainNextJump(_ type: TrainNextJumpType) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(type.rawValue, forKey: "jumptype" + version)
        userDefaults.synchronize()
    }
    
    ///
    static func trainNextJump() -> TrainNextJumpType? {
        let userDefaults = UserDefaults.standard
        let typeInt = userDefaults.integer(forKey: "jumptype" + version)
        return TrainNextJumpType(rawValue: typeInt)
    }
    
    /// 任务配置列表
    static func saveEvaluateConfig(_ dic: [String : Any]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(dzy_safe(dic), forKey: "evaluateConfig" + version)
        userDefaults.synchronize()
    }
    
    static func evaluateConfig() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "evaluateConfig" + version)
    }
    
    /// 是否已经暂时过引导图
    static func saveIsGuide(_ isGuide: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isGuide, forKey: "isguide" + version)
        userDefaults.synchronize()
    }
    
    static func isGuide() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "isguide" + version)
    }
    
    /// 当前 HOST
    static func saveHost(_ host: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(host, forKey: "host" + version)
        userDefaults.synchronize()
    }
    
    static func host() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: "host" + version)
    }
    
    /// 存储系统配置
    static func saveSysConfig(_ config: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(dzy_safe(config), forKey: "sysconfig" + version)
        userDefaults.synchronize()
    }
    
    
    static func sysConfig() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "sysconfig" + version)
    }
    
    /// 员工 code
    static func saveStaffMsg(_ dic: [String : Any]?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(dic, forKey: "staffMsg")
        userDefaults.synchronize()
    }
    
    static func staffMsg() -> [String : Any]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "staffMsg")
    }
    
    /// 储存登陆时间
    static func saveLoginDate(_ date: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "logindate" + version)
        userDefaults.synchronize()
    }
    
    static func loginDate() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: "logindate" + version)
    }
    
    /// 是否正在看房
    static func saveIsInHouse(_ isInHouse: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isInHouse, forKey: "inhouse" + version)
        userDefaults.synchronize()
    }
    
    static func isInHouse() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "inhouse" + version)
    }
    
    //判断是否登录
    static func isLogin() -> Bool {
        return DataManager.user() != nil
    }
    
    //登出去
    static func logout() {
        let userDefaults = UserDefaults.standard
        [
            "user" + version, "ispush" + version,
            "dzy_deal" + version, "dzy_bid" + version,
            "dzy_undo" + version, "jumptype" + version,
            "host" + version, "sysconfig" + version
        ].forEach { (key) in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    //获取用户ID
    static func getUserId() -> Int{
        return DataManager.user()?.intValue("id") ?? -99
    }
    
    //获取用户手机号
    static func getUserPhone() -> String{
        return DataManager.user()?.stringValue("mobile") ?? ""
    }

}
