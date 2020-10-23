//
//  TimeTableModel.swift
//  PPBody
//
//  Created by edz on 2019/4/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import Foundation

class TimeTableModel {
    // 房间名
    var name: String = ""
    // 时间段
    var times: [String] = []
    // 具体课程 key 为 times 中的字段  value 默认为 count = 7 的空数组 (对应星期一到星期天)
    var classes: [String : [[String : Any]?]] = [:]

    static func dealWithData(_ list: [[String : Any]]) -> [TimeTableModel] {
        var temp = list
        var arr = [TimeTableModel]()
        var names = Set<String>()
        temp.sort(by: {($0.intValue("start") ?? 0) < ($1.intValue("start") ?? 0)})
        temp.forEach { (dic) in
            let start = dic.intValue("start") ?? 0
            let end = dic.intValue("end") ?? 0
            let sStr = ToolClass.getTimeStr(start)
            let eStr = ToolClass.getTimeStr(end)
            // 时间的 key
            let timeKey = sStr + "-" + eStr
            // 星期几
            let week = dic.intValue("week") ?? 1
            //名字
            let name = dic.stringValue("spaceName") ?? ""
            
            // 已经存在对应房间
            if names.contains(name) {
                if let index = arr.firstIndex(where: {$0.name == name}) {
                    let model = arr[index]
                    // 已经有当前时间段的数组
                    if model.times.contains(timeKey) {
                        model.classes[timeKey]?[week - 1] = dic
                    }else {
                        // 还没有当前时间段的数组
                        model.times.append(timeKey)
                        var classArr = [[String : Any]?](repeating: nil, count: 7)
                        classArr[week - 1] = dic
                        model.classes.updateValue(classArr, forKey: timeKey)
                    }
                }
            }else {
                // 课程数组(先初始化为 7 个nil)
                var classArr = [[String : Any]?](repeating: nil, count: 7)
                classArr[week - 1] = dic
                
                let model = TimeTableModel()
                model.name = name
                model.times = [timeKey]
                model.classes = [timeKey : classArr]
                arr.append(model)
                names.insert(name)
            }
        }
        return arr
    }
}
