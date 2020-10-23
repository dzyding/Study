//
//  DataManager.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2016/12/11.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit
class DataManager{
    
    static let version = "_v1"
    
    //存储用户信息
    static func saveUserInfo(_ user : Dictionary<String, Any>)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(user, forKey: "user" + version)
        userDefaults.synchronize()
    }
    
    //获取用户信息
    static func userInfo() -> Dictionary<String, Any>?
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "user" + version)
    }
    
    //判断是否登录
    static func isLogin() -> Bool
    {
        return DataManager.userInfo() != nil
    }
    
    //获取用户的认证ID
    static func userAuth()->String
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        if user != nil
        {
            return "\(user!["uid"] as! String)"
        }else
        {
            return ""
        }
    }
    
    //获取用户 saasId
    static func smid() -> Int {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        return user?.intValue("smid") ?? 0
    }
    
    //刷新用户 saasId
    static func saveSmid(_ smid: Int) {
        if var user = DataManager.userInfo() {
            user.updateValue(smid, forKey: "smid")
            DataManager.saveUserInfo(user)
        }
    }
    
    //存储汗水
    static func changeSweat(_ sweat: Int) {
        let userDefaults = UserDefaults.standard
        if var user = userDefaults.dictionary(forKey: "user" + version) {
            user["sweat"] = sweat
            DataManager.saveUserInfo(user)
        }
    }
    
    static func getSweat() -> Int {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        return user?.intValue("sweat") ?? 0
    }
    
    //存储学员信息
    static func saveMemberInfo(_ member : Dictionary<String, Any>)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(member, forKey: "member" + version)
        userDefaults.synchronize()
    }
    
    //获取学员信息
    static func memberInfo() -> Dictionary<String, Any>?
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "member" + version)
    }
    
    //获取学员头像信息
    static func getMemberHead() -> String?
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "member" + version)
        return user?["head"] as? String
    }
    
    //获取学员性别
    static func getMemberSex() -> Int?
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "member" + version)
        if user == nil {
            return nil
        }
        return user?["sex"] as? Int
    }
    
    //移除学员信息
    static func removeMemberInfo()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "member" + version)
    }
    
    
    //选中学员的信息
    static func memberAuth() -> String
    {
        let memberDefaults = UserDefaults.standard
        let  member = memberDefaults.dictionary(forKey: "member" + version)
        if  member != nil
        {
            return "\( member!["uid"] as! String)"
        }else
        {
            return ""
        }
    }
    
    //判断是否为教练身份
    static func isCoach() -> Bool
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        if user != nil
        {
            let type = user!["type"] as! Int
            return type == 20 ? true : false
        }
        return false
    }
    
    //获取用户的手机号
    static func mobile() ->String
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        
        if user != nil
        {
            return "\(user!["mobile"]!)"
        }else
        {
            return ""
        }
    }   
   
    
    //修改用户头像
    static func changeHead_V3(_ head: String)
    {
        let userDefaults = UserDefaults.standard
        var user = userDefaults.dictionary(forKey: "user" + version)
        user?["head"] = head
        DataManager.saveUserInfo(user!)
    }
    
    //获取头像信息
    static func getHead() -> String?
    {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.dictionary(forKey: "user" + version)
        return user?["head"] as? String
    }
    
    //登出去
    static func logout()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "user" + version)
    }
    
    static func cleanUserInfo(){
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "user" + version)
    }
    

    //存储是否是第一次登录 1为第一次登录
    static func saveIsFirstToZAJA(_ isFirst : String){
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(isFirst, forKey: "isFirst" + version)
        userDefaults.synchronize()
    }
    
    //取出程序是否第一次登录的
    static func isFirst() -> String?
    {
        let userDefaults = UserDefaults.standard
        let object = userDefaults.value(forKey: "isFirst" + version)
        return object as? String
        
    }
    
    //清除第一次登录
    static func clearIsFirst(){
        
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "isFirst" + version)
    }
    
    //存储搜索历史
    static func saveHistorySearch(_ key : String)
    {
        let userDefaults = UserDefaults.standard
        var historys = userDefaults.array(forKey: "historys_search_key") as? [String]
        if historys == nil {
            historys = [String]()
        }
        //去重复数据
        for name in historys!
        {
            
            if name == key
            {
                return
            }
        }
        
        //最多20条记录
        if historys?.count == 10
        {
            historys?.removeLast()
        }
        
        historys?.insert(key, at: 0)
        userDefaults.set(historys, forKey: "historys_search_key")
        userDefaults.synchronize()
    }
    
    //获取搜索记录
    static func historySearch() -> [String]
    {
        let userDefaults = UserDefaults.standard
        let historys = userDefaults.array(forKey: "historys_search_key") as? [String]
        
        if historys == nil
        {
            return [String]()
        }
        
        return historys!
    }
    
    //清除搜索记录
    static func removeHistory()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "historys_search_key")
    }

    //存储搜索动作历史
    static func saveMotionHistorySearch(_ key : String)
    {
        let userDefaults = UserDefaults.standard
        var historys = userDefaults.array(forKey: "historys_motion_search_key") as? [String]
        if historys == nil {
            historys = [String]()
        }
        //去重复数据
        for name in historys!
        {
            
            if name == key
            {
                return
            }
        }
        
        //最多20条记录
        if historys?.count == 10
        {
            historys?.removeLast()
        }
        
        historys?.insert(key, at: 0)
        userDefaults.set(historys, forKey: "historys_motion_search_key")
        userDefaults.synchronize()
    }
    
    //获取动作搜索记录
    static func historyMotionSearch() -> [String]
    {
        let userDefaults = UserDefaults.standard
        let historys = userDefaults.array(forKey: "historys_motion_search_key") as? [String]
        
        if historys == nil
        {
            return [String]()
        }
        
        return historys!
    }
    
    //清除动作搜索记录
    static func removeMotionHistory()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "historys_motion_search_key")
    }
    
    //存储message 的通知消息
    static func saveMessageNotify(_ msg:[String:Any])
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(msg, forKey: "message_notify" + version)
        userDefaults.synchronize()
    }
    
    //获取 message 的通知消息
    static func messageNotify() -> [String:Any]?
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.dictionary(forKey: "message_notify" + version)
    }
    
    //是不是第一次点击推荐部落
    static func saveTribeTap(_ index: Int)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(index, forKey: "tribe_tap")
        userDefaults.synchronize()
    }
    
    //获取推荐部落点击事件
    static func tribeTap() -> Int
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: "tribe_tap")
    }
    
    //首次注册
    static func saveFirstRegister(_ index: Int)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(index, forKey: "firster_register")
        userDefaults.synchronize()
    }
    
    static func firstRegister() -> Int
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: "firster_register")
    }
    
    //消息推送
    static func saveNotifySwitch(_ index: Int)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(index, forKey: "notify_switch")
        userDefaults.synchronize()
    }
    
    static func notifySwitch() -> Int
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: "notify_switch")
    }
    
    //教练切换学员的指引
    static func saveFirstCoachMember(_ index: Int)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(index, forKey: "firster_coach_member")
        userDefaults.synchronize()
    }
    
    static func firstCoachMember() -> Int
    {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: "firster_coach_member")
    }
    
    //    MARK: - 保存投屏信息
    static func saveSplash(_ datas: [[String : Any]]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(datas, forKey: "splash_array")
        userDefaults.synchronize()
    }
    
    static func splashs() -> [[String : Any]]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.array(forKey: "splash_array") as? [[String : Any]]
    }
    
//    MARK: - 搜索健身房的历史记录
    static func saveLocationSearch(_ datas: [String]) {
        var temp = datas
        if temp.count > 10 {
            temp = Array(datas[(temp.count - 10)..<temp.count])
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(temp, forKey: "location_gym_search")
        userDefaults.synchronize()
    }
    
    static func locationSearchDatas() -> [String]? {
        let userDefaults = UserDefaults.standard
        return userDefaults.array(forKey: "location_gym_search") as? [String]
    }
}
