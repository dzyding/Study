//
//  LocationRCTimeCell.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpRCTimeCell: UICollectionViewCell {
    
    @IBOutlet weak var titleBtn: UIButton!
    
    var handler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func clickAction(_ sender: UIButton) {
        handler?()
    }
    
    func updateUI(_ time: (Int, Bool)) {
        let title = ToolClass.getTimeStr(time.0)
        titleBtn.setTitle(title, for: .normal)
        titleBtn.isSelected = time.1
    }
}
