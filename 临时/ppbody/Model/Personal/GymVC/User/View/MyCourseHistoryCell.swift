//
//  MyCourseHistoryCell.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyCourseHistoryCell: UITableViewCell {

    @IBOutlet weak var cnameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        let time = data.stringValue("createTime") ?? ""
        timeLB.text = ToolClass.compareCurrentTime(date: time)
        cnameLB.text = data.stringValue("className")
        nameLB.text = data.stringValue("ptName")
        iconIV.isHidden = data.intValue("isReserve") != 1
    }
}
