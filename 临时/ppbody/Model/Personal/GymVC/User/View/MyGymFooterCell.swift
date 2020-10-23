//
//  MyGymFooterCell.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymFooterCell: UITableViewCell {

    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var longLB: UILabel!
    
    @IBOutlet weak var infoLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        let time = data.stringValue("time") ?? ""
        timeLB.text = ToolClass.compareCurrentTime(date: time)
        let duration = data.intValue("duration") ?? 0
        dealWithDuration(duration)
        let reduce = data.intValue("reduce") ?? 0
        if reduce > 0 {
            infoLB.text = "次卡扣除：\(reduce)次"
        }else {
            infoLB.text = nil
        }
    }
    
    private func dealWithDuration(_ value: Int) {
        if value == 0 {
            longLB.text = "训练时长：-"
        }else if value <= 60 {
            longLB.text = "训练时长：\(value)分钟"
        }else {
            let h = Double(value) / 60.0
            longLB.text = "训练时长：\(h.decimalStr)小时"
        }
    }
}
