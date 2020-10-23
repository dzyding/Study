//
//  WatchHouseInfoView.swift
//  YJF
//
//  Created by edz on 2019/5/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class WatchHouseInfoView: UIView {
    
    @IBOutlet weak var nameLB: UILabel!
    //4室2厅 200.00㎡
    @IBOutlet weak var typeLB: UILabel!
    //117人次竞买
    @IBOutlet weak var bidNumLB: UILabel!

    @IBOutlet weak var buyBgView: UIView!
    @IBOutlet weak var buyWidthLC: NSLayoutConstraint!
    @IBOutlet weak var buyLB: UILabel!
    
    @IBOutlet weak var sellBgView: UIView!
    @IBOutlet weak var sellLB: UILabel!
    @IBOutlet weak var sellWidthLC: NSLayoutConstraint!
    
    private lazy var buyScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: buyBgView.bounds, font: dzy_Font(13))
        return view
    }()
    
    private lazy var sellScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: sellBgView.bounds, font: dzy_Font(13))
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        price_AddSubView()
    }
    
    func updateUI(_ house: [String : Any]) {
        let layout = house.stringValue("layout") ?? ""
        let area = house.doubleValue("area") ?? 0
        nameLB.text = house.stringValue("houseTitle")
        typeLB.text = layout + " " + area.decimalStr + "㎡"
        let bidNum = house.intValue("competeNum") ?? 0
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        
        price_UpdateUI(house)
    }
}

extension WatchHouseInfoView: BuySellPriceListCell {
    var _buyWidthLC: NSLayoutConstraint {
        return buyWidthLC
    }
    
    var _buyBgView: UIView {
        return buyBgView
    }
    
    var _buyLB: UILabel {
        return buyLB
    }
    
    var _sellBgView: UIView {
        return sellBgView
    }
    
    var _sellWidthLC: NSLayoutConstraint {
        return sellWidthLC
    }
    
    var _sellLB: UILabel {
        return sellLB
    }
    
    var _buyScrollLB: ScrollLabelView {
        return buyScrollLB
    }
    
    var _sellScrollLB: ScrollLabelView {
        return sellScrollLB
    }
}
