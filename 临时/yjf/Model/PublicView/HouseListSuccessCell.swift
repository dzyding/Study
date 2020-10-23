//
//  HouseListSuccessCell.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseListSuccessCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    /// 117人次竞买
    @IBOutlet weak var bidNumLB: UILabel!
    /// 发布后56天成交
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var selectBtnLeftLC: NSLayoutConstraint!
    
    @IBOutlet weak var paddingView: UIView!
    
    private var house: [String : Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func batchUpdateUI(_ data: [String : Any], isBatch: Bool) {
        selectBtnLeftLC.constant = isBatch ? 0 : -32
        updateUI(data)
    }
 
    func paddingUpdateUI(_ data: [String : Any]) {
        paddingView.isHidden = false
        updateUI(data)
    }
    
    func updateUI(_ data: [String : Any]) {
        house = data
        // 房源名
        let title = house.stringValue("houseTitle") ?? ""
        if let index = title.lastIndex(where: {$0 == "-"}) {
            titleLB.text = String(title[..<index])
        }else {
            titleLB.text = title
        }
        // 人次竞买
        let bidNum = house.intValue("competeNum") ?? 0
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        priceLB.text = "\(data.doubleValue("total"), optStyle: .toInt)万"
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let finishStr = data.stringValue("finishTime"),
            let publishStr = data.stringValue("publishTime"),
            let finish = format.date(from: finishStr),
            let publish = format.date(from: publishStr)
        else {return}
        let candler = Calendar.current
        let day = candler.dateComponents([.day], from: publish, to: finish).day ?? 0
        let finishCom = candler.dateComponents([.year, .month], from: publish)
        timeLB.text = "\(finishCom.year ?? 0)年\(finishCom.month ?? 0)月，发布后\(max(1, day))天成交"
    }
}
