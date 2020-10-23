//
//  TPPHelper.swift
//  PPBody
//
//  Created by edz on 2020/6/15.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import Foundation

//MARK: - 枚举
/**
 这里 edit 的 dataArr 数据格式与 play 和 playSelf 是一样的
 但是界面显示有差异，主要在于可以删除
 
 然后最后接口提交的数据，edit 和 new 的数据格式是一样的
 所以相关的判断有点多
 */

public enum TrainPlanShowType {
    /// 创建计划界面
    case new
    /// 计划锻炼
    case play(pid : Int)
    /// 自主锻炼
    case playSelf
    /// 计划编辑
    case planEdit(pid: Int)
    /// 训练记录编辑
    case hisEdit(detail: [String : Any])
}

/**
 SourceView 取值时的 type
 */

public enum TPPValueType {
    // 正常状态
    case normal
    // 这个状态只返回选中的
    case selected
    // 这个状态会带回去 targetId
    case edit
}

/**
    TPPlayView  的类型
 */
public enum TPPlayViewType {
    /// 计次（常规）
    case normal
    /// 计时（有氧）
    case cardio
    /// 跑步（跑步单独需要个 km）
    case run
    
    func defaultValue() -> [String : Any] {
        switch self {
        case .normal:
            return [
                "freNum" : 0,
                "weight" : 0.0,
                "rest" : 0
            ]
        case .cardio:
            return [
                "time" : 0,
                "rest" : 0
            ]
        case .run:
            return [
                "time" : 0,
                "distance" : 0.0,
                "rest" : 0
            ]
        }
    }
    
    static func checkType(_ motion: [String : Any]?) -> TPPlayViewType {
        guard let motion = motion else {
            return .normal
        }
        if motion.intValue("id") == 149 {
            return .run
        }else if motion.intValue("type") == 20 {
            return .cardio
        }else {
            return .normal
        }
    }
    
    static func hisCheckType(_ motion: [String : Any]?) -> TPPlayViewType
    {
        guard let motion = motion else {
            return .normal
        }
        if motion.intValue("motionId") == 149 {
            return .run
        }
        let dic = motion.arrValue("list")?.first ?? [:]
        let freNum = dic.intValue("freNum") ?? 0
        let time = dic.doubleValue("time") ?? 0
        if freNum > 0 {
            return .normal
        }else if time > 0 {
            return .cardio
        }else {
            return .normal
        }
    }
}
