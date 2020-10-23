//
//  HouseBidDetailSellCell.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseBidDetailSellCellDelegate {
    /// 成交
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectDealBtn btn: UIButton, data: [String : Any])
    /// 删除报价
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectDeleteBtn btn: UIButton, data: [String : Any])
    /// 修改报价
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectEditBtn btn: UIButton, data: [String : Any])
}

class HouseBidDetailSellCell: UITableViewCell {
    
    @IBOutlet weak var totalLB: UILabel!
    /// 现金100.00万，贷款100.00万
    @IBOutlet weak var moneyLB: UILabel!
    
    @IBOutlet weak var buyerView: UIView!
    
    @IBOutlet weak var sellerView: UIView!
    
    private var data: [String : Any] = [:]
    /// 成交价的 logo
    @IBOutlet weak var cjIV: UIImageView!
    
    weak var delegate: HouseBidDetailSellCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(
        _ identity: Identity,
        data: [String : Any],
        isDeposit: Bool,
        orderMsg: [String : Any]?
    ) {
        self.data = data
        let total = data.doubleValue("total") ?? 0
        let cach = data.doubleValue("cash") ?? 0
        let loan = data.doubleValue("loan") ?? 0
        totalLB.textColor = isDeposit ? dzy_HexColor(0x2571FD) : Font_Dark
        totalLB.text = "\(total.decimalStr)万"
        moneyLB.text = "现金\(cach.decimalStr)万，贷款\(loan.decimalStr)万"
        cjIV.isHidden = true
        
        if orderMsg != nil {
            sellerView.isHidden = true
            buyerView.isHidden = true
            // 10为买方成交
            let type = orderMsg?.intValue("type") ?? 10
            let ototal = orderMsg?.doubleValue("total") ?? 0
            let ocach = orderMsg?.doubleValue("cash") ?? 0
            if type == 10,
                ototal == total,
                ocach == cach
            {
                cjIV.isHidden = false
            }
        }else {
            buyerView.isHidden = false
            sellerView.isHidden = identity == .buyer
        }
    }
    
    @IBAction func dealAction(_ sender: UIButton) {
        delegate?.sellCell(self, didSelectDealBtn: sender, data: data)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        delegate?.sellCell(self, didSelectEditBtn: sender, data: data)
    }
    
    @IBAction func delAction(_ sender: UIButton) {
        delegate?.sellCell(self, didSelectDeleteBtn: sender, data: data)
    }
}
