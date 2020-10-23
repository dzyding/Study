//
//  LClassHeaderTopView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LClassHeaderTopView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var adBgView: UIView!

    func initUI() {
        adView.updateUI(
            ["https://oss.ppbody.com/banner/002fc727388811bc444e56cbe7ea1b3e.png",
             "https://oss.ppbody.com/banner/6f3a553087732d00b811d71a66bdb337.png"],
            isTimer: false
        )
        adBgView.addSubview(adView)
    }
    
    //    MARK: - 懒加载
    private lazy var adView: DzyAdView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 240.0)
        let view = DzyAdView(frame, pageType: .num)
        return view
    }()
}
