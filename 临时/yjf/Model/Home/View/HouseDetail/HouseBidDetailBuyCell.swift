//
//  HouseBidDetailBuyCell.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseBidDetailBuyCellDelegate {
    func buyCell(_ buyCell: HouseBidDetailBuyCell, didSelectSureBtn btn: UIButton, data: [String : Any])
}

class HouseBidDetailBuyCell: UITableViewCell {
    
    weak var delegate: HouseBidDetailBuyCellDelegate?

    @IBOutlet weak var rankIV: UIImageView!
    
    @IBOutlet weak var rankLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var sureBtn: UIButton!
    
    private var data: [String : Any] = [:]
    /// 成交价的 logo
    @IBOutlet weak var cjIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(
        _ indexPath: IndexPath,
        identity: Identity,
        data: [String : Any],
        orderMsg: [String : Any]?
    ) {
        switch indexPath.row {
        case 0:
            rankIV.image = UIImage(named: "bid_detail_first")
            rankLB.text = nil
        case 1:
            rankIV.image = UIImage(named: "bid_detail_second")
            rankLB.text = nil
        case 2:
            rankIV.image = UIImage(named: "bid_detail_third")
            rankLB.text = nil
        default:
            rankIV.image = nil
            rankLB.text = "\(indexPath.row + 1)"
        }
        updateUI(data, identity: identity, orderMsg: orderMsg)
        switch identity {
        case .buyer:
            sureBtn.isHidden = true
            let userId = data.intValue("userId")
            let isSelf = userId == DataManager.getUserId()
            nameLB.text = isSelf ? "我" : data.stringValue("name")
            nameLB.textColor = isSelf ? dzy_HexColor(0xFF3A3A) : Font_Dark
            setBgColor(isSelf)
        case .seller:
            let isSelected = data.boolValue(Public_isSelected) ?? false
            sureBtn.isHidden = !isSelected
            nameLB.text = data.stringValue("name")
            nameLB.textColor = Font_Dark
            setBgColor(isSelected)
        }
    }
    
    private func updateUI(_ data: [String : Any], identity: Identity, orderMsg: [String : Any]?) {
        self.data = data
        let total = data.doubleValue("total") ?? 0
        let cach = data.doubleValue("cash") ?? 0
        let loan = data.doubleValue("loan") ?? 0
        nameLB.text = data.stringValue("name")
        priceLB.text = "\(total.decimalStr)万"
        priceLB.textColor = data.intValue("effect") == 1 ?
            dzy_HexColor(0xFD7E25) : dzy_HexColor(0xA3A3A3)
        detailLB.text = "现金\(cach.decimalStr)万，贷款\(loan.decimalStr)万"
        
        // 卖方执行的成交操作
        if orderMsg?.intValue("type") == 20 {
            cjIV.isHidden = orderMsg?.intValue("buyerId") != data.intValue("userId")
        }else {
            cjIV.isHidden = true
        }
    }
    
    private func setBgColor(_ isSelected: Bool) {
        contentView.backgroundColor = isSelected ?
            dzy_HexColor(0xFFF2E9) : .white
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        delegate?.buyCell(self, didSelectSureBtn: sender, data: data)
    }
}
