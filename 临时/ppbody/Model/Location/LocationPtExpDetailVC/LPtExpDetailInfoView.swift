//
//  LPtExpDetailInfoView.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpDetailInfoView: UIView, InitFromNibEnable {

    @IBOutlet weak var adBgView: UIView!
    
    @IBOutlet weak var nameLB: UILabel!
    /// 可在线选教练
    @IBOutlet weak var berifLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initStyle()
    }
    
    func initUI(_ data: [String : Any]) {
        let imgs = data["imgs"] as? [String] ?? []
        adView.updateUI(imgs, isTimer: false)
        adBgView.addSubview(adView)
        
        nameLB.text = data.stringValue("name")
        numLB.text = "已约\(data.intValue("consumeNum") ?? 0)"
    }
    
    private func initStyle() {
        let str = "可在线选教练"
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        let attStr = NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedString.Key.font : dzy_Font(11),
                NSAttributedString.Key.foregroundColor : color
        ])
        attStr.addAttribute(NSAttributedString.Key.foregroundColor,
                            value: YellowMainColor,
                            range: NSRange(location: 1, length: 2))
        berifLB.attributedText = attStr
    }
    
    //    MARK: - 图片的点击事件
    private func clickAction(_ index: Int) {
        
    }
    
    //    MARK: - 懒加载
    private lazy var adView: DzyAdView = {
        let frame = CGRect(x: 0, y: 0,
                           width: ScreenWidth, height: 240.0)
        let view = DzyAdView(frame, pageType: .num)
        view.handler = { [weak self] index in
            self?.clickAction(index)
        }
        return view
    }()
}
