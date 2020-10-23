//
//  CzzdJumpProtocol.swift
//  YJF
//
//  Created by edz on 2019/8/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol CzzdMsgProtocol {
    func czzdShowMsg(_ data: [String : Any]) -> String?
    func czzdGetTypeMsg(_ type: String) -> String
}

extension CzzdMsgProtocol {
    func czzdShowMsg(_ data: [String : Any]) -> String? {
        guard var content = data.stringValue("content") else {
            return nil
        }
        if data.intValue("skipType") == 57,
            let type = data.stringValue("parameList")?
                .components(separatedBy: "=").last
        {
            content = content.replacingOccurrences(
                of: "【${目标页面}】", with: czzdGetTypeMsg(type)
            )
        }
        return content
    }
    
    func czzdGetTypeMsg(_ type: String) -> String {
        //20.看房押金, 30.交易保证金  40.添加房源  50.门锁押金  60.申请装锁  70.交易保证金[卖方
        switch type {
        case "20":
            return "缴纳看房押金"
        case "30":
            return "缴纳买方交易保证金"
        case "40":
            return "添加房源"
        case "50":
            return "缴纳门锁押金"
        case "60":
            return "申请装锁"
        case "70":
            return "缴纳卖方交易保证金"
        default:
            return ""
        }
    }
}

protocol CzzdJumpProtocol where Self: UIViewController {
    func czzdAction(_ type: String)
}

extension CzzdJumpProtocol {
    func czzdAction(_ type: String) {
        //20.看房押金, 30.交易保证金  40.添加房源  50.门锁押金  60.申请装锁  70.交易保证金[卖方
        switch type {
        case "20", "30":
            checkIdentity(.buyer) { [unowned self] (result) in
                if result {
                    IDENTITY = .buyer
                    let vc = PayBuyDepositVC(.normal)
                    self.dzy_push(vc)
                }
            }
        case "50", "70":
            checkIdentity(.seller) { [unowned self] (result) in
                if result {
                    IDENTITY = .seller
                    let vc = PaySellDepositVC(.normal)
                    self.dzy_push(vc)
                }
            }
        case "40":
            checkIdentity(.seller) { [unowned self] (result) in
                if result {
                    IDENTITY = .seller
                    let vc = AddHouseBaseVC(RegionManager.cityId())
                    self.dzy_push(vc)
                }
            }
        case "60":
            checkIdentity(.seller) { [unowned self] (result) in
                if result {
                    IDENTITY = .seller
                    let vc = MyHouseVC()
                    self.dzy_push(vc)
                }
            }
        default:
            break
        }
    }
    
    private func checkIdentity(_ type: Identity, handler: @escaping (Bool) -> ()) {
        if type == .buyer && IDENTITY == .seller {
            let alert = dzy_normalAlert("提示", msg: "执行该操作需要切换至买家身份，是否继续", sureClick: { (_) in
                PublicFunc.changeIdentityApi(20, handler: handler)
            }) { (_) in
                handler(false)
            }
            present(alert, animated: true, completion: nil)
        }else if type == .seller && IDENTITY == .buyer {
            let alert = dzy_normalAlert("提示", msg: "执行该操作需要切换至卖家身份，是否继续", sureClick: { (_) in
                PublicFunc.changeIdentityApi(10, handler: handler)
            }) { (_) in
                handler(false)
            }
            present(alert, animated: true, completion: nil)
        }else {
            handler(true)
        }
    }
}
