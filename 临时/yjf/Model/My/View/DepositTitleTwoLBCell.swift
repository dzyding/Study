//
//  DepositTitleTwoLBCell.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol DepositTitleTwoLBCellDelegate: class {
    func twoLBCell(
        _ twoLBCell: DepositTitleTwoLBCell,
        didClickBtn btn: UIButton,
        amount: [String : Any]
    )
}

class DepositTitleTwoLBCell: UITableViewCell {
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var houseLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    //10 0
    @IBOutlet weak var typeRightLC: NSLayoutConstraint!
    /// 暂押
    @IBOutlet weak var useLB: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    /// 箭头
    @IBOutlet weak var arrowIV: UIImageView!
    
    private var amount: [String : Any] = [:]
    
    weak var delegate: DepositTitleTwoLBCellDelegate?
    
    //swiftlint:disable:next function_body_length
    func updateUI(_ data: [String : Any], row: Int, type: DepositType) {
        self.amount = data
        let selected = data.boolValue(Public_isSelected) ?? false
        contentView.backgroundColor = selected ? dzy_HexColor(0xfff2e9) : .white
        titleLB.text = type.title() + "-\(row + 1)"
        let price = data.doubleValue("price") ?? 0
        let takeprice = data.doubleValue("takePrice")
        detailLB.attributedText = type.detail(price, takePrice: takeprice)
        houseLB.text = "房源：" + (data.stringValue("houseTitle") ?? "")
        
        func hideBtnFunc(_ x: Bool) {
            btn.tag = 0
            btn.isHidden = x
            typeLB.isHidden = x
            arrowIV.isHidden = x
        }
        
        func refundedFunc(_ status: Int) {
            btn.isHidden = true
            typeLB.text = status == 20 ? "退还中" : "已退还"
            arrowIV.isHidden = true
            useLB.isHidden = true
            typeRightLC.constant = 0
        }
        
        useLB.isHidden = true
        hideBtnFunc(true)
        //.正常（申请驳回） 15.暂押  20.申请成功  90.扣除 95.结算完成（退款成功）
        let status = data.intValue("status") ?? 0
        switch type {
        case .buy_deposit:
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请退还"
                    btn.tag = DepositFunType.reBuyDeposit.rawValue
                }
            }else if status == 15 {
                hideBtnFunc(true)
                useLB.isHidden = false
            }else if status == 20 || status == 25 {
                refundedFunc(status)
            }else {
                hideBtnFunc(true)
            }
        case .sell_lock:
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请退还"
                    btn.tag = DepositFunType.reLock.rawValue
                }
            }else if status == 15 {
                hideBtnFunc(true)
                useLB.isHidden = false
            }else if status == 20 || status == 25 {
                refundedFunc(status)
            }else {
                hideBtnFunc(true)
            }
        case .sell_flow:
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请盈余结算"
                    btn.tag = DepositFunType.reSellFlow.rawValue
                }else if price < 0 {
                    hideBtnFunc(false)
                    typeLB.text = "补缴结算"
                    btn.tag = DepositFunType.paySellFlow.rawValue
                }
            }
        case .sell_deposit:
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请退还"
                    btn.tag = DepositFunType.reSellDeposit.rawValue
                }
            }else if status == 15 {
                hideBtnFunc(true)
                useLB.isHidden = false
            }else if status == 20 || status == 25 {
                refundedFunc(status)
            }else {
                hideBtnFunc(true)
            }
        default:
            break
        }
    }
    
    @IBAction func clickAction(_ sender: UIButton) {
        delegate?.twoLBCell(self, didClickBtn: sender, amount: amount)
    }
}
