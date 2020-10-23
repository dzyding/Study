//
//  JumpHouseDetailProtocol.swift
//  YJF
//
//  Created by edz on 2019/8/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol JumpHouseDetailProtocol where Self: UIViewController {
    func goHouseDetail(_ isBid: Bool, house: [String : Any])
}

extension JumpHouseDetailProtocol {
    func goHouseDetail(_ isBid: Bool, house: [String : Any]) {
        let houseId = house.intValue("id") ?? 0
        let vc = HouseDetailVC(houseId)
        vc.isDeal = house.isOrderSuccess()
        if isBid {
            vc.firstShowIndex = 1
        }
        dzy_push(vc)
    }
}
