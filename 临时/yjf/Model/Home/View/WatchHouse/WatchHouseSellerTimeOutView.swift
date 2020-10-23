//
//  WatchHouseSellerTimeOutView.swift
//  YJF
//
//  Created by edz on 2019/8/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol WatchHouseSellerTimeOutViewDelegate: class {
    func timeOutView(_ timeOutView: WatchHouseSellerTimeOutView, didClickBtn btn: UIButton)
}

class WatchHouseSellerTimeOutView: UIView, InitFromNibEnable {
    
    weak var delegate: WatchHouseSellerTimeOutViewDelegate?

    @IBOutlet weak var msgLB: UILabel!
    
    @IBAction func btnClick(_ sender: UIButton) {
        delegate?.timeOutView(self, didClickBtn: sender)
    }
    
    func updateUI(_ data: [String : Any]) {
        let time = (data.dicValue("lockOpenLog") ?? data.dicValue("lockOpen"))?.intValue("L") ?? 30
        var attStr = DzyAttributeString()
        attStr.str = "您已经看房\(time)分钟，请尽快查看及处理，及时退出关门，并确认【结束看房】"
        attStr.font = dzy_Font(15)
        attStr.color = .white
        attStr.lineSpace = defaultLineSpace
        msgLB.attributedText = attStr.create()
    }
}
