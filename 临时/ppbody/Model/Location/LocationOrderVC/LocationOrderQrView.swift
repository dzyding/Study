//
//  LocationOrderQrView.swift
//  PPBody
//
//  Created by edz on 2019/11/1.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderQrView: UIView, InitFromNibEnable {
    /// （有效期至2019.12.26）
    @IBOutlet weak var endTimeLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func initUI(_ list: [[String : Any]],
                endTime: String,
                orderId: Int)
    {
        let time = endTime.components(separatedBy: " ").first ?? ""
        endTimeLB.text = "（有效期至\(time)）"
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews.last?.removeFromSuperview()
        }
        list.forEach { (coupon) in
            let status = coupon.intValue("status") ?? 10
            let code = coupon.stringValue("code") ?? ""
            if status == 10 {
                let view = LocationOrderCodeAndQrView.initFromNib()
                view.updateUI(code, orderId: orderId)
                stackView.addArrangedSubview(view)
            }else {
                let view = LocationOrderCodeView.initFromNib()
                view.updateUI(code)
                stackView.addArrangedSubview(view)
            }
        }
    }

}
