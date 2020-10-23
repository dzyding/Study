//
//  CoachClassListCell.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachClassListCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func updateUI(_ data: [String : Any]) {
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        nameLB.text = data.stringValue("memberName")
        if let time = data.stringValue("createTime") {
            timeLB.text = String(time[time.index(time.startIndex, offsetBy: 5)...])
        }
    }
    
}
