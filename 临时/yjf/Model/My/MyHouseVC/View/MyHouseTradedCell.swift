//
//  MyHouseTradedCell.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol MyHouseTradedCellDelegate: class {
    func tradedCell(_ cell: MyHouseTradedCell, didClickBtn btn: UIButton, index: Int)
    func tradedCell(_ cell: MyHouseTradedCell, selectedHouse btn: UIButton, index: Int)
}

class MyHouseTradedCell: UITableViewCell {
    
    weak var delegate: MyHouseTradedCellDelegate?
    /// 成交日期
    @IBOutlet weak var timeLB: UILabel!
    /// 房源名字
    @IBOutlet weak var titleLB: UILabel!
    /// 户型
    @IBOutlet weak var layoutLB: UILabel!
    /// 竞买次数
    @IBOutlet weak var bidNumLB: UILabel!
    /// 成交价格
    @IBOutlet weak var totalPriceLB: UILabel!
    /// 价格详情
    @IBOutlet weak var priceDetailLB: UILabel!
    /// 房源状态
    @IBOutlet weak var typeLB: UILabel!
    /// 锁状态
    @IBOutlet weak var lockTypeLB: UILabel!
    /// 锁操作相关的按钮
    @IBOutlet weak var lockBtn: UIButton!
    
    @IBOutlet weak var lockView: UIView!
    /// 进展按钮
    @IBOutlet weak var progressBtn: UIButton!
    /// 进展
    @IBOutlet weak var progressLB: UILabel!
    /// -15 0
    @IBOutlet weak var progressRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UIView!
    /// 40 15
    @IBOutlet weak var dealPriceLBTopLC: NSLayoutConstraint!
    
    private var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        delegate?.tradedCell(self, didClickBtn: sender, index: index)
    }
    
    @IBAction func clickHouseAction(_ sender: UIButton) {
        delegate?.tradedCell(self, selectedHouse: sender, index: index)
    }
    
    func updateUI(_ data: [String : Any], index: Int) {
        self.index = index
        let type = (data[HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        
        titleLB.text = data.stringValue("houseTitle")
        let layout = data.stringValue("layout") ?? ""
        let areaNum = data.doubleValue("area") ?? 0
        layoutLB.text = layout + " " + "\(areaNum.decimalStr)㎡"
        let bidNum = data.intValue("competeNum") ?? 0
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        
        let order = data.dicValue("map")
        timeLB.text = order?
            .stringValue("finishTime")?
            .components(separatedBy: " ").first
        let totalPrice = order?.doubleValue("total") ?? 0
        let cash = order?.doubleValue("cash") ?? 0
        let loan = order?.doubleValue("loan") ?? 0
        totalPriceLB.text = "\(totalPrice.moneyStr)万"
        priceDetailLB.text = "其中：现金\(cash.moneyStr)万，贷款\(loan.moneyStr)万"
        
        let taskName = data.stringValue("taskName") ?? ""
        MyHouseCellHelper.typeLB(typeLB, type: type)
        switch type {
        case .signed(let lockType):
            progressView.isHidden = false
            dealPriceLBTopLC.constant = 40.0
            
            if taskName.count > 0 {
                progressLB.text = taskName
            }else {
                progressLB.text = "结算"
            }
            
            progressRightLC.constant = -15
            progressBtn.isHidden = false
            checkLockType(lockType)
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
        case .traded:
            lockBtn.isHidden = true
            lockView.isHidden = false
            progressView.isHidden = false
            dealPriceLBTopLC.constant = 40.0
            
            progressLB.text = "签约"
            progressRightLC.constant = 0
            progressBtn.isHidden = true
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: .installSuccess)
        case .end(let lockType):
            progressView.isHidden = true
            checkLockType(lockType)
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
        default:
            break
        }
    }
    
    private func checkLockType(_ type: MyHouseType.LockType) {
        MyHouseCellHelper.lockTypeLB(lockTypeLB, type: type)
        switch type {
        case .canRemove, .installSuccess:
            lockView.isHidden = false
            lockBtn.isHidden = false
            dealPriceLBTopLC.constant = 40.0
            MyHouseCellHelper.unlockBtn(lockBtn)
        case .removing:
            lockView.isHidden = false
            lockBtn.isHidden = true
            dealPriceLBTopLC.constant = 40.0
        case .removed:
            lockView.isHidden = true
            dealPriceLBTopLC.constant = 15.0
        default:
            lockView.isHidden = false
            lockBtn.isHidden = true
            dealPriceLBTopLC.constant = 40.0
            break
        }
    }
}
