//
//  ShowFirstHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol ShowFirstHeaderViewDelegate {
    func header(_ header: ShowFirstHeaderView, didClickPickerBtn btn: UIButton)
    func header(_ header: ShowFirstHeaderView, didClickRechargeBtn btn: UIButton)
}

class ShowFirstHeaderView: UIView {
    
    weak var delegate: ShowFirstHeaderViewDelegate?
    
    @IBOutlet weak var pickBtn: UIButton!
    /// 房源名字
    @IBOutlet weak var showLB: UILabel!
    /// 优显账户
    @IBOutlet weak var accountLB: UILabel!
    /// 余额
    @IBOutlet weak var moneyLB: UILabel!
    /// 展示次数
    @IBOutlet weak var topNumLB: UILabel!
    /// 状态
    @IBOutlet weak var statusLB: UILabel!
    /// 累计展示天数
    @IBOutlet weak var totalDayLB: UILabel!
    /// 累计扣费
    @IBOutlet weak var totalPriceLB: UILabel!
    
    func closeAction() {
        pickBtn.isSelected = false
    }
    
    @IBAction func pickAction(_ sender: UIButton) {
        sender.isSelected = true
        delegate?.header(self, didClickPickerBtn: sender)
    }
    
    @IBAction func rechargeAction(_ sender: UIButton) {
        delegate?.header(self, didClickRechargeBtn: sender)
    }
    
    func updateTitle(_ title: String?, index: Int) {
        showLB.text = title
        accountLB.text = "优显广告账户-\(index + 1)"
    }
    
    //    MARK: - 刷新当前的数据
    func updateUI(_ data: [String : Any]) {
        totalDayLB.text = String(format: "%ld天", data.intValue("allDayNum") ?? 0)
        totalPriceLB.text = String(format: "-%.2lf元", data.doubleValue("allPrice") ?? 0)
        moneyLB.text = String(format: "%.2lf元",data.doubleValue("topPrice") ?? 0)
        topNumLB.text = "\(data.intValue("top") ?? 0)次"
        
        let isTop = data.intValue("isTop") ?? 0
        if isTop == 1 {
            statusLB.text = "展示中"
            statusLB.textColor = dzy_HexColor(0x26CC85)
        }else {
            statusLB.text = "已停止"
            statusLB.textColor = dzy_HexColor(0xFD7E25)
        }
    }
}
