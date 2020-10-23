//
//  LocationCollectCell.swift
//  PPBody
//
//  Created by edz on 2019/10/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationCollectCell: UITableViewCell {
    /// -34 0
    @IBOutlet weak var leftLC: NSLayoutConstraint!
    
    @IBOutlet weak var widthLC: NSLayoutConstraint!
    
    @IBOutlet weak var selectedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        widthLC.constant = ScreenWidth + 34.0
    }
    
    func updateUI(_ isEdit: Bool) {
        leftLC.constant = isEdit ? 0 : -34
        selectedBtn.isHidden = !isEdit
        if isEdit {
            UIView.animate(withDuration: 0.25) {
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
}
