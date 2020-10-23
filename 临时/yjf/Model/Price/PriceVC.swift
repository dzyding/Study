//
//  PriceVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class PriceVC: ScrollBtnVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    override var titles: [String] {
        if isLock {
            return ["成交记录", "价格曲线", "房产新闻", "政策法规", "专家点评"]
        }else {
            return ["价格曲线", "房产新闻", "政策法规", "专家点评"]
        }
    }
    
    override var btnsViewType: ScrollBtnType {
        return .arrange_custom(ScreenWidth / 4.5, CGSize(width: 23, height: 2))
    }
    
    override var normalFont: UIFont {
        return dzy_FontBlod(15)
    }
    
    override var selectedFont: UIFont {
        return dzy_FontBlod(17)
    }
    
    override var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    override var selectedColor: UIColor {
        return dzy_HexColor(0x262626)
    }
    
    override var btnsViewHeight: CGFloat {
        return 50
    }
    
    override var lineToBottom: CGFloat {
        return 10
    }
    
    // 成交记录的 lock
    private var isLock: Bool = true
    
    deinit {
        deinitObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        registObservers([
            PublicConfig.Notice_ChangeCitySuccess
        ]) {
            self.clearVCs()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        PublicConfig.updateCityConfig { (data) in
            self.isLock = data?.dicValue("cityConfig")?
                .stringValue("isLookHouseRecord") == "Y"
            self.updateVCs()
        }
    }

    override func getVCs() -> [UIViewController] {
        if isLock {
            return [
                DealListVC(),
                PriceCurveVC(),
                NewsListVC(.house),
                NewsListVC(.policy),
                NewsListVC(.expert)
            ]
        }else {
            return [
                PriceCurveVC(),
                NewsListVC(.house),
                NewsListVC(.policy),
                NewsListVC(.expert)
            ]
        }
    }
}
