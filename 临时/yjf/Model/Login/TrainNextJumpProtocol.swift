//
//  TrainNextJumpProtocol.swift
//  YJF
//
//  Created by edz on 2019/6/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

enum TrainNextJumpType: Int {
    case none = 0
    case buyDeposit
    case sellDeposit
    case addHouse
}

protocol TrainNextJumpProtocol where Self: UIViewController {
    func checkTarinNextJump()
}

extension TrainNextJumpProtocol {
    func checkTarinNextJump() {
        if let type = DataManager.trainNextJump(),
            type != .none
        {
            switch type {
            case .addHouse:
                let vc = AddHouseBaseVC(RegionManager.cityId())
                dzy_push(vc)
            case .buyDeposit:
                let vc = PayBuyDepositVC(.normal)
                dzy_push(vc)
            case .sellDeposit:
                let vc = PaySellDepositVC(.normal)
                dzy_push(vc)
            default:
                break
            }
            DataManager.saveTrainNextJump(.none)
        }
    }
}
