//
//  BindGymCell.swift
//  PPBody
//
//  Created by edz on 2019/4/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class BindGymCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var selBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func updateViews(_ dic: [String : Any]) {
        iconIV.setCoverImageUrl(dic.stringValue("logo") ?? "")
        nameLB.text = dic.stringValue("name")
        addressLB.text = dic.stringValue("city")
        
        let selected = dic.boolValue(SelectedKey) ?? false
        selBtn.isSelected = selected
        if selected {
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = YellowMainColor.cgColor
        }else {
            bgView.layer.borderWidth = 0
        }
    }
}
