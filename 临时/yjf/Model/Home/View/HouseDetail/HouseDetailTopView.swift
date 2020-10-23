//
//  HouseDetailTopView.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseDetailTopViewDelegate {
    func topView(_ topView: HouseDetailTopView, didSelectType type: Int)
    func topView(_ topView: HouseDetailTopView, didSelectGzBtn btn: UIButton)
}

class HouseDetailTopView: UIView {
    
    weak var delegate: HouseDetailTopViewDelegate?
    /// 滚动视图的占位图
    @IBOutlet weak var adBgView: UIView!
    /// btnsView 的占位图
    @IBOutlet weak var btnsBg: UIView!
    /// 关注按钮
    @IBOutlet weak var gzBtn: UIButton!
    /// 房源名称
    @IBOutlet weak var nameLB: UILabel!
    /// 卖价
    @IBOutlet weak var sellPriceLB: UILabel!
    /// ()人实地看房
    @IBOutlet weak var lookedNumLB: UILabel!
    /// ()人次竞买
    @IBOutlet weak var bidedNumLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.initUI()
        }
    }
    
    private func initUI() {
        adBgView.addSubview(adView)
        btnsBg.addSubview(btnsView)
    }
    
    @IBAction private func gzAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.topView(self, didSelectGzBtn: sender)
    }
    
    func updateUI(_ data: [String : Any], identity: Identity) {
        
        gzBtn.isHidden = identity == .seller
        gzBtn.isSelected = data.intValue("isConcern") == 1
        
        let house = data.dicValue("house")
        let bidNum = data.intValue("houseBuyNum") ?? 0
        let lookNum = data.intValue("lookNum") ?? 0
        nameLB.text     = house?.stringValue("houseTitle")
        
        let sellPrice = house?.arrValue("sellList")?
            .compactMap({$0.doubleValue("total")})
            .min()
        sellPriceLB.text    = "\(sellPrice, optStyle: .price)万"
        bidedNumLB.text     = bidNum > 0 ? "\(bidNum)人次竞买" : nil
        lookedNumLB.text    = lookNum > 0 ? "\(lookNum)人实地看房" : nil
        
        let imgs = (house?["imgs"] as? [String]) ?? []
        let userImgs = (house?["userImgs"] as? [String]) ?? []
        let result = imgs.count > 0 ? imgs : userImgs
        adView.updateUI(result)
    }

    //    MARK: - 懒加载
    lazy var adView: DzyAdView = DzyAdView(adBgView.bounds, pageType: .num)
    
    lazy var btnsView: ScrollBtnView = {
        let size = CGSize(width: 22, height: 2)
        let frame = CGRect(x: 5, y: 0, width: 240, height: 40)
        let block: (Int) -> () = { [unowned self] index in
            self.delegate?.topView(self, didSelectType: index)
        }
        let view = ScrollBtnView(.scale_custom(size), frame: frame, block: block)
        view.btns = ["房源详情", "房源导航", "周边情况"]
        view.normalColor = dzy_HexColor(0x646464)
        view.selectedColor = Font_Dark
        view.font = dzy_Font(13)
        view.selectedFont = dzy_FontBlod(15)
        view.lineColor = dzy_HexColor(0xFD7E25)
        view.updateUI()
        return view
    }()
}
