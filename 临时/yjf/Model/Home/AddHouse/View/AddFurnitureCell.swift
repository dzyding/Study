//
//  AddFurnitureCell.swift
//  YJF
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class AddFurnitureCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    var handelr: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 3
        bgView.layer.masksToBounds = true
    }

    @IBAction func delAction(_ sender: UIButton) {
        handelr?()
    }
}
