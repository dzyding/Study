//
//  LOrderSubmitInfoView.swift
//  PPBody
//
//  Created by edz on 2019/10/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LOrderSubmitInfoView: UIView, InitFromNibEnable, AttPriceProtocol {

    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var mobileLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ price: Double) {
        priceLB.attributedText = attPriceStr(price)
        mobileLB.text = DataManager.mobile()
    }
}
