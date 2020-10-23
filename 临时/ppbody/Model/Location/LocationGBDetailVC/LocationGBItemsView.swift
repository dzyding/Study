//
//  LocationGBItemsView.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGBItemsView: UIView, InitFromNibEnable, ActivityTimeProtocol {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var contentLB: UILabel!
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    func updateUI(_ data: [String : Any]) {
        let items = data.arrValue("items") ?? []
        items.forEach { (item) in
            let cell = LocationGBItemsCell.initFromNib()
            cell.updateUI(item)
            stackView.addArrangedSubview(cell)
        }
        if items.count > 0 {
            let tcell = LocationGBItemsCell.initFromNib()
            tcell.totalPriceUI(data.doubleValue("originPrice") ?? 0)
            stackView.addArrangedSubview(tcell)
            
            let gcell = LocationGBItemsCell.initFromNib()
            if isActivity,
                let aprice = data.doubleValue("activityPrice"),
                aprice > 0
            {
                gcell.groupBuyPriceUI(aprice)
            }else {
                let price = data.doubleValue("presentPrice") ?? 0
                gcell.groupBuyPriceUI(price)
            }
            stackView.addArrangedSubview(gcell)
        }
        if let str = data.stringValue("content") {
            let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.8)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5.0
            let attStr = NSMutableAttributedString(string: str, attributes: [
                NSAttributedString.Key.font : dzy_Font(13),
                NSAttributedString.Key.foregroundColor : color,
                NSAttributedString.Key.paragraphStyle : style
            ])
            contentLB.attributedText = attStr
        }
    }
}
