//
//  BodyIndexHistoryCell.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class BodyIndexHistoryCell: UITableViewCell {

    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [dateLB, numLB].forEach { (label) in
            label?.font = dzy_FontBlod(13)
        }
    }
    
    func updateUI(_ data: [String : Any], unit: String) {
        dateLB.text = data.stringValue("time")?
            .components(separatedBy: " ").first
        numLB.text = (data.doubleValue("num") ?? 0).decimalStr + unit
    }
    
}
