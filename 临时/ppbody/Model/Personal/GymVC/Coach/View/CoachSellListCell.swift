//
//  CoachSellListCell.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachSellListCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        selectionStyle = .none
    }
    
    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("memberName")
        numLB.text  = "\(data.intValue("classNum") ?? 0)"
        msgLB.text  = data.stringValue("classes")
        if let time = data.stringValue("createTime") {
            timeLB.text = String(time[...time.index(time.endIndex, offsetBy: -2)])
        }
    }
}
