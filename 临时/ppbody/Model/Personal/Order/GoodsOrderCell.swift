//
//  GoodsOrderCell.swift
//  PPBody
//
//  Created by edz on 2019/11/13.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class GoodsOrderCell: UITableViewCell, AttPriceProtocol {

    @IBOutlet weak var codeLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(_ data: [String : Any]) {
        codeLB.text = "订单号：\(data.stringValue("code") ?? "")"
        let status = data.intValue("status") ?? 0
        typeLB.text = typeStr(status)
        iconIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = data.stringValue("name")
        numLB.text = "x\(data.intValue("num") ?? 0)"
        let price = data.doubleValue("totalPrice") ?? 0
        priceLB.attributedText = attPriceStr(price)
    }
    
    //10 待付款 20 待发货  30 已发货 40 完成 50 已取消 60 退款中 61 已退款
    private func typeStr(_ status: Int) -> String {
        switch status {
        case 10:
            return "待付款"
        case 20:
            return "待发货"
        case 30:
            return "已发货"
        case 40:
            return "完成"
        case 50:
            return "已取消"
        case 60:
            return "退款中"
        case 61:
            return "已退款"
        default:
            return ""
        }
    }
}
