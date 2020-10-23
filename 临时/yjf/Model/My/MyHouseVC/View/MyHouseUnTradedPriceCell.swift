//
//  MyHouseUnTradedPriceCell.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol MyHouseUnTradedPriceCellDelegate: class {
    func priceCell(
        _ pirceCell: MyHouseUnTradedPriceCell,
        didClickBtn btn: UIButton,
        withIndex index: Int
    )
    func priceCell(
        _ pirceCell: MyHouseUnTradedPriceCell,
        selectedHouse btn: UIButton,
        withIndex index: Int
    )
}

/// 已发布
class MyHouseUnTradedPriceCell: UITableViewCell {
    
    weak var delegate: MyHouseUnTradedPriceCellDelegate?
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var layoutLB: UILabel!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var bidNumLB: UILabel!

    @IBOutlet weak var lockTypeLB: UILabel!
    
    @IBOutlet weak var depositView: UIView!
    /// 添加报价的按钮
    @IBOutlet weak var priceBtn: UIButton!
    /// 撤销按钮
    @IBOutlet weak var undoBtn: UIButton!
    /// 装/拆锁按钮
    @IBOutlet weak var lockBtn: UIButton!
    /// = 0 跳转房源详情，不然就是编辑
    @IBOutlet weak var houseBtn: UIButton!
    
    private var index: Int = 0
    
    /// 滚动价格的宽度
    @IBOutlet weak var buyWidthLC: NSLayoutConstraint!
    /// 滚动价格的背景view
    @IBOutlet weak var buyBgView: UIView!
    
    @IBOutlet weak var buyLB: UILabel!
    
    @IBOutlet weak var sellLB: UILabel!
    
    @IBOutlet weak var sellBgView: UIView!
    
    @IBOutlet weak var sellWidthLC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        priceBtn.tag = MyHouseCellAction.addPrice.rawValue
        price_AddSubView()
    }
    
    @IBAction func priceAction(_ sender: UIButton) {
        delegate?.priceCell(self, didClickBtn: sender, withIndex: index)
    }
    
    @IBAction func undoAction(_ sender: UIButton) {
        delegate?.priceCell(self, didClickBtn: sender, withIndex: index)
    }
    
    @IBAction func payDepositAction(_ sender: UIButton) {
        delegate?.priceCell(self, didClickBtn: sender, withIndex: index)
    }
    
    @IBAction func lockAction(_ sender: UIButton) {
        delegate?.priceCell(self, didClickBtn: sender, withIndex: index)
    }
    
    @IBAction func clickHouseAction(_ sender: UIButton) {
        if sender.tag == 0 {
            delegate?.priceCell(self, selectedHouse: sender, withIndex: index)
        }else {
            delegate?.priceCell(self, didClickBtn: sender, withIndex: index)
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
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        price_UpdateUI(data)
        // 默认跳转详情
        houseBtn.tag = 0
        
        MyHouseCellHelper.typeLB(typeLB, type: type)
        switch type {
        case .waitAudit(let lockType, let isDeposit, _):
            baseUpdateFunc(lockType, isDeposit: isDeposit)
            
            MyHouseCellHelper.editBtn(houseBtn)
        case .released(let lockType, let isDeposit, _),
             .auditSuccess(let lockType, let isDeposit, _):
            baseUpdateFunc(lockType, isDeposit: isDeposit)
        default:
            break
        }
    }
    
    private func baseUpdateFunc(_ lockType: MyHouseType.LockType, isDeposit: Bool) {
        depositView.isHidden = isDeposit
        
        MyHouseCellHelper.undoBtn(undoBtn)
        
        MyHouseCellHelper.lockTypeLB(lockTypeLB, type: lockType)
        switch lockType {
        case .unInstall,
             .installFail:
            lockBtn.isHidden = false
            MyHouseCellHelper.lockBtn(lockBtn)
        case .noDeposit:
            lockBtn.isHidden = false
            MyHouseCellHelper.noDepositBtn(lockBtn)
        default:
            lockBtn.isHidden = true
        }
    }
    
    //    MARK: - 懒加载
    private lazy var buyScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: buyBgView.bounds, font: dzy_Font(11))
        return view
    }()
    
    private lazy var sellScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: sellBgView.bounds, font: dzy_Font(11))
        return view
    }()
}

extension MyHouseUnTradedPriceCell: BuySellPriceListCell {
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
