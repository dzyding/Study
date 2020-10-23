//
//  LActivityTBHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/11/6.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LActivityTBHeaderViewDelegate: class {
    func header(_ header: LActivityTBHeaderView, didSelectType type: Int)
}

class LActivityTBHeaderView: UIView, InitFromNibEnable {
    
    weak var delegate: LActivityTBHeaderViewDelegate?

    @IBOutlet weak var lowBtn: UIButton!
    
    @IBOutlet weak var maxBtn: UIButton!
    
    @IBOutlet weak var midBtn: UIButton!
    
    @IBAction func lowAction(_ sender: UIButton) {
        lowBtn.isSelected = true
        maxBtn.isSelected = false
        midBtn.isSelected = false
        delegate?.header(self, didSelectType: 10)
    }
    
    @IBAction func midAction(_ sender: UIButton) {
        lowBtn.isSelected = false
        maxBtn.isSelected = false
        midBtn.isSelected = true
        delegate?.header(self, didSelectType: 20)
    }
    
    @IBAction func maxAction(_ sender: UIButton) {
        lowBtn.isSelected = false
        maxBtn.isSelected = true
        midBtn.isSelected = false
        delegate?.header(self, didSelectType: 30)
    }
    
}
