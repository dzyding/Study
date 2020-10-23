//
//  TrainHistoryHeaderView.swift
//  PPBody
//
//  Created by edz on 2020/1/7.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainHistoryHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var mWeightLB: UILabel!
    @IBOutlet weak var mGroupLB: UILabel!
    
    @IBOutlet weak var nearDayLB: UILabel!
    
    @IBOutlet weak var dayLB: UILabel!
    
    @IBOutlet weak var monthLB: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var totalWeightLB: UILabel!
    
    @IBOutlet weak var totalGroupLB: UILabel!
    
    private var isInit: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateUI(_ dic: [String : Any]) {
        let time = dic.stringValue("time") ?? ""
        let timeArr = time.components(separatedBy: "-")
        if timeArr.count == 3 {
            nearDayLB.isHidden = true
            dayLB.isHidden = false
            monthLB.isHidden = false
            dayLB.text = "\(timeArr[2])"
            monthLB.text = "\(timeArr[1])月"
        }else {
            nearDayLB.isHidden = false
            dayLB.isHidden = true
            monthLB.isHidden = true
            nearDayLB.text = timeArr.first
        }
        let totalW = dic.doubleValue("totalWeight") ?? 0
        let totalGN = dic.intValue("totalGroupNum") ?? 0
        totalWeightLB.text = totalW.decimalStr
        totalGroupLB.text = "\(totalGN)"
        
        if isInit {return}
        isInit = true
        initUI()
    }
    
    private func initUI() {
        nearDayLB.font = dzy_FontBlod(30)
        dayLB.font = dzy_FontBlod(21)
        monthLB.font = dzy_FontBlod(12)
        [mGroupLB, mWeightLB].forEach { (label) in
            label?.font = dzy_FontBlod(10)
        }
        [totalWeightLB, totalGroupLB].forEach { (label) in
            label?.font = dzy_FontBBlod(18)
        }
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        bgView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
    }
}
