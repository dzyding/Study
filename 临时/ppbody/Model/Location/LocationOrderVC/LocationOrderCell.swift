//
//  LocationOrderCell.swift
//  PPBody
//
//  Created by edz on 2019/10/31.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LocationOrderCellDelegate: class {
    func orderCell(_ orderCell: LocationOrderCell,
                   didClickActionBtn btn: UIButton,
                   order: [String : Any])
}

class LocationOrderCell: UITableViewCell, AttPriceProtocol {
    
    weak var delegate: LocationOrderCellDelegate?
    /// 订单号
    @IBOutlet weak var orderNumLB: UILabel!
    /// 状态
    @IBOutlet weak var typeLB: UILabel!
    /// 图片
    @IBOutlet weak var imgIV: UIImageView!
    /// 名字
    @IBOutlet weak var nameLB: UILabel!
    /// 数量
    @IBOutlet weak var numLB: UILabel!
    /// 价格
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var leftBtn: UIButton!
    
    private var order: [String : Any] = [:]

    func updateUI(_ data: [String : Any]) {
        self.order = data
        let status = data.intValue("status") ?? 1
        var code = data.stringValue("code") ?? ""
        code = code.count > 0 ? code : "暂未生成"
        orderNumLB.text = "订单号：\(code)"
        typeLB.text = LOrderType.type(status)
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = data.stringValue("name")
        numLB.text = "x\(data.intValue("num") ?? 1)"
        let price = data.doubleValue("actualPrice") ?? 0
        priceLB.attributedText = attPriceStr(price)
        
        // 10 待付款 20 待使用 30 待评价 40 完成 50 已取消 60 退款和售后
        rightBtn.isHidden = false
        rightBtn.tag = LOrderActionType.none.rawValue
        leftBtn.isHidden = false
        leftBtn.tag = LOrderActionType.none.rawValue
        switch status {
        case 10:
            rightBtn.tag = LOrderActionType.pay.rawValue
            rightBtn.setTitle("付款", for: .normal)
            leftBtn.tag = LOrderActionType.cancel.rawValue
            leftBtn.setTitle("取消订单", for: .normal)
        case 20:
            rightBtn.tag = LOrderActionType.use.rawValue
            rightBtn.setTitle("使用", for: .normal)
            if code.contains("免单") { // 免单
                leftBtn.isHidden = true
            }else if price <= 1 { // 金额小于1
                leftBtn.isHidden = true
            }else {
                leftBtn.tag = LOrderActionType.refund.rawValue
                leftBtn.setTitle("退款", for: .normal)
            }
        case 30:
            rightBtn.tag = LOrderActionType.evaluate.rawValue
            rightBtn.setTitle("评价", for: .normal)
            leftBtn.isHidden = true
        case 50:
//            rightBtn.tag = LOrderActionType.rProgress.rawValue
//            rightBtn.setTitle("退款进度", for: .normal)
            rightBtn.isHidden = true
            leftBtn.isHidden = true
        default:
            rightBtn.isHidden = true
            leftBtn.isHidden = true
        }
    }
    
    @IBAction private func btnAction(_ sender: UIButton) {
        delegate?.orderCell(self,
                            didClickActionBtn: sender,
                            order: order)
    }
}
