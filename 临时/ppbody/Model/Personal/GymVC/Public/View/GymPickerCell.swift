//
//  GymPickerCell.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class GymPickerCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func coachUpdateViews(_ data: [String : Any]) {
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        nameLB.text = data.stringValue("name")
    }
    
    func gymUpdateViews(_ data: [String : Any]) {
        iconIV.layer.cornerRadius = 6
        iconIV.layer.masksToBounds = true
        iconIV.setCoverImageUrl(data.stringValue("logo") ?? "")
        nameLB.text = data.stringValue("name")
    }
}
