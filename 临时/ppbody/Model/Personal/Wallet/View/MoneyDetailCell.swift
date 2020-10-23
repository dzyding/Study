//
//  MoneyDetailCell.swift
//  PPBody
//
//  Created by edz on 2019/12/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MoneyDetailCell: UITableViewCell {

    @IBOutlet weak var moneyLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        detailLB.text = data.stringValue("content")
        data.stringValue("createTime")
            .flatMap({
                timeLB.text = ToolClass
                    .compareCurrentTime(date: $0)
            })
        if let type = data.intValue("type"),
            let num = data.doubleValue("price")
        {
            moneyLB.text = (type != 90 ? "+" : "-") + " ¥ \(num.decimalStr)元"
            
            if type == 90 {
                let color = RGB(r: 110.0, g: 172.0, b: 86.0)
                typeLB.text = "已提现"
                typeLB.textColor = color
                return
            }
        }
        if let status = data.intValue("status") {
            switch status {
            case 10:
                typeLB.text = "未入账"
                typeLB.textColor = .white
            case 20:
                typeLB.text = "已入账"
                typeLB.textColor = YellowMainColor
            case 30:
                typeLB.text = "已取消"
                typeLB.textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.45)
            default:
                typeLB.text = nil
            }
        }
    }
}
