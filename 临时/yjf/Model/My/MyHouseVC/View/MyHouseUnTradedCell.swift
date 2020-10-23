//
//  MyHouseUnTradedCell.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol MyHouseUnTradedCellDelegate {
    func unTradedCell(_ cell: MyHouseUnTradedCell, didClickBtn btn: UIButton, index: Int)
    func unTradedCell(_ cell: MyHouseUnTradedCell, selectedHouse btn: UIButton, index: Int)
}

/// 待审核 待发布 已发布 已撤销
class MyHouseUnTradedCell: UITableViewCell {
    
    private var index: Int = 0
    
    weak var delegate: MyHouseUnTradedCellDelegate?
    /// 房源名字
    @IBOutlet weak var titleLB: UILabel!
    /// 户型
    @IBOutlet weak var layoutLB: UILabel!
    /// 竞买人次
    @IBOutlet weak var buyNumLB: UILabel!
    
    @IBOutlet weak var depositView: UIView!
    
    @IBOutlet weak var lockTypeLB: UILabel!
    
    @IBOutlet weak var lockBtn: UIButton!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var priceBtn: UIButton!
    
    @IBOutlet weak var undoBtn: UIButton!
    /// 110 18
    @IBOutlet weak var titleLBRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var houseBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// 在售界面，这里是交保证金的按钮。  历史界面，这里隐藏。
    @IBAction func buyDepositAction(_ sender: UIButton) {
        delegate?.unTradedCell(self, didClickBtn: sender, index: index)
    }
    
    /// 在售界面，这里是撤销房源。  历史界面，这里都是发布房源。
    @IBAction func undoAction(_ sender: UIButton) {
        delegate?.unTradedCell(self, didClickBtn: sender, index: index)
    }
    
    /// 在售界面，这里是申请装锁。  历史界面，这里是申请拆锁。
    @IBAction func lockAction(_ sender: UIButton) {
        delegate?.unTradedCell(self, didClickBtn: sender, index: index)
    }
    
    /// 在售界面，这里是添加报价按钮。  历史界面，这个按钮隐藏
    @IBAction func priceAction(_ sender: UIButton) {
        delegate?.unTradedCell(self, didClickBtn: sender, index: index)
    }
    
    @IBAction func clickHouseAction(_ sender: UIButton) {
        if sender.tag == 0 {
            delegate?.unTradedCell(self, selectedHouse: sender, index: index)
        }else {
            delegate?.unTradedCell(self, didClickBtn: sender, index: index)
        }
    }
    
    func updateUI(_ data: [String : Any], index: Int) {
        self.index = index
        let type = (data[HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        titleLB.text = data.stringValue("houseTitle")
        let layout = data.stringValue("layout") ?? ""
        let areaNum = data.doubleValue("area") ?? 0
        layoutLB.text = layout + " " + "\(areaNum.decimalStr)㎡"
        let bidNum = data.intValue("competeNum") ?? 0
        buyNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        
        MyHouseCellHelper.typeLB(typeLB, type: type)
        // = 0 是跳详情页
        houseBtn.tag = 0
        priceBtn.isHidden = true
        titleLBRightLC.constant = 18.0
        switch type {
        case .waitAudit(let lockType, let isDeposit, _):
            depositView.isHidden = isDeposit
            MyHouseCellHelper.undoBtn(undoBtn)
            MyHouseCellHelper.editBtn(houseBtn)
            
            priceBtn.isHidden = false
            titleLBRightLC.constant = 110.0
            MyHouseCellHelper.priceBtn(priceBtn)
            
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
            checkLockBtnType(lockType)
        case .auditSuccess(let lockType, let isDeposit, _):
            depositView.isHidden = isDeposit
            MyHouseCellHelper.undoBtn(undoBtn)
            
            priceBtn.isHidden = false
            titleLBRightLC.constant = 110.0
            MyHouseCellHelper.priceBtn(priceBtn)
            
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
            checkLockBtnType(lockType)
        case .released(let lockType, let isDeposit, _): // 已发布
            depositView.isHidden = isDeposit
            //(这里不用考虑已经报价的情况，那是另一个cell，所以直接显示就行)
            priceBtn.isHidden = false
            titleLBRightLC.constant = 110.0
            MyHouseCellHelper.priceBtn(priceBtn)
            
            MyHouseCellHelper.undoBtn(undoBtn)
            
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
            checkLockBtnType(lockType)
        case .undo(let lockType),
             .auditFail(let lockType): // 已撤销
            depositView.isHidden = true
            MyHouseCellHelper.releaseBtn(undoBtn)
            
            MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
            checkLockBtnType(lockType, isUndo: true)
        default:
            break
        }
    }
    
    //    MARK: - 检查锁的状态
    private func checkLockBtnType(
        _ lockType: MyHouseType.LockType,
        isUndo: Bool = false
    ) {
        switch lockType {
        case .unInstall where isUndo == false,
             .installFail where isUndo == false:
            lockBtn.isHidden = false
            MyHouseCellHelper.lockBtn(lockBtn)
        case .noDeposit where isUndo == false:
            lockBtn.isHidden = false
            MyHouseCellHelper.noDepositBtn(lockBtn)
        case .canRemove where isUndo == true: // 判断是否为撤销状态
            lockBtn.isHidden = false
            MyHouseCellHelper.unlockBtn(lockBtn)
        default:
            lockBtn.isHidden = true
        }
    }
}
