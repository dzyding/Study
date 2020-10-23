//
//  ShowFirstCell.swift
//  YJF
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ShowFirstCell: UITableViewCell {

    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var moneyLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        dateLB.text = data.stringValue("createTime")
        let priceStr = "\(data.doubleValue("price"), optStyle: .price)元"
        let status = data.intValue("status") ?? 0
        switch status {
        case 1:
            typeLB.text = "退款中"
            moneyLB.text = "-" + priceStr
            moneyLB.textColor = MainColor
        case 95:
            typeLB.text = "线下结清，余额冲销"
            moneyLB.text = "-" + priceStr
            moneyLB.textColor = MainColor
        case 96:
            typeLB.text = "充值"
            moneyLB.text = "+" + priceStr
            moneyLB.textColor = dzy_HexColor(0x26CC85)
        case 97:
            let es = data.intValue("expenditureStatus") ?? 10
            if es == 10 {
                typeLB.text = "扣除"
                moneyLB.text = "-" + priceStr
                moneyLB.textColor = MainColor
            }else {
                typeLB.text = "已豁免"
                moneyLB.text = "+" + priceStr
                moneyLB.textColor = dzy_HexColor(0x26CC85)
            }
        case 98:
            typeLB.text = "退款"
            moneyLB.text = "-" + priceStr
            moneyLB.textColor = dzy_HexColor(0x26CC85)
        default:
            typeLB.text = nil
            moneyLB.text = priceStr
            moneyLB.textColor = Font_Dark
        }
    }
    
}
