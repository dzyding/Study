//
//  EvaluateHelper.swift
//  YJF
//
//  Created by edz on 2019/7/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

struct EvaluateHelper {
    
    static func houseName(_ house: inout [String : Any]) {
        let owner = house.boolValue("isOwner") ?? true
        let title = house.stringValue("houseTitle") ?? ""
        house["houseTitle"] = (owner ? "卖方：" : "买方：") + title
    }
    
    static func taskName(_ task: inout [String : Any]) {
        if var time = task.stringValue("createTime"),
            time.count > 5
        {
            let index = time.index(time.endIndex, offsetBy: -3)
            time = String(time[..<index])
            task["createTime"] = time
        }
        if let number = task.stringValue("number") {
            let dic = DataManager.evaluateConfig()?.dicValue(number)
            task["taskType"] = dic?.stringValue("taskType")
            task["name"] = dic?.stringValue("name")
        }
    }
    
    static func houseTaskList(_ data: [String : Any]) -> [[String : Any]] {
        let list = data.arrValue("list") ?? []
        var result:[[String : Any]] = []
        for var data in list {
            EvaluateHelper.houseTaskTimeFunc(&data)
            if let number = data.stringValue("number") {
                let dic = DataManager.evaluateConfig()?.dicValue(number)
                data["taskType"] = dic?.stringValue("taskType")
                data["name"] = dic?.stringValue("name")
            }
            result.append(data)
        }
        return result
    }
    
    private static func houseTaskTimeFunc(_ data: inout [String : Any]) {
        if var time = data.stringValue("createTime"),
            time.count > 0
        {
            let index = time.index(time.endIndex, offsetBy: -3)
            time = String(time[..<index])
            data["createTime"] = time
        }
    }
}
