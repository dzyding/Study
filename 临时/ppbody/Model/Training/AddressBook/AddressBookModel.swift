//
//  StudentUserModel.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StudentUserModel: NSObject
{
    // 名字
    var name: String?
    // 备注
    var remark: String?
    //身体信息
    var body: String?
    // 拼音
    var char: String?
    // 头像
    var head: String?
    // auth
    var uid: String?
    
    var sex: Int?
    
    var type: Int?
    
    
    override init() {
        super.init()
    }
    
    init(name: String?, head: String? = nil, uid: String? = nil, sex: Int?  = nil, type: Int?  = nil, remark: String? = nil, body: String? = nil) {
        self.name = name
        self.head = head
        self.uid = uid
        self.sex = sex
        self.type = type
        self.char = ToolClass.findFirstLetterFromString(aString: name!)
        self.remark = remark
        self.body = body
    }
    
    
    // MARK:- 将联系人进行排序和分组操作
    class func getMemberListData(by array: [StudentUserModel]) -> [[StudentUserModel]] {
        // 排序 (升序)
        let serializedArr = array.sorted { $0.char! < $1.char! }
        var ans = [[StudentUserModel]]()
        var lastC = serializedArr.count>0 ? serializedArr[0].char : "-1"
        var data = [StudentUserModel]()
        // 分组
        for model in serializedArr
        {
           if model.char == lastC
           {
              data.append(model)
           }else{
            lastC = model.char
            ans.append(data)
            data = [StudentUserModel]()
            data.append(model)
            }
        }
        if data.count != 0
        {
            ans.append(data)
        }
        
        if ans.count>0
        {
            let first = ans[0]
            if !(first.first?.char?.isAlpha())!
            {
                ans.remove(at: 0)
                ans.append(first)
            }
        }
        
        return ans
    }
    
    // 获取索引
    class func getFriendListSection(by array: [[StudentUserModel]]) -> [String] {
        var section = [String]()
//        section.append(UITableViewIndexSearch) // 添加放大镜
        for item in array {
            let user = item.first
            var c = user?.char
            if !(c?.isAlpha())! {
                c = "#"
            }
            section.append((c?.uppercased())!)
        }
        return section
    }
    
    func getUserDic()->[String:Any]
    {
        var dic = [String:Any]()
        dic["nickname"] = self.name
        dic["head"] = self.head
        dic["uid"] = self.uid
        dic["sex"] = self.sex
        dic["type"] = self.type
        return dic
    }
}
