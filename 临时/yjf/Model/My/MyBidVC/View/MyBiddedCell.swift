//
//  MyBiddedCell.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol MyBiddedCellDelegate {
    func biddedCell(_ cell: MyBiddedCell, didSelectBtn btn: UIButton, data: [String : Any])
}

class MyBiddedCell: UITableViewCell {
    /// 2019-03-01 12:22
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var titleLB: UILabel!
    /// 4室2厅 200.00㎡
    @IBOutlet weak var layoutLB: UILabel!
    
    @IBOutlet weak var bidNumLB: UILabel!
    /// 我的竞买价：150.00万
    @IBOutlet weak var totalPriceLB: UILabel!
    /// 其中：现金50.00万，贷款100.00万
    @IBOutlet weak var detailPriceLB: UILabel!
    
    @IBOutlet weak var progressBtn: UIButton!
    
    @IBOutlet weak var progressLB: UILabel!
    /// -15 0
    @IBOutlet weak var progressTrailLC: NSLayoutConstraint!
    
    weak var delegate: MyBiddedCellDelegate?
    
    var data: [String : Any] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func btnAction(_ sender: UIButton) {
        delegate?.biddedCell(self, didSelectBtn: sender, data: data)
    }
    
    func updateUI(_ data: [String : Any]) {
        self.data = data
        let total = data.doubleValue("total") ?? 0
        let cash  = data.doubleValue("cash") ?? 0
        let loan  = data.doubleValue("loan") ?? 0
        let house = data.dicValue("house") ?? [:]
        let layout = house.stringValue("layout") ?? ""
        let area   = house.doubleValue("area") ?? 1
        let status = data.intValue("status") ?? 10
        let statusType = data.intValue("statusType") ?? -1
        let bidNum = house.intValue("competeNum") ?? 0
        
        totalPriceLB.text = "\(total.moneyStr)万"
        detailPriceLB.text = "其中：现金\(cash.moneyStr)万，贷款\(loan.moneyStr)万"
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        timeLB.text = data.stringValue("finishTime")
        titleLB.text = house.stringValue("houseTitle")
        layoutLB.text = layout + " \(area.decimalStr)㎡"
        
        if let task = data.stringValue("taskName"),
            task.count > 0
        {
            progressLB.text = task
        }else {
            progressLB.text = "签约"
        }
        if statusType == 99 {
            progressTrailLC.constant = 0
            progressBtn.isHidden = true
        }else if status == 30 || status == 35 {
            // 已签约
            progressTrailLC.constant = -15
            progressBtn.isHidden = false
        }else {
            progressTrailLC.constant = 0
            progressBtn.isHidden = true
        }
    }
}
