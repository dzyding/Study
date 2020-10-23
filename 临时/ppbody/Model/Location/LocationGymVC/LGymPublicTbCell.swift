//
//  LGymPublicTbCell.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum LGymViewType {
    /// 体验课
    case ptExp
    /// 团购
    case groupBuy
}

class LGymPublicTbCell: UITableViewCell, AttPriceProtocol, ActivityTimeProtocol {
    
    var btnHandler: (()->())?
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var imgIV: UIImageView!
    
    @IBOutlet weak var activityIV: UIImageView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var dPriceLB: UILabel!
    
    @IBOutlet weak var consumeLB: UILabel!
    /// 预约按钮
    @IBOutlet weak var sureBtn: UIButton!
    
    private var data: [String : Any] = [:]
    
    private lazy var isActivity: Bool = checkActivityDate()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func sureAction(_ sender: Any) {
        btnHandler?()
    }
    
    func updateUI(_ type: LGymViewType,
                  data: [String : Any],
                  row: Int
    ) {
        self.data = data
        switch type {
        case .groupBuy:
            groupBuyUpdate(data, row: row)
        case .ptExp:
            expClassUpdate(data, row: row)
        }
    }
    
    private func groupBuyUpdate(_ data: [String : Any], row: Int) {
        sureBtn.isHidden = true
        consumeLB.text = "\(data.intValue("consumeNum") ?? 0)人购买"
        if isActivity,
            let aprice = data.doubleValue("activityPrice"),
            aprice > 0
        {
            let color = RGBA(r: 222.0, g: 38.0, b: 97.0, a: 1)
            activityIV.isHidden = false
            priceLB.attributedText = attPriceStr(aprice,
                                                 fontColor: color)
        }else {
            activityIV.isHidden = true
            let price = data.doubleValue("presentPrice") ?? 0
            priceLB.attributedText = attPriceStr(price)
        }
        baseUpdateUI(data, row: row)
    }
    
    private func expClassUpdate(_ data: [String : Any], row: Int) {
        activityIV.isHidden = true
        sureBtn.isHidden = false
        consumeLB.text = "已预约\(data.intValue("consumeNum") ?? 0)人"
        priceLB.attributedText = attPriceStr(data.doubleValue("presentPrice") ?? 0)
        baseUpdateUI(data, row: row)
    }
    
    private func baseUpdateUI(_ data: [String : Any], row: Int) {
        bgView.layer.cornerRadius = row == 0 ? 6 : 0
        bgView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        bgView.layer.masksToBounds = true
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        titleLB.text = data.stringValue("name")
        dPriceLB.text = "¥\(data.doubleValue("originPrice"), optStyle: .price)"
    }
}
