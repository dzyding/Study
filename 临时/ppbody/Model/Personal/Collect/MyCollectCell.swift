//
//  MyCollectCell.swift
//  PPBody
//
//  Created by edz on 2019/11/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol MyCollectCellDelegate: class {
    func collectCell(_ cell: MyCollectCell,
                     didClickCollectBtnWith data: [String : Any])
}

class MyCollectCell: UITableViewCell, AttPriceProtocol {
    
    private var data: [String : Any] = [:]
    
    weak var delegate: MyCollectCellDelegate?

    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var opriceLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any], type: CollectType) {
        self.data = data
        switch type {
        case .gym:
            priceLB.isHidden = true
            opriceLB.isHidden = true
            msgLB.isHidden = false
            nameLB.text = data.stringValue("name")
            logoIV.setCoverImageUrl(data.stringValue("logo") ?? "")
            let region = data.stringValue("address") ?? ""
            let type = data.intValue("type") ?? 10
            msgLB.text = region + "  |  " + (LocationVCHelper.gymStrType(type) ?? "")
        case .good:
            priceLB.isHidden = false
            opriceLB.isHidden = false
            msgLB.isHidden = true
            let price = data.doubleValue("presentPrice") ?? 0
            let oprice = data.doubleValue("originPrice") ?? 0
            logoIV.setCoverImageUrl(data.stringValue("cover") ?? "")
            nameLB.text = data.stringValue("name")
            priceLB.attributedText = attPriceStr(price)
            opriceLB.text = "门市价￥\(oprice.decimalStr)"
        }
    }
    
    @IBAction func favAction(_ sender: UIButton) {
        delegate?.collectCell(self, didClickCollectBtnWith: data)
    }
    
}
