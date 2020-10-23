//
//  SellDepositHouseView.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol SellDepositHouseViewDelegate {
    func houseView(_ houseView: SellDepositHouseView, didSelect btn:UIButton)
}

class SellDepositHouseView: UIView {
    
    @IBOutlet weak var titleLB: UILabel!
    
    weak var delegate: SellDepositHouseViewDelegate?
    
    @IBOutlet private weak var selectedBtn: UIButton!
    
    func updateUI(_ house: [String : Any], tag: Int) {
        titleLB.text = house.stringValue("houseTitle")
        let selected = house.boolValue(Public_isSelected) ?? false
        selectedBtn.isSelected = selected
        self.tag = tag
    }

    @IBAction private func btnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.houseView(self, didSelect: sender)
    }
    
}
