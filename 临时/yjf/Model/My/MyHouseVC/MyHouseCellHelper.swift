//
//  MyHouseCellHelper.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

enum MyHouseCellAction: Int {
    /// 发布房源
    case release = 10
    /// 添加报价
    case addPrice
    /// 拆锁
    case unLock
    /// 装锁
    case lock
    /// 装锁 但是没有保证金
    case lock_nodeposit
    /// 撤销
    case undo
    /// 缴纳保证金
    case buyDeposit = 16
    /// 交易进展
    case progress = 17
    /// 编辑
    case edit = 18
}

struct MyHouseCellHelper {
    
    static let redColor = dzy_HexColor(0xFF3A3A)
    
    static let greenColor = dzy_HexColor(0x26CC85)
    
    static let orangeColor = dzy_HexColor(0xFD7E25)
    
    static let blackColor = dzy_HexColor(0x262626)
    
    /// 编辑
    static func editBtn(_ btn: UIButton) {
        btn.tag = MyHouseCellAction.edit.rawValue
    }
    
    /// 发布
    static func releaseBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_release"), for: .normal)
        btn.setTitle("发布房源", for: .normal)
        btn.setTitleColor(greenColor, for: .normal)
        btn.tag = MyHouseCellAction.release.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = greenColor.cgColor
    }
    
    /// 添加报价
    static func priceBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_baojia"), for: .normal)
        btn.setTitle("添加报价", for: .normal)
        btn.setTitleColor(greenColor, for: .normal)
        btn.tag = MyHouseCellAction.addPrice.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = greenColor.cgColor
    }
    
    /// 拆锁
    static func unlockBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_unlock"), for: .normal)
        btn.setTitle("申请拆锁", for: .normal)
        btn.setTitleColor(orangeColor, for: .normal)
        btn.tag = MyHouseCellAction.unLock.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = orangeColor.cgColor
    }
    
    /// 装锁
    static func lockBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_lock"), for: .normal)
        btn.setTitle("申请装锁", for: .normal)
        btn.setTitleColor(orangeColor, for: .normal)
        btn.tag = MyHouseCellAction.lock.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = orangeColor.cgColor
    }
    
    /// 装锁，但是没有保证金
    static func noDepositBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_lock"), for: .normal)
        btn.setTitle("申请装锁", for: .normal)
        btn.setTitleColor(orangeColor, for: .normal)
        btn.tag = MyHouseCellAction.lock_nodeposit.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = orangeColor.cgColor
    }
    
    /// 撤销房源
    static func undoBtn(_ btn: UIButton) {
        btn.setImage(UIImage(named: "my_house_cexiao"), for: .normal)
        btn.setTitle("撤销房源", for: .normal)
        btn.setTitleColor(orangeColor, for: .normal)
        btn.tag = MyHouseCellAction.undo.rawValue
        setCornerRadius(btn)
        btn.layer.borderColor = orangeColor.cgColor
    }
    
    /// 锁状态
    static func lockTypeLB(_ lb: UILabel, type: MyHouseType.LockType) {
        switch type {
        case .unInstall, .removed, .noDeposit, .installFail:
            lb.text = "未安装"
            lb.textColor = blackColor
        case .installing:
            lb.text = "待安装"
            lb.textColor = orangeColor
        case .installSuccess:
            lb.text = "已安装"
            lb.textColor = greenColor
        case .canRemove:
            lb.text = "待拆除"
            lb.textColor = redColor
        case .removing:
            lb.text = "拆除中"
            lb.textColor = redColor
        case .replacing:
            lb.text = "换锁中"
            lb.textColor = redColor
        }
    }
    
    /// 房源状态
    static func typeLB(_ lb: UILabel, type: MyHouseType) {
        switch type {
        case .waitAudit:
            lb.text = "待审核"
            lb.textColor = orangeColor
        case .auditSuccess:
            lb.text = "待发布"
            lb.textColor = redColor
        case .released:
            lb.text = "已发布"
            lb.textColor = greenColor
        case .traded:
            lb.text = "已成交"
            lb.textColor = greenColor
        case .auditFail:
            lb.text = "审核失败"
            lb.textColor = orangeColor
        case .undo:
            lb.text = "已撤销"
            lb.textColor = redColor
        case .signed:
            lb.text = "已签约"
            lb.textColor = blackColor
        case .end:
            lb.text = "已具结"
            lb.textColor = blackColor
        }
    }
    
    /// 每个状态对应的高度
    static func cellHeight(_ type: MyHouseType) -> CGFloat {
        switch type {
        case .waitAudit(_, let isDeposit, _),
             .auditSuccess(_, let isDeposit, _),
             .released(_, let isDeposit, _):
            return isDeposit ? 163 : 198
        case .undo, .auditFail:
            return 163
        case .traded:
            return 240
        case .signed(let type):
            return type == MyHouseType.LockType.removed ? 215 : 240
        case .end(let type):
            return type == MyHouseType.LockType.removed ? 188 : 213
        }
    }
    
    private static func setCornerRadius(_ btn: UIButton) {
        btn.layer.cornerRadius = 3
        btn.layer.borderWidth = 1
    }
}
