//
//  VarietyLabelView.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol VarietyLabelViewDelegate: class {
    func vlView(_ vlView: VarietyLabelView,
                didClickTitle title: String,
                withIndex index: Int)
}

class VarietyLabelView: UIView {
    
    weak var delegate: VarietyLabelViewDelegate?
    
    private var titles: [String]
    /// 字体
    var font = ToolClass.CustomBoldFont(12)
    /// 高度
    var height: CGFloat = 40.0
    /// y 间距
    var yPadding: CGFloat = 12.0
    /// x 间距
    var xPadding: CGFloat = 10.0
    /// 左右多出来一点
    var more: CGFloat = 24.0
    /// 圆角
    var cRadius: CGFloat = 6.0
    /// 点击背景
    var selectedStyle = false
    
    init(_ titles: [String], frame: CGRect) {
        self.titles = titles
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        addSubview(scrollView)
        updateUI(titles)
    }
    
    @objc private func btnClick(_ btn: UIButton) {
        guard let title = btn.title(for: .normal) else {return}
        delegate?.vlView(self, didClickTitle: title, withIndex: btn.tag)
    }
    
    func updateUI(_ titles: [String]) {
        while scrollView.subviews.count > 0 {
            scrollView.subviews.last?.removeFromSuperview()
        }
        self.titles = titles
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lastBtn: UIButton?
        titles.enumerated().forEach { (value) in
            var width = dzy_strSize(str: value.1,
                                    font: font,
                                    width: ScreenWidth).width
            if width + more > dzy_w {
                width = dzy_w - more
            }
            if x != 0,
                x + width + more + xPadding > dzy_w
            {
                x = 0
                y += (height + yPadding)
            }
            
            let frame = CGRect(x: x,
                               y: y,
                               width: width + more,
                               height: height)
            
            let btn = UIButton(type: .custom)
            btn.tag = value.0
            btn.frame = frame
            btn.backgroundColor = CardColor
            btn.setTitle(value.1, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = font
            btn.layer.cornerRadius = cRadius
            btn.layer.masksToBounds = true
            btn.addTarget(self,
                          action: #selector(btnClick(_:)),
                          for: .touchUpInside)
            scrollView.addSubview(btn)
            lastBtn = btn
            x = btn.frame.maxX + xPadding
        }
        lastUpdateFrame(lastBtn)
    }
    
    private func lastUpdateFrame(_ btn: UIButton?) {
        guard let btn = btn else {return}
        var sFrame = frame
        sFrame.size.height = btn.frame.maxY
        frame = sFrame
        scrollView.frame = bounds
        scrollView.contentSize = bounds.size
    }
    
//    MARK: - 懒加载
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.bounces = false
        scrollView.contentSize = bounds.size
        return scrollView
    }()
}
