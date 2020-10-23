//
//  CoachMemberListCell.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachMemberListCell: UITableViewCell {
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = dzy_HexColor(0x333237).cgColor
    }

    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("name")
        
        let endTime = data.stringValue("endTime")
        
        if endTime == nil || endTime == ""
        {
            timeLB.text = ""
        }else{
            timeLB.text = "（" + endTime! + "到期）"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let timeDate = formatter.date(from: endTime!)
            
            let currentDate = Date()
            let timeInterval = currentDate.timeIntervalSince(timeDate!)
            if timeInterval/(60 * 60 * 24) < 7
            {
                //还有一周
                timeLB.textColor = UIColor.ColorHex("#F23A42")
            }else{
                timeLB.textColor = UIColor.ColorHex("#F4F4F4")
            }
            
        }
        numLB.text = "\(data.intValue("num") ?? 0)节"
    }
}
