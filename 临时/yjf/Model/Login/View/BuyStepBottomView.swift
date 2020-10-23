//
//  BuyStepBottomView.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol BuyStepBottomViewDelegate {
    func bottomView(_ bottomView: BuyStepBottomView, didClickSureBtn btn: UIButton)
    func bottomView(_ bottomView: BuyStepBottomView, didClickPayDepostBtn btn: UIButton)
}

class BuyStepBottomView: UIView {
    
    static let fullHeight: CGFloat = 157
    
    static let shortHeight: CGFloat = 87
    
    weak var delegate: BuyStepBottomViewDelegate?

    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var agreeBtn: UIButton!
    /// 50 10
    @IBOutlet weak var payDepositTopLC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        okBtn.layer.borderWidth = 1
        okBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
    }
    
    func updateUI() {
        payDepositTopLC.constant = 10
        okBtn.isHidden = true
        agreeBtn.isHidden = true
    }
    
    @IBAction func agreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        delegate?.bottomView(self, didClickSureBtn: sender)
    }
    
    @IBAction func payDepositAction(_ sender: UIButton) {
        delegate?.bottomView(self, didClickPayDepostBtn: sender)
    }
}
