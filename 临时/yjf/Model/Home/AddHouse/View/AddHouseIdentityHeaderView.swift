//
//  AddHouseIdentityHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol AddHouseIdentityHeaderViewDelegate {
    func identityView(_ identityView: AddHouseIdentityHeaderView, didSelectType type: AddHouseType)
}

class AddHouseIdentityHeaderView: UIView {

    @IBOutlet private weak var ownBtn: UIButton!
    
    @IBOutlet private weak var agentBtn: UIButton!
    
    weak var delegate: AddHouseIdentityHeaderViewDelegate?
    
    func initUI(_ type: AddHouseType) {
        switch type {
        case .agent:
            agentBtn.isSelected = true
            ownBtn.isSelected = false
        case .owner:
            ownBtn.isSelected = true
            agentBtn.isSelected = false
        }
    }
    
    @IBAction func ownAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        ownBtn.titleLabel?.font     = dzy_FontBlod(14)
        agentBtn.titleLabel?.font   = dzy_Font(14)
        agentBtn.isSelected = false
        delegate?.identityView(self, didSelectType: .owner)
    }
    
    @IBAction func agentAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        ownBtn.titleLabel?.font     = dzy_Font(14)
        agentBtn.titleLabel?.font   = dzy_FontBlod(14)
        ownBtn.isSelected = false
        delegate?.identityView(self, didSelectType: .agent)
    }
    
}
