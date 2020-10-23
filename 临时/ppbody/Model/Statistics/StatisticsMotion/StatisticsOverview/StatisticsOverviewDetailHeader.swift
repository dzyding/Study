//
//  StatisticsOverviewDetailHeader.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol StatisticsOverviewDetailHeaderDelegate: class {
    func overviewHeader(
        _ header: StatisticsOverviewDetailHeader,
        didClickEditBtn btn: UIButton,
        data: [String : Any])
    func overviewHeader(
        _ header: StatisticsOverviewDetailHeader,
        didClickDelBtn btn: UIButton,
        data: [String : Any])
}

class StatisticsOverviewDetailHeader: UITableViewHeaderFooterView {
    
    weak var delegate: StatisticsOverviewDetailHeaderDelegate?
    
    private var data: [String : Any] = [:]
    
    @IBOutlet weak var motionNameLB: UILabel!
    
    @IBOutlet weak var motionCoverIV: UIImageView!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var createTimeLB: UILabel!
    
    @IBOutlet weak var infoLB: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var delBtn: UIButton!
    
    @IBOutlet weak var editBtn: UIButton!
    
    func setData(_ dic: [String : Any]) {
        self.data = dic
        let motion = dic.dicValue("motion")
        motionNameLB.text = motion?.stringValue("name")
        motionCoverIV
            .setCoverImageUrl(motion?.stringValue("cover") ?? "")
        
        var info = ""
        dic.doubleValue("weightAve").flatMap({
            info = $0.decimalStr + "kg均负重"
        })
        dic.intValue("freNumAve").flatMap({
            info = "\($0)均次 / " + info
        })
        dic.intValue("groupNum").flatMap({
            info = "\($0)组 / " + info
        })
        infoLB.text = info
        
        let cdate = dic.stringValue("createTime") ?? ""
        createTimeLB.text = ToolClass.compareCurrentTime(date: cdate)
        
        let isHidden = compareDate(cdate) < 7
        editBtn.isHidden = !isHidden
        delBtn.isHidden = !isHidden
        
        let type = dic["type"] as! Int
        typeLB.isHidden = type == 20 ? false : true
        
        while (gestureRecognizers?.count ?? 0) > 0 {
            gestureRecognizers?.first.flatMap({
                removeGestureRecognizer($0)
            })
        }
    }
    
    func setStyle(_ select: Bool) {
        if select {
            bgView.layer.borderColor = YellowMainColor.cgColor
            bgView.layer.borderWidth = 1
        }else{
            bgView.layer.borderColor = YellowMainColor.cgColor
            bgView.layer.borderWidth = 0
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
    
    @IBAction private func editAction(_ sender: UIButton) {
        delegate?.overviewHeader(self, didClickEditBtn: sender, data: data)
    }
    
    @IBAction private func delAction(_ sender: UIButton) {
        delegate?.overviewHeader(self, didClickDelBtn: sender, data: data)
    }
}


