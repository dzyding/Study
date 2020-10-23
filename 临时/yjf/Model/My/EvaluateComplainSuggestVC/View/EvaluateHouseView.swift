//
//  EvaluateHouseView.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol EvaluateHouseViewDelegate {
    func houseView(_ houseView: EvaluateHouseView, didSelectShowBtn btn: UIButton)
}

class EvaluateHouseView: UIView {
    
    weak var delegate: EvaluateHouseViewDelegate?

    @IBOutlet private weak var nameLB: UILabel!
    
    @IBOutlet private weak var showBtn: UIButton!
    
    @IBAction func showAction(_ sender: UIButton) {
        sender.isSelected = true
        delegate?.houseView(self, didSelectShowBtn: sender)
    }
    
    func updateUI(_ str: String?) {
        nameLB.text = str
    }
    
    func closeAction() {
        showBtn.isSelected = false
    }
}
