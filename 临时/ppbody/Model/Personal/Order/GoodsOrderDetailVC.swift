//
//  GoodsOrderDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/11/13.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class GoodsOrderDetailVC: BaseVC, AttPriceProtocol {

    @IBOutlet weak var goodsIV: UIImageView!
    
    @IBOutlet weak var goodsNameLB: UILabel!
    
    @IBOutlet weak var goodsPriceLB: UILabel!
    
    @IBOutlet weak var codeLB: UILabel!
    
    @IBOutlet weak var phoneLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var tpriceLB: UILabel!
    
    @IBOutlet weak var wlNameLB: UILabel!
    
    @IBOutlet weak var wlCodeLB: UILabel!
    
    @IBOutlet weak var wlTypeLB: UILabel!
    
    private let order: [String : Any]
    
    init(_ order: [String : Any]) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商品订单"
        initUI()
    }
    
    func initUI() {
        goodsIV.setCoverImageUrl(order.stringValue("cover") ?? "")
        goodsNameLB.text = order.stringValue("name")
        let num = order.intValue("num") ?? 0
        let price = order.doubleValue("totalPrice") ?? 0
        goodsPriceLB.attributedText = attPriceStr(price / Double(num))
        codeLB.text = "\(order.stringValue("code") ?? "")"
        phoneLB.text = order.stringValue("receiverMobile")
        numLB.text = "\(num)"
        tpriceLB.text = "¥\(price.decimalStr)"
        wlNameLB.text = order.stringValue("wlName")
        wlCodeLB.text = order.stringValue("wlCode")
        let status = order.intValue("status") ?? 0
        wlTypeLB.text = typeStr(status)
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
