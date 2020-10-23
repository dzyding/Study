//
//  OrderFlowCell.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class OrderFlowCell: UITableViewCell {
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    /// 是否豁免
    @IBOutlet weak var typeLB: UILabel!
    
    func updateUI(_ data: [String : Any]) {
        //20 支出，10 收入
        let type = data.intValue("way") ?? 10
        let price = data.doubleValue("price") ?? 0
        let priceStr = (type == 10 ? "+" : "-") + "\(price, format: "%.2lf")"
        let msg = data.stringValue("cause")
        
        titleLB.text = data.stringValue("title")
        detailLB.text = data.stringValue("content")
        typeLB.isHidden = data.intValue("expenditureStatus") != 20
        if let time = data.stringValue("createTime"),
            time.count > 16
        {
            let index = time.index(time.startIndex, offsetBy: 16)
            timeLB.text = String(time[..<index])
        }else {
            timeLB.text = nil
        }
        
        if let num = data.stringValue("sequentialNumber") {
            numLB.text = "流水号：\(num)"
        }else {
            numLB.text = "流水号："
        }
        
        if let msg = msg,
            let range = msg.range(of: priceStr) {
            let nsrange = dzy_toNSRange(range, str: msg)
            let arrStr = NSMutableAttributedString(string: msg, attributes: [
                NSAttributedString.Key.font : dzy_Font(14),
                NSAttributedString.Key.foregroundColor : dzy_HexColor(0x646464)
                ])
            let color = type == 10 ? dzy_HexColor(0x26CC85) : dzy_HexColor(0xFD7E25)
            arrStr.addAttribute(
                NSAttributedString.Key.foregroundColor, value: color, range: nsrange
            )
            msgLB.attributedText = arrStr
        }else {
            msgLB.text = msg
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
