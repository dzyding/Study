//
//  WalletHeaderGiftCell.swift
//  PPBody
//
//  Created by edz on 2018/12/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SWalletHeaderGiftCell: UICollectionViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var numLB: GiftNameLabel!
    
    @IBOutlet weak var bgView: UIView!
    
    var data: [String : Any] = [:] {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 3
        bgView.dzy_shadow(RGB(r: 140.0, g: 140.0, b: 140.0))
    }

    func updateViews() {
        iconIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        numLB.text = "x\(data.intValue("num") ?? 0)"
    }
}
