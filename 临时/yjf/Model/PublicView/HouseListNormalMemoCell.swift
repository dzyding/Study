//
//  HouseListNormalMemoCell.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol HouseListNormalMemoCellDelegate: class {
    func memoCell(_ memoCell: HouseListNormalMemoCell, didClickBidBtnWithHouse house: [String : Any])
}

class HouseListNormalMemoCell: UITableViewCell, CheckLockDestroyProtocol {
    
    weak var delegate: HouseListNormalMemoCellDelegate?
    /// 房源备忘
    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var memoLB: UILabel!
    /// 名称
    @IBOutlet weak var nameLB: UILabel!
    /// 40 10
    @IBOutlet weak var nameLeftLC: NSLayoutConstraint!
    /// 户型
    @IBOutlet weak var layoutLB: UILabel!
    /// 竞买人数
    @IBOutlet weak var bidNumLB: UILabel!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    private var house: [String : Any] = [:]
    
    /// 滚动价格的宽度
    @IBOutlet weak var buyWidthLC: NSLayoutConstraint!
    /// 滚动价格的背景view
    @IBOutlet weak var buyBgView: UIView!
    
    @IBOutlet weak var buyLB: UILabel!

    @IBOutlet weak var sellBgView: UIView!
    
    @IBOutlet weak var sellWidthLC: NSLayoutConstraint!
    
    @IBOutlet weak var sellLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        price_AddSubView()
    }
    
    @IBAction func bidAction(_ sender: UIButton) {
        delegate?.memoCell(self, didClickBidBtnWithHouse: house)
    }
    
    /// 无批量操作的界面使用
    func updateUI(_ memo: String, data: [String : Any]) {
        var temp = DzyAttributeString()
        temp.str = "房源备忘：" + memo
        temp.font = dzy_Font(13)
        temp.color = dzy_HexColor(0x646464)
        temp.lineSpace = defaultLineSpace
        memoLB.attributedText = temp.create()
        
        house = data
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
        
        actionBtn.setTitle(
            (data.intValue("userId") != DataManager.getUserId()) ?
                "我要竞买" : "我要报价",
            for: .normal
        )
        price_UpdateUI(data)
    }
    
//    MARK: - 懒加载
    lazy var buyScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: buyBgView.bounds, font: dzy_Font(11))
        return view
    }()
    
    lazy var sellScrollLB: ScrollLabelView = {
        let view = ScrollLabelView(frame: sellBgView.bounds, font: dzy_Font(11))
        return view
    }()
}

extension HouseListNormalMemoCell: BuySellPriceListCell {
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
