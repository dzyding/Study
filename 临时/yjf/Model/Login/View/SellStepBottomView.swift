//
//  SellStepBottomView.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol SellStepBottomViewDelegate {
    func bottomView(_ bottomView: SellStepBottomView, didClickSureBtn btn: UIButton)
    func bottomView(_ bottomView: SellStepBottomView, didClickSellDepositBtn btn: UIButton)
    func bottomView(_ bottomView: SellStepBottomView, didClickAddHouseBtn btn: UIButton)
}

class SellStepBottomView: UIView {
    
    static let fullHeight: CGFloat = 200.0
    
    static let shortHeight: CGFloat = 135.0
    
    weak var delegate: SellStepBottomViewDelegate?

    /// 50 10
    @IBOutlet weak var addHouseTopLC: NSLayoutConstraint!
    
    @IBOutlet weak var agreeBtn: UIButton!
    
    @IBOutlet weak var okBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        okBtn.layer.borderWidth = 1
        okBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
    }
    
    func updateUI() {
        addHouseTopLC.constant = 10
        agreeBtn.isHidden = true
        okBtn.isHidden = true
    }

    @IBAction func agreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        delegate?.bottomView(self, didClickSureBtn: sender)
    }
    
    @IBAction func sellDepositAction(_ sender: UIButton) {
        delegate?.bottomView(self, didClickSellDepositBtn: sender)
    }
    
    @IBAction func addHouseAction(_ sender: UIButton) {
        delegate?.bottomView(self, didClickAddHouseBtn: sender)
    }
    
}
