//
//  StatisticsCardioMotionDetailCell.swift
//  PPBody
//
//  Created by edz on 2019/10/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class StatisticsCardioMotionDetailCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var delBtn: UIButton!
    
    var editHandler: (()->())?
    
    var delHandler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderColor = CardColor.cgColor
        bgView.layer.borderWidth = 1
    }
    
    func updateUI(_ data: [String : Any]) {
        let date = data.stringValue("createTime") ?? ""
        dateLB.text = ToolClass.compareCurrentTime(date: date)
        
        let isHidden = compareDate(date) < 7
        editBtn.isHidden = !isHidden
        delBtn.isHidden = !isHidden
        
        if let time = data.doubleValue("time") {
            let result = time / 60.0
            timeLB.text = result.decimalStr + "min"
        }else {
            timeLB.text = nil
        }
    }
    
    private func compareDate(_ time: String) -> Int {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormat.date(from: time) {
            let calender = Calendar.current
            let result = calender.dateComponents([.day],
                                                 from: date,
                                                 to: Date())
            return result.day ?? 99
        }else {
            return 99
        }
    }
    
    @IBAction private func delAction(_ sender: UIButton) {
        delHandler?()
    }
    
    @IBAction private func editAction(_ sender: UIButton) {
        editHandler?()
    }
    
}
