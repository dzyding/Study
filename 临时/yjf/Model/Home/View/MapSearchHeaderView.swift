//
//  MapSearchHeaderView.swift
//  YJF
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MapSearchHeaderView: UIView {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var zkIV: UIImageView!
    
    func updateNumMsgUI(_ data: [String : Any]) {
        // 在售数量
        let pushNum = data.intValue("pushNum") ?? 0
        // 成交数量
        let notPushNum = data.intValue("notPushNum") ?? 0
        msgLB.text = "在售房源\(pushNum)套  已成交房源\(notPushNum)套"
    }
    
    func updateNameMsg(_ data: [String : Any]) {
        titleLB.text = data.stringValue("name")
    }
}
