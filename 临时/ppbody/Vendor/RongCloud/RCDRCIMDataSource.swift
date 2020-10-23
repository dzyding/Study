//
//  RCDRCIMDataSource.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/13.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RCDRCIMDataSource: NSObject {
    static let shared = RCDRCIMDataSource()
    
    
    func getUserInfo(_ userId: String, _ complete:@escaping (RCUserInfo)->())
    {
        
        if userId == "system"
        {
            let user = RCUserInfo()
            user.userId = "system"
            user.portraitUri = "https://oss.ppbody.com/logo.png"
            user.name = "PPbody小助手"
        
            complete(user)
            return
        }
        
        if Int(userId) != nil
        {
            let request = BaseRequest()
            request.url = BaseURL.UserInfo
            request.otherUid = ToolClass.encryptUserId(Int(userId)!)
            request.start { (data, error) in
                
                guard error == nil else
                {
                    //执行错误信息
                    return
                }
                
                
                let info = data!["info"] as! [String:Any]
                
                let user = RCUserInfo()
                user.userId = userId
                user.portraitUri = info["head"] as? String
                user.name = info["nickname"] as? String
                
                complete(user)
            }
        }
    }
}

extension RCDRCIMDataSource:RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource, RCIMGroupMemberDataSource
{
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        let user = RCUserInfo()
        if userId == nil
        {
            user.userId = userId
            user.portraitUri = ""
            user.name = ""
            completion(user)
            return
        }
        
        getUserInfo(userId, completion)
    }
    
    func getGroupInfo(withGroupId groupId: String!, completion: ((RCGroup?) -> Void)!) {
        
    }
    
    func getUserInfo(withUserId userId: String!, inGroup groupId: String!, completion: ((RCUserInfo?) -> Void)!) {
        
    }
    
    
}
