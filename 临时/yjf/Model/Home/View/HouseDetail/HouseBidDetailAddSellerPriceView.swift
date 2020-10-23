//
//  HouseBidDetailAddSellerPriceView.swift
//  YJF
//
//  Created by edz on 2019/5/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseBidDetailAddSellerPriceViewDelegate {
    func pirceView(_ priceView: HouseBidDetailAddSellerPriceView, didSelectAddPriceBtn btn: UIButton)
}

class HouseBidDetailAddSellerPriceView: UIView {
    
    weak var delegate: HouseBidDetailAddSellerPriceViewDelegate?

    @IBOutlet weak var lineView: UIView!

    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBtn.layer.masksToBounds = true
        addBtn.layer.cornerRadius = 3
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
    }
    
    func updateUI(_ ifEmpty: Bool) {
        lineView.isHidden = ifEmpty
        msgLB.isHidden = !ifEmpty
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        delegate?.pirceView(self, didSelectAddPriceBtn: sender)
    }
}
