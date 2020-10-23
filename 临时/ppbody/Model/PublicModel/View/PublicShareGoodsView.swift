//
//  PublicShareGoodsView.swift
//  PPBody
//
//  Created by edz on 2019/11/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class PublicShareGoodsView: UIView, AttPriceProtocol, InitFromNibEnable, ActivityTimeProtocol {
    
    var handler: ((ShareType, Int)->())?

    @IBOutlet weak var imgIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var opriceLB: UILabel!
    
    private var type: ShareType = .goods
    
    private var goodsId: Int = 1
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    func updateUI(_ type: ShareType, data: [String : Any]) {
        self.goodsId = data.intValue("id") ?? 1
        self.type = type
        var price = 0.0
        var oprice = 0.0
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        switch type {
        case .goods:
            nameLB.text = data.stringValue("title")
            price = data.doubleValue("presentPrice") ?? 0
            oprice = data.doubleValue("originPrice") ?? 0
        case .lbs_gb:
            nameLB.text = data.stringValue("name")
            price = 0.0
            if isActivity,
                let aprice = data.doubleValue("activityPrice"),
                aprice > 0
            {
                price = aprice
            }else {
                price = data.doubleValue("presentPrice") ?? 0
            }
            oprice = data.doubleValue("originPrice") ?? 0
        case .lbs_exp:
            nameLB.text = data.stringValue("name")
            price = data.doubleValue("presentPrice") ?? 0
            oprice = data.doubleValue("originPrice") ?? 0
        default:
            print("default")
        }
        priceLB.attributedText = attPriceStr(
            price,
            signFont: dzy_FontBBlod(12),
            priceFont: dzy_FontBBlod(24),
            fontColor: dzy_HexColor(0xEF343B))
        opriceLB.text = "¥\(oprice.decimalStr)"
    }
    
    @IBAction func detailAction(_ sender: Any) {
        handler?(type, goodsId)
    }
}
