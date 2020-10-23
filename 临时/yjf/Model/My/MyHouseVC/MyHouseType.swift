//
//  MyHouseType.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation
import ZKProgressHUD

public let HouseTypeKey = "dzyType"

protocol HouseTypeDealable where Self: BaseVC {
    func dealHouseData(_ data: [String : Any]) -> MyHouseType?
    func typeBtnClickAction(_ data: [String : Any], type: MyHouseCellAction)
    func installLockApi(_ data: [String : Any])
}

extension HouseTypeDealable {
    func installLockApi(_ data: [String : Any]) {}
    
    func dealHouseData(_ data: [String : Any]) -> MyHouseType? {
        //是否缴纳保证金 0:未缴纳 1:缴纳
        let isDeposit = data.intValue("isGuaranteePrice") == 1
        // 5.没有门锁押金  10.待安装  20.安装中（已生成对应任务）25.装锁失败(和10对等) 30.安装成功 35.待拆锁 40.拆锁中（已生成对应任务）45.换锁中 50=10 (50 和 10可以理解成是一样的)
        let lockTypeInt = data.intValue("lockStatus") ?? 5
        //是否添加报价
        let isPrice = (data.arrValue("sellList")?.count ?? 0) > 0
        //01.待审核 02.待执行 03.执行中 04.通过 05.驳回  10.正常 15.成交  20.成交生效 30交易完成【房间售卖】   80.未生效房源  90：撤销房源
        let type = data.intValue("status") ?? 10
        
        var houseType: MyHouseType?
        // 锁类型
        let lockType = (MyHouseType.LockType(rawValue: lockTypeInt)) ?? MyHouseType.LockType.unInstall
        switch type {
        case (1...3): // 待审核
            houseType = .waitAudit(type: lockType,
                                   isDeposit: isDeposit,
                                   isPrice: isPrice)
        case 4: // 待发布(已审核)
            houseType = .auditSuccess(type: lockType,
                                      isDeposit: isDeposit,
                                      isPrice: isPrice)
        case 5: // 审核失败
            houseType = .auditFail(type: lockType)
        case 15, 20: // 已成交 (准确来说 20 是签约中)
            houseType = .traded
        case 30, 35: // 已签约
            houseType = .signed(type: lockType)
        case 40: // 已具结
            houseType = .end(type: lockType)
        case 80: // 说是没用
            break
        case 90: // 已撤销
            houseType = .undo(type: lockType)
        default: // 已发布
            houseType = .released(type: lockType, isDeposit: isDeposit, isPrice: isPrice)
        }
        return houseType
    }
    
    func typeBtnClickAction(_ data: [String : Any], type: MyHouseCellAction) {
        switch type {
        case .addPrice:
            data.intValue("id").flatMap({
                let vc = HouseDetailVC($0)
                vc.firstShowIndex = 1
                dzy_push(vc)
            })
        case .buyDeposit:
            switch IDENTITY {
            case .buyer:
                let vc = PayBuyDepositVC(.normal)
                dzy_push(vc)
            case .seller:
                let vc = PaySellDepositVC(.normal)
                dzy_push(vc)
            }
        case .lock:
            if let houseId = data.intValue("id") {
                let dic = [
                    "houseId" : houseId,
                    "type"    : 10 // 装锁
                ]
                let alert = dzy_normalAlert("提示", msg: "您确定要申请装锁么?", sureClick: { [weak self] (_) in
                    self?.installLockApi(dic)
                }, cancelClick: nil)
                present(alert, animated: true, completion: nil)
            }else {
                showMessage("房源信息错误")
            }
        case .lock_nodeposit:
            let vc = PaySellDepositVC(.notice(PublicConfig.Pay_Notice_Lock))
            vc.houseId = data.intValue("id")
            dzy_push(vc)
        case .unLock:
            if let houseId = data.intValue("id") {
                let dic = [
                    "houseId" : houseId,
                    "type"    : 30 // 拆锁
                ]
                let alert = dzy_normalAlert("提示", msg: "您确定要申请拆锁么?", sureClick: { [weak self] (_) in
                    self?.installLockApi(dic)
                    }, cancelClick: nil)
                present(alert, animated: true, completion: nil)
            }else {
                showMessage("房源信息错误")
            }
        case .release:
            let vc = AddHouseBaseVC(nil)
            vc.houseId = data.intValue("id") ?? 0
            dzy_push(vc)
        case .undo:
            let vc = UndoHouseVC(data)
            dzy_push(vc)
        case .progress:
            if let houseId = data.intValue("id"),
                let dealNo = data.dicValue("map")?
                    .stringValue("dealNo")
            {
                let vc = OrderProgressBaseVC(houseId, dealNo: dealNo)
                dzy_push(vc)
            }else {
                showMessage("房源信息错误")
            }
        case .edit:
            let vc = AddHouseBaseVC(nil, type: .edit)
            vc.houseId = data.intValue("id") ?? 0
            dzy_push(vc)
        }
    }
}

enum MyHouseType {
    // 5.没有门锁押金  10.待安装  20.安装中（已生成对应任务）25.装锁失败(和10对等) 30.安装成功 35.待拆锁 40.拆锁中（已生成对应任务）45.换锁中 50=10 (50 和 10可以理解成是一样的)
    enum LockType: Int {
        case noDeposit = 5
        /// 待安装
        case unInstall = 10
        /// 安装中
        case installing = 20
        /// 装锁失败
        case installFail = 25
        /// 安装成功
        case installSuccess = 30
        /// 待拆锁
        case canRemove = 35
        /// 拆除中
        case removing = 40
        /// 换锁中
        case replacing = 45
        /// 已拆除
        case removed = 50
    }

    ///待审核
    case waitAudit(type: LockType, isDeposit: Bool, isPrice: Bool)
    ///审核失败
    case auditFail(type: LockType)
    ///已审核
    case auditSuccess(type: LockType, isDeposit: Bool, isPrice: Bool)
    ///已发布
    case released(type: LockType, isDeposit: Bool, isPrice: Bool)
    ///已撤销
    case undo(type: LockType)
    ///已成交
    case traded
    ///已签约
    case signed(type: LockType)
    ///已具结
    case end(type: LockType)
}
