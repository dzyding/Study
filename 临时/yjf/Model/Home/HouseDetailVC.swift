//
//  HouseDetailVC.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseDetailVC: ScrollBtnVC, CustomBackProtocol {
    
    private let houseId: Int
    /// 已成交
    var isDeal: Bool = false
    /// 已撤销
    var isUndo: Bool = false
    
    init(_ houseId: Int) {
        self.houseId = houseId
        super.init(.naviBar(CGSize(width: 210, height: 45)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var titles: [String] {
        return ["房源详情", "竞价详情"]
    }
    
    override var btnsFrame: CGRect {
        return CGRect(x: 0, y: 0, width: 210, height: 45)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateVCs()
        if isDeal {
            dzy_removeToFirstVC(HouseDetailVC.self, isContain: true)
        }
    }

    override func getVCs() -> [UIViewController] {
        return [
            HouseDetailBaseVC(houseId),
            HouseBidDetailBaseVC(houseId)
        ]
    }
}
