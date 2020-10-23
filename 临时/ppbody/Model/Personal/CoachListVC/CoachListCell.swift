//
//  CoachListCell.swift
//  PPBody
//
//  Created by edz on 2019/11/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachListCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(_ data: [String : Any]) {
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "",
                                45.0 * ScreenScale)
        nameLB.text = data.stringValue("nickname")
    }
}
