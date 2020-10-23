//
//  WatchHouseBuyerCell.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol WatchHouseBuyerCellDelegate {
    func buyerCell(
        _ buyerCell: WatchHouseBuyerCell,
        didSelectOpenBtn btn: UIButton,
        on row: Int
    )
}

class WatchHouseBuyerCell: UITableViewCell {
    
    weak var delegate: WatchHouseBuyerCellDelegate?
    
    private var row: Int = 0

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var openBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.buyerCell(self, didSelectOpenBtn: sender, on: row)
    }
    
    func updateUI(_ equip: [String : Any], row: Int) {
        self.row = row
        openBtn.isSelected = false
        nameLB.text = equip.stringValue("name")
        typeLB.text = equip.stringValue(DzyQuqipKey)
    }
}
