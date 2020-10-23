//
//  LocationGBInfoView.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

/// 团课，体验课详情 顶部信息视图
class LocationGBInfoView: UIView, InitFromNibEnable {

    @IBOutlet weak var imgBgView: UIView!

    @IBOutlet weak var reserveLB: UILabel!

    @IBOutlet weak var nameLB: UILabel!
    
    func updateUI(_ data: [String : Any]) {
        let imgs = data["imgs"] as? [String] ?? []
        adView.updateUI(imgs, isTimer: false)
        addSubview(adView)
        
        let isOrder = data.intValue("isOrder") ?? 1
        reserveLB.text = isOrder == 1 ? "需预约" : "免预约"
        
        nameLB.text = data.stringValue("name")
    }
    
    private func clickAction(_ index: Int) {
        
    }
    
    //    MARK: - 懒加载
    private lazy var adView: DzyAdView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 240.0)
        let view = DzyAdView(frame, pageType: .num)
        view.handler = { [weak self] index in
            self?.clickAction(index)
        }
        return view
    }()
}
