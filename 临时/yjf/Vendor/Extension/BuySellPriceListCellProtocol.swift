//
//  BuySellPriceListCellProtocol.swift
//  YJF
//
//  Created by edz on 2019/9/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol BuySellPriceListCell: class {
    
    var _buyWidthLC: NSLayoutConstraint {get}
    /// 滚动价格的背景view
    var _buyBgView: UIView {get}
    
    var _buyLB: UILabel {get}
    
    var _sellBgView: UIView {get}
    
    var _sellWidthLC: NSLayoutConstraint {get}
    
    var _sellLB: UILabel {get}
    
    var _buyScrollLB: ScrollLabelView {get}
    
    var _sellScrollLB: ScrollLabelView {get}
    
    func price_AddSubView()
    func price_UpdateUI(_ data: [String : Any])
    func updatePriceAction(_ total: Int)
}

extension BuySellPriceListCell {
    func price_AddSubView() {
        _buyBgView.addSubview(_buyScrollLB)
        _sellBgView.addSubview(_sellScrollLB)
        _buyScrollLB.snp.makeConstraints { (make) in
            make.edges.equalTo(_buyBgView).inset(UIEdgeInsets.zero)
        }
        _sellScrollLB.snp.makeConstraints { (make) in
            make.edges.equalTo(_sellBgView).inset(UIEdgeInsets.zero)
        }
    }
    
    func price_UpdateUI(_ data: [String : Any]) {
        // 买价
        let buyList = data.arrValue("buyList") ?? []
        let buyprice = buyList.compactMap({$0.doubleValue("total")})
        let buycolors = buyList.compactMap(
            {$0.intValue("effect") == 1 ? BuyDeposit_Color : NoDeposit_Color}
        )
        _buyLB.isHidden = buyprice.count == 0
        _buyScrollLB.isHidden = buyprice.count == 0
        let buyHandler: (CGFloat) -> () = { [weak self] max in
            self?._buyWidthLC.constant = max
        }
        _buyScrollLB.initUI(buyprice, colors: buycolors, handler: buyHandler)
        
        // 卖价
        let sellprice = data.arrValue("sellList")?
            .compactMap({$0.doubleValue("total")}) ?? []
        _sellLB.isHidden = sellprice.count == 0
        _sellScrollLB.isHidden = sellprice.count == 0
        let sellHandler: (CGFloat) -> () = { [weak self] max in
            self?._sellWidthLC.constant = max
        }
        let isSellDeposit = data.intValue("isflag") == 1
        
        let sellcolor = isSellDeposit ? SellDeposit_Color : NoDeposit_Color
        let sellcolors = [UIColor](repeating: sellcolor, count: sellprice.count)
        _sellScrollLB.initUI(sellprice,
                             colors: sellcolors,
                             handler: sellHandler)
    }
    
    func updatePriceAction(_ total: Int) {
        _buyScrollLB.updateIndex(total)
        _sellScrollLB.updateIndex(total)
    }
}
