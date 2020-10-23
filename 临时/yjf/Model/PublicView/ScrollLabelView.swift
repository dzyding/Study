//
//  ScrollLabelView.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

public let ScrollLabelDefaultWidth: CGFloat = 35.0

class ScrollLabelView: UIView {
    // 判断是否已经开始动画
    private var isAnimate = false
    
    private weak var topLB: UILabel?
    
    private weak var bottomLB: UILabel?
    
    private let font: UIFont
    
    private var colors: [UIColor] = []
    
    private var titles: [Double] = []
    // 当前的 index
    private var cIndex: Int = 0
    // 随机的滚动时间
    private var time: Int = 1

    init(frame: CGRect, font: UIFont) {
        self.font = font
        super.init(frame: frame)
        clipsToBounds = true
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        (0..<2).forEach { (index) in
            let y = CGFloat(index) * bounds.size.height
            let label = UILabel(frame: CGRect(
                x: 0,
                y: y,
                width: bounds.size.width,
                height: bounds.size.height)
            )
            label.font = font
            label.textColor = NoDeposit_Color
            addSubview(label)
            
            if index == 0 {
                topLB = label
            }else {
                bottomLB = label
            }
            
            label.snp.makeConstraints({ (make) in
                make.height.equalTo(bounds.size.height)
                make.left.equalTo(0)
                make.top.equalTo(y)
            })
        }
    }
    
    func initUI(_ titles: [Double],
                colors: [UIColor] = [NoDeposit_Color],
                handler: (CGFloat) -> ())
    {
        isAnimate = false
        topLB?.text = nil
        bottomLB?.text = nil
        self.titles = []
        self.colors = []
        guard titles.count > 0 else {return}
        self.titles = titles
        self.colors = colors
        assert(titles.count == colors.count, "价格数据和颜色数据不一致")
        cIndex = 0
        time = ToolClass.randomCustom(min: 1, max: 3)
        handler(maxWidth(titles))
        if titles.count == 1 {
            topLB?.text = String(format: "%.0lf万", titles[0])
            topLB?.textColor = colors[0]
            bottomLB?.text = nil
        }else {
            updateUI()
        }
    }
    
    func updateIndex(_ total: Int) {
        if titles.count < 2 {return}
        if total % time != 0 {return}
        if isAnimate {return}
        cIndex += 1
        if cIndex >= titles.count {
            cIndex = 0
        }
        updateUI()
    }
    
    private func updateUI() {
        isAnimate = true
        var topTitle: String? = nil
        var bottomTitle: String? = nil
        var topColor = NoDeposit_Color
        var bottomColor = NoDeposit_Color
        
        if titles.count > cIndex {
            topTitle = String(format: "%.0lf万", titles[cIndex])
            topColor = colors[cIndex]
        }
        if titles.count > cIndex + 1 {
            bottomTitle = String(format: "%.0lf万", titles[cIndex + 1])
            bottomColor = colors[cIndex + 1]
        }
        if titles.count == cIndex + 1 {
            bottomTitle = String(format: "%.0lf万", titles[0])
            bottomColor = colors[0]
        }
        topLB?.text = topTitle
        topLB?.textColor = topColor
        bottomLB?.text = bottomTitle
        bottomLB?.textColor = bottomColor
        
        let height = bounds.size.height
        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.bounds.y = height
        }) { (_) in
            self.topLB?.text = bottomTitle
            self.topLB?.textColor = bottomColor
            self.bounds.y = 0
            self.isAnimate = false
        }
    }
    
    private func maxWidth(_ titles: [Double]) -> CGFloat {
        var maxw: CGFloat = 0
        titles.forEach { (price) in
            let str = String(format: "%.0lf万", price)
            let width = dzy_strSize(str: str, font: font).width
            maxw = max(width, maxw)
        }
        return maxw
    }
}
