//
//  LocationTwoTBFilterCell.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationTwoTBFilterCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any], isRight: Bool) {
        titleLB.text = data.stringValue("name")
        let isSelected = data.boolValue(SelectedKey) ?? false
        if isRight {
            if isSelected {
                contentView.backgroundColor = .clear
                titleLB.textColor = YellowMainColor
            }else {
                contentView.backgroundColor = .clear
                titleLB.textColor = .white
            }
        }else {
            if isSelected {
                contentView.backgroundColor = YellowMainColor
                titleLB.textColor = CardColor
            }else {
                contentView.backgroundColor = .clear
                titleLB.textColor = .white
            }
        }
    }
}
