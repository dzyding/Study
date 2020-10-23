//
//  CollectionFilterCell.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CollectionFilterCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib() 
    }
    
    //swiftlint:disable:next large_tuple
    func updateUI(_ model: (String, Bool, (Int, Int)?)) {
        label.text = model.0
        let bgColor = model.1 ? dzy_HexColor(0xFFF2E9) : dzy_HexColor(0xF5F5F5)
        let textColor = model.1 ? dzy_HexColor(0xFD7E25) : dzy_HexColor(0x646464)
        label.textColor = textColor
        label.backgroundColor = bgColor
    }

}
