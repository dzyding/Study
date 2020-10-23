//
//  StatisticsOverviewDetailHeader.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol StatisticsMotionDetailHeaderDelegate: class {
    func motionHeader(_ header: StatisticsMotionDetailHeader,
                      didClickEditBtn btn: UIButton,
                      data: [String : Any])
    func motionHeader(_ header: StatisticsMotionDetailHeader,
                      didClickDeleteBtn btn: UIButton,
                      data: [String : Any])
}

class StatisticsMotionDetailHeader: UITableViewHeaderFooterView {
    
    weak var delegate: StatisticsMotionDetailHeaderDelegate?
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var createTimeLB: UILabel!
    
    @IBOutlet weak var groupNumLB: UILabel!
    
    @IBOutlet weak var freNumLB: UILabel!
    
    @IBOutlet weak var weightLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var delBtn: UIButton!
    
    private var data: [String : Any] = [:]
    
    func setData(_ dic: [String:Any]) {
        self.data = dic
        groupNumLB.text = "\(dic["groupNum"]!)"
        freNumLB.text = "\(dic["freNumAve"]!)"
        let aveWeight = (dic["weightAve"] as! NSNumber).floatValue
        weightLB.text = aveWeight.removeDecimalPoint + "kg"
        
        let time = dic["time"] as! Int
        timeLB.text = "时长：" + ToolClass.secondToText(time)
        
        let cdate = dic.stringValue("createTime") ?? ""
        createTimeLB.text = ToolClass.compareCurrentTime(date: cdate)
        
        let isHidden = compareDate(cdate) < 7
        editBtn.isHidden = !isHidden
        delBtn.isHidden = !isHidden
        
        let type = dic["type"] as! Int
        typeLB.isHidden = type == 20 ? false : true
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
        delegate?.motionHeader(self, didClickEditBtn: sender, data: data)
    }
    
    @IBAction private func deleteAction(_ sender: UIButton) {
        delegate?.motionHeader(self, didClickDeleteBtn: sender, data: data)
    }
}


