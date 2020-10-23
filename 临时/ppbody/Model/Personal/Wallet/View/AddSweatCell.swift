//
//  AddMoneyCell.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import StoreKit

class AddSweatCell: UITableViewCell {
    /// 头像
    @IBOutlet weak var iconIV: UIImageView!
    /// 名称
    @IBOutlet weak var nameLB: UILabel!
    /// 价格
    @IBOutlet weak var priceLB: UILabel!
    /// 热卖
    @IBOutlet weak var typeIV: UIImageView!
    
    var product: [String : Any]? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // 圆角为 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateViews() {
        guard let product = product else {return}
        if let sweat = product.intValue("sweat") {
            nameLB.text = "\(sweat)滴汗水"
            priceLB.text = "¥\(product.intValue("price") ?? 0)"
            
            if sweat == 15 || sweat == 40 {
                typeIV.isHidden = false
            }else {
                typeIV.isHidden = true
            }
        }
        
    }
}
