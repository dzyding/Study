//
//  YJFPickerSourceCell.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class YJFPickerSourceCell: UITableViewCell {

    @IBOutlet weak var labelLB: UILabel!
    
    @IBOutlet weak var subLabelLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
