//
//  HouseListNormalCell.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol HouseListNormalCellDelegate: class {
    func normalCell(_ normalCell: HouseListNormalCell, didClickBidBtnWithHouse house: [String : Any])
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int)
}

class HouseListNormalCell: UITableViewCell, CheckLockDestroyProtocol {
    
    weak var delegate: HouseListNormalCellDelegate?
    
    @IBOutlet weak var logoIV: UIImageView!
    /// 房源名字
    @IBOutlet weak var nameLB: UILabel!
    /// 22 0
    @IBOutlet weak var nameLeftLC: NSLayoutConstraint!
    /// 房源户型
    @IBOutlet weak var layoutLB: UILabel!
    /// 房型的左间距 (0, 35 左边是顶到批量操作按钮的)
    @IBOutlet weak var layoutLBLeftLC: NSLayoutConstraint!
    /// 竞价次数
    @IBOutlet weak var bidNumLB: UILabel!
    /// 优显
    @IBOutlet weak var vipLB: UILabel!
    /// -32 0 (选择按钮的left)
    @IBOutlet weak var selectBtnLeftLC: NSLayoutConstraint!
    /// 部分界面需要使用的左右占满高为5的分割线
    @IBOutlet weak var paddingView: UIView!
    /// 选择按钮
    @IBOutlet weak var selectBtn: UIButton!
    /// 竞买/报价
    @IBOutlet weak var actionBtn: UIButton!
    /// 房源数据
    private var house: [String : Any] = [:]
    /// 所在行
    private var row: Int = 0
    
    /// 买字
    @IBOutlet weak var buyLB: UILabel!
    /// 买价格的宽度
    @IBOutlet weak var buyWidthLC: NSLayoutConstraint!
    /// 买价格的背景view
    @IBOutlet weak var buyBgView: UIView!
    /// 卖字
    @IBOutlet weak var sellLB: UILabel!
    /// 卖价格的背景
    @IBOutlet weak var sellWidthLC: NSLayoutConstraint!
    /// 卖价格的背景 view
    @IBOutlet weak var sellBgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        price_AddSubView()
    }
    
    /// 有批量操作的界面使用
    func updateUI(_ isBatch: Bool, data: [String : Any], row: Int) {
        self.row = row
        selectBtnLeftLC.constant = isBatch ? 0 : -32
        vipLB.isHidden = true
        layoutLBLeftLC.constant = 0
        selectBtn.isSelected = data.boolValue(Public_isSelected) ?? false
        let house = data.dicValue("house") ?? [:]
        updateUI(house)
    }
    
    /// 需要分割线的
    func paddingUpdateUI(_ data: [String : Any]) {
        paddingView.isHidden = false
        updateUI(data)
    }
    
    /// 无批量操作的界面使用
    func updateUI(_ data: [String : Any]) {
        house = data
        let isTop = data.intValue("isTop") ?? 0
        vipLB.isHidden = isTop == 0
        layoutLBLeftLC.constant = isTop == 0 ? 0 : 35
        
        let canUse = isLockCanUse(house)
        logoIV.isHidden = !canUse
        nameLeftLC.constant = canUse ? 22 : 0
        
        // 房源名
        nameLB.text = data.stringValue("houseTitle")
        // 房型
        let layoutStr = data.stringValue("layout") ?? ""
        layoutLB.text = layoutStr + " \(data.doubleValue("area"), optStyle: .price)㎡"
        // 人次竞买
        let bidNum = data.intValue("competeNum") ?? 0
        bidNumLB.text = bidNum == 0 ? " " : "\(bidNum)人次竞买"
        
        let isOwner = data.intValue("userId") != DataManager.getUserId()
        actionBtn.setTitle(
            isOwner ? "我要竞买" : "我要报价",
            for: .normal
        )
        price_UpdateUI(data)
    }
    
    /// 我要竞买
    @IBAction func bidAction(_ sender: UIButton) {
        delegate?.normalCell(self, didClickBidBtnWithHouse: house)
    }
    
    /// 选择
    @IBAction func selectAction(_ sender: UIButton) {
        delegate?.normalCell(self, didSelect: row)
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

extension HouseListNormalCell: BuySellPriceListCell {
    var _buyScrollLB: ScrollLabelView {
        return buyScrollLB
    }
    
    var _sellScrollLB: ScrollLabelView {
        return sellScrollLB
    }
    
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
}
