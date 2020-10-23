//
//  DistrictFilterCell.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DistrictFilterCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        titleLB.text = data.stringValue("name")
        titleLB.textColor = data.boolValue(Public_isSelected) == true ? dzy_HexColor(0xFD7E25) : Font_Dark
    }
}
