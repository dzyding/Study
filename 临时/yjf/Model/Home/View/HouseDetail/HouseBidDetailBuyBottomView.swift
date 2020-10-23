//
//  HouseBidDetailBuyBottomView.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseBidDetailBuyBottomViewDelegate {
    /// 收藏
    func bidBottomView(_ bottomView: HouseBidDetailBuyBottomView, didSelectFaviBtn btn: UIButton)
    /// 竞买
    func bidBottomView(_ bottomView: HouseBidDetailBuyBottomView, didSelectBidBtn btn: UIButton)
}

class HouseBidDetailBuyBottomView: UIView {
    
    weak var delegate: HouseBidDetailBuyBottomViewDelegate?

    @IBOutlet weak var faviBtn: UIButton!
    
    func updateUI(_ data: [String : Any]) {
        faviBtn.isSelected = data.intValue("isCollect") == 1
    }
    
    func updateFavBtn(_ isSelected: Bool) {
        faviBtn.isSelected = isSelected
    }
    
    @IBAction func faviAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.bidBottomView(self, didSelectFaviBtn: sender)
    }
    
    @IBAction func bidAction(_ sender: UIButton) {
        delegate?.bidBottomView(self, didSelectBidBtn: sender)
    }
}
