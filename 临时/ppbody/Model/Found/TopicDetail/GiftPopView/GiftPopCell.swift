//
//  GiftPopCell.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class GiftPopCell: UICollectionViewCell {
    
    var data: [String : Any]? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
    }
    
    func updateViews() {
        guard let data = data else {return}
        imgView.setCoverImageUrl(data.stringValue("cover") ?? "")
        priceLB.text = "\(data.intValue("value") ?? 0)" + "水滴"
        nameLB.text = data.stringValue("name")
        if data.boolValue("selected") == true {
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = YellowMainColor.cgColor
        }else {
            bgView.layer.borderWidth = 0
        }
    }
}
