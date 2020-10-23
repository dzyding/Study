//
//  CityRectCell.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CityRectCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(_ city: [String : Any]) {
        titleLB.text = city.stringValue("city")
//        if isSelected {
//            bgView.backgroundColor = .clear
//            bgView.layer.cornerRadius = 6
//            bgView.layer.borderColor = YellowMainColor.cgColor
//            bgView.layer.borderWidth = 1
//        }else {
//            bgView.backgroundColor = CardColor
//            bgView.layer.borderWidth = 0
//        }
    }
}
