//
//  StatisticsCardioOverviewDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol StatisticsCardioOverviewDetailCellDelegate: class {
    func overviewCell(_ cell: StatisticsCardioOverviewDetailCell,
                      didClickEditBtn btn: UIButton,
                      data: [String : Any])
    
    func overviewCell(_ cell: StatisticsCardioOverviewDetailCell,
                      didClickDelBtn btn: UIButton,
                      data: [String : Any])
}

class StatisticsCardioOverviewDetailCell: UITableViewCell {
    
    weak var delegate: StatisticsCardioOverviewDetailCellDelegate?
    
    private var data: [String : Any] = [:]
    
    @IBOutlet weak var motionNameLB: UILabel!
    
    @IBOutlet weak var motionCoverIV: UIImageView!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var createTimeLB: UILabel!
    
    @IBOutlet weak var delBtn: UIButton!
    
    @IBOutlet weak var editBtn: UIButton!

    func setData(_ dic: [String:Any]) {
        self.data = dic
        let motion = dic["motion"] as! [String:Any]
        motionNameLB.text = motion["name"] as? String
        motionCoverIV.setCoverImageUrl(motion["cover"] as! String)
        
        let time = dic["time"] as! Int
        timeLB.text = ToolClass.secondToText(time)
        
        let cdate = dic.stringValue("createTime") ?? ""
        createTimeLB.text = ToolClass.compareCurrentTime(date: cdate)
        
        let type = dic["type"] as! Int
        typeLB.isHidden = type == 20 ? false : true
        
        let isHidden = compareDate(cdate) < 7
        editBtn.isHidden = !isHidden
        delBtn.isHidden = !isHidden
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
    
    @IBAction private func editAction(_ sender: UIButton) {
        delegate?.overviewCell(self, didClickEditBtn: sender, data: data)
    }
    
    @IBAction private func delAction(_ sender: UIButton) {
        delegate?.overviewCell(self, didClickDelBtn: sender, data: data)
    }
}
