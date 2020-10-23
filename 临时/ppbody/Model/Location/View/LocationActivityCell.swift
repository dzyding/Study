//
//  LocationActivityCell.swift
//  PPBody
//
//  Created by edz on 2019/11/6.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationActivityCell: UITableViewCell, AttPriceProtocol {

    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var opriceLB: UILabel!
    
    @IBOutlet weak var distanceLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        logoIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = data.stringValue("name")
        let club = data.stringValue("clubName") ?? ""
        let region = data.stringValue("region") ?? ""
        addressLB.text = club + "  |  " + region
        let price = data.doubleValue("price") ?? 0
        priceLB.attributedText = attPriceStr(price,
                                             signFont: dzy_FontBBlod(10),
                                             priceFont: dzy_FontBBlod(18),
                                             fontColor: dzy_HexColor(0xE63939))
        let oprice = data.doubleValue("originPrice") ?? 0
        opriceLB.text = "¥" + oprice.decimalStr
        let distance = data.doubleValue("distance") ?? 0
        distanceLB.text = (distance / 1000.0).decimalStr + "km"
    }
}
