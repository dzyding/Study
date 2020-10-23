//
//  LGymGCClassCell.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymGCClassCell: UIView, AttPriceProtocol, InitFromNibEnable {
    
    var reserveHandler: (()->())?

    @IBOutlet weak var priceLB: UILabel!
    
    func initUI() {
        priceLB.attributedText = attPriceStr(6.6)
    }
    
    @IBAction func reserveAction(_ sender: UIButton) {
        reserveHandler?()
    }
}
