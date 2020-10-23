//
//  MyBiddingCell.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol MyBiddingCellDelegate {
    func biddingCell(_ biddingCell: MyBiddingCell, didSelected index: Int)
    func biddingCell(_ biddingCell: MyBiddingCell, didClickPayDepositBtn index: Int)
}

class MyBiddingCell: UITableViewCell {
    
    weak var delegate: MyBiddingCellDelegate?
    
    private var index: Int = 0
    /// 竞买时间
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var titleLB: UILabel!
    /// 4室2厅 200.00㎡
    @IBOutlet weak var layoutLB: UILabel!
    /// 117人次竞买
    @IBOutlet weak var buyNumLB: UILabel!
    /// 我的竞买价：150.00万
    @IBOutlet weak var myBidLB: UILabel!
    /// 其中：现金50.00万，贷款100.00万
    @IBOutlet weak var bidDetailLB: UILabel!
    /// 选择按钮
    @IBOutlet weak var selectBtn: UIButton!
    /// 最后一行
    @IBOutlet weak var lastLineView: UIView!
    /// 我的竞买价到底部的距离 41 15
    @IBOutlet weak var mypriceLBBottomLC: NSLayoutConstraint!
    /// 最左边的按钮 -32 0
    @IBOutlet weak var btnLeftLC: NSLayoutConstraint!
    
    
    /// 滚动价格的宽度
    @IBOutlet weak var buyWidthLC: NSLayoutConstraint!
    /// 滚动价格的背景view
    @IBOutlet weak var buyBgView: UIView!
    /// 买：
    @IBOutlet weak var buyLB: UILabel!
    
    @IBOutlet weak var sellBgView: UIView!
    
    @IBOutlet weak var sellWidthLC: NSLayoutConstraint!
    
    @IBOutlet weak var sellLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        price_AddSubView()
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.biddingCell(self, didSelected: index)
    }
    
    @IBAction func payDepositAction(_ sender: UIButton) {
        delegate?.biddingCell(self, didClickPayDepositBtn: index)
    }
    
    /// 无批量操作的界面使用
    func updateUI(
        _ data: [String : Any],
        isBatch: Bool,
        index: Int
    ) {
        self.index = index
        let house = data.dicValue("house") ?? [:]
        let layout = house.stringValue("layout") ?? ""
        let area   = house.doubleValue("area") ?? 1
        
        let info  = data.dicValue("houseBuy") ?? [:]
        let total = info.doubleValue("total") ?? 0
        let cash  = info.doubleValue("cash") ?? 0
        let loan  = info.doubleValue("loan") ?? 0
        let isHidden = info.intValue("effect")
        
        selectBtn.isSelected = data.boolValue(Public_isSelected) ?? false
        myBidLB.text = "\(total.moneyStr)万"
        bidDetailLB.text = "其中：现金\(cash.moneyStr)万，贷款\(loan.moneyStr)万"
        let bidNum = house.intValue("competeNum") ?? 0
        buyNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        timeLB.text = info.stringValue("updateTime")
        titleLB.text = house.stringValue("houseTitle")
        layoutLB.text = layout + " \(area.decimalStr)㎡"
        
        if isHidden == 1 {
            lastLineView.isHidden = true
            mypriceLBBottomLC.constant = 35
        }else {
            lastLineView.isHidden = false
            mypriceLBBottomLC.constant = 61
        }
        btnLeftLC.constant = isBatch ? 0 : -32
        price_UpdateUI(house)
    }
    
    //    MARK: - 懒加载
    private lazy var buyScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(
            frame: buyBgView.bounds, font: dzy_Font(11)
        )
        return view
    }()
    
    private lazy var sellScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(
            frame: sellBgView.bounds, font: dzy_Font(11)
        )
        return view
    }()
}

extension MyBiddingCell: BuySellPriceListCell {
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
