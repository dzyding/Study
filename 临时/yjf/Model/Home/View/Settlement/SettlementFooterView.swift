//
//  SettlementFooterView.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol SettlementFooterViewDelegate {
    func footer(_ footer: SettlementFooterView, didClickPayBtn btn: UIButton)
}

class SettlementFooterView: UIView {
    
    @IBOutlet weak var totalPriceLB: UILabel!
    
    @IBOutlet weak var payBtn: UIButton!
    
    weak var delegate: SettlementFooterViewDelegate?
    
    func updateUI(_ amount: [String : Any]) {
        guard var price = amount.doubleValue("price") else {return}
        price = abs(price)
        totalPriceLB.text = "-¥" + price.decimalStr
        payBtn.setTitle("同意，去支付¥\(price.decimalStr)", for: .normal)
    }

    @IBAction private func payAction(_ sender: UIButton) {
        delegate?.footer(self, didClickPayBtn: sender)
    }
    
}
