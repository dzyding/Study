//
//  MyMotionAddTypeCell.swift
//  PPBody
//
//  Created by edz on 2020/4/20.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class MyMotionAddTypeCell: UICollectionViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLB.layer.cornerRadius = 6
        titleLB.layer.borderColor = YellowMainColor.cgColor
        titleLB.layer.masksToBounds = true
    }

    func borderUI() {
        titleLB.textColor = YellowMainColor
        titleLB.backgroundColor = BackgroundColor
        titleLB.layer.borderWidth = 1
        
    }
    
    func emptyUI() {
        titleLB.textColor = .white
        titleLB.backgroundColor = CardColor
        titleLB.layer.borderWidth = 0
    }
}
