//
//  LocationGBItemsCell.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGBItemsCell: UIView, InitFromNibEnable {

    @IBOutlet weak var nameLB: UILabel!
    /// 份数，"团购价"
    @IBOutlet weak var xLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("name")
        xLB.text = "1份"
        priceLB.text = "\(data.doubleValue("price"), optStyle: .price)元"
    }
    
    func totalPriceUI(_ price: Double) {
        xLB.text = "总价"
        priceLB.text = price.decimalStr + "元"
    }
    
    func groupBuyPriceUI(_ price: Double) {
        xLB.text = "团购价"
        priceLB.text = price.decimalStr + "元"
        priceLB.textColor = YellowMainColor
    }
    
}
