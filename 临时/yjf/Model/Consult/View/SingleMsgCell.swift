//
//  SingleMsgCell.swift
//  YJF
//
//  Created by edz on 2019/8/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SingleMsgCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func normalUpdateUI(_ str: String) {
        titleLB.text = str
    }
    
    func keyUpdateUI(_ data: [String: Any], key: String) {
        guard let title = data.stringValue("title") else {return}
        if let swiftRange = title.range(of: key) {
            let ocRange = dzy_toNSRange(swiftRange, str: title)
            let str = NSMutableAttributedString(string: title, attributes: [
                NSAttributedString.Key.font : dzy_Font(14),
                NSAttributedString.Key.foregroundColor : Font_Dark
                ])
            str.addAttributes([
                NSAttributedString.Key.foregroundColor : MainColor
                ], range: ocRange)
            titleLB.attributedText = str
        }else {
            titleLB.text = title
        }
    }
}
