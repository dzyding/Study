//
//  DepositTitleOneLBCell.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol DepositTitleOneLBCellDelegate: class {
    func oneLBCell(
        _ oneLBCell: DepositTitleOneLBCell,
        didClickBtn btn: UIButton,
        amount: [String : Any]
    )
}

class DepositTitleOneLBCell: UITableViewCell {
    
    weak var delegate: DepositTitleOneLBCellDelegate?

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    //10 0
    @IBOutlet weak var typeRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var arrowIV: UIImageView!
    
    private var amount: [String : Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any], row: Int, type: DepositType) {
        self.amount = data
        let selected = data.boolValue(Public_isSelected) ?? false
        contentView.backgroundColor = selected ? dzy_HexColor(0xfff2e9) : .white
        titleLB.text = type.title() + "-\(row + 1)"
        let price = data.doubleValue("price") ?? 0
        let status = data.intValue("status") ?? 0
        detailLB.attributedText = type.detail(price, takePrice: nil)
        
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
            typeRightLC.constant = 0
        }
        // 下面等于 0 的都没判断，相当于直接隐藏
        hideBtnFunc(true)
        switch type {
        case .buy_flow:
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请盈余结算"
                    btn.tag = DepositFunType.reBuyFlow.rawValue
                }else if price < 0 {
                    hideBtnFunc(false)
                    typeLB.text = "补缴结算"
                    btn.tag = DepositFunType.payBuyFlow.rawValue
                }
            }
        case .buy_look:
            //10.正常（申请驳回） 15.暂押  20.申请成功  90.扣除 95.结算完成（退款成功）
            if status == 10 {
                if price > 0 {
                    hideBtnFunc(false)
                    typeLB.text = "申请退还"
                    btn.tag = DepositFunType.reLook.rawValue
                }
            }else if status == 20 || status == 25 {
                refundedFunc(status)
            }else {
                hideBtnFunc(true)
            }
        default:
            break
        }
    }
    
    @IBAction private func clickAction(_ sender: UIButton) {
        delegate?.oneLBCell(self, didClickBtn: sender, amount: amount)
    }
}
