//
//  SmartQaUserCell.swift
//  YJF
//
//  Created by edz on 2019/8/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SmartQaUserCell: UITableViewCell {
    
    @IBOutlet weak var textLB: UILabel!
    
    func updateUI(_ str: String?) {
        if let str = str {
            var attStr = DzyAttributeString()
            attStr.str = str
            attStr.color = UIColor.white
            attStr.font = dzy_Font(14)
            attStr.lineSpace = defaultLineSpace
            textLB.attributedText = attStr.create()
        }else {
            textLB.text = nil
        }
    }
}
