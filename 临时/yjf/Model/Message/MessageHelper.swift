//
//  MessageType.swift
//  YJF
//
//  Created by edz on 2019/7/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

enum MessageType: Int {
    /// 即时消息
    case jsxx = 100
    /// 交易提醒
    case jytx = 90
    /// 事务预约
    case swyy = 80
    /// 竞价更变
    case jjbg = 50
    /// 操作指导
    case czzd = 40
    /// 成交通告
    case cjbg = 20
    /// 系统消息
    case xtxx = 10
    
    func name() -> String {
        switch self {
        case .jsxx:
            return "即时消息"
        case .jytx:
            return "交易提醒"
        case .swyy:
            return "事务预约"
        case .jjbg:
            return "竞价更变"
        case .czzd:
            return "操作指导"
        case .cjbg:
            return "成交通告"
        case .xtxx:
            return "系统消息"
        }
    }
    
    func image() -> String {
        switch self {
        case .jsxx:
            return "msg_icon_jishi"
        case .jytx:
            return "msg_icon_jiaoyi"
        case .swyy:
            return "msg_icon_shiwu"
        case .jjbg:
            return "msg_icon_jingjia"
        case .czzd:
            return "msg_icon_caozuo"
        case .cjbg:
            return "msg_icon_chengjiao"
        case .xtxx:
            return "msg_icon_xitong"
        }
    }
}

struct MessageHelper {
    static func time(_ str: String?) -> String? {
        guard let result = str else {return nil}
        let today = dzy_date8().description
        guard let reFirst = result.components(separatedBy: " ").first,
            reFirst.count > 5,
            let toFirst = today.components(separatedBy: " ").first
        else {
            return nil
        }
        if reFirst == toFirst {
            if let temp = result.components(separatedBy: " ").last,
                temp.count > 5
            {
                let index = temp.index(temp.startIndex, offsetBy: 5)
                return "今天 " + String(temp[..<index])
            }else {
                return nil
            }
        }else {
            let index = reFirst.index(reFirst.startIndex, offsetBy: 5)
            return String(reFirst[index...])
        }
    }
    
    static func openParameList(_ str: String) -> [String : String] {
        let arrList = str.components(separatedBy: "&&")
        var result: [String : String] = [:]
        for s in arrList {
            let arr = s.components(separatedBy: "=")
            guard arr.count == 2 else {continue}
            result[arr[0]] = arr[1]
        }
        return result
    }
}
