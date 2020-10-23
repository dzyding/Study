//
//  ScrollBtnView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/5/23.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation
import UIKit

private let DefaultLineH: CGFloat = 1.5

enum ScrollBtnType {
    ///按总宽度等分 (一般是屏幕宽)
    case scale
    ///按钮宽度按屏幕等分 但是滚动线条长度按title计算
    case scale_widthFit
    ///按钮宽度按屏幕等分 但是滚动线条长度自定义
    case scale_custom(CGSize)
    ///按按钮长度依次排列 参数为最小宽度
    case arrange(CGFloat)
    ///按按钮长度依次排列 参数为最小宽度，线条的自定义长度
    case arrange_custom(CGFloat, CGSize)
    ///按按钮长度依次排列 小于等于四个按钮的时候等分
    case arrange_four
}

class ScrollBtnView: UIScrollView {
    //在导航控制器中的 size
    var intrinsicSize: CGSize = .zero
    //所有线的size
    fileprivate var sizes:[CGSize] = []
    //所有的子视图
    fileprivate var dzySubViews: [UIView] = []
    //所有按钮的名字
    var btns:[String] = []
    //字体大小
    var font = dzy_Font(15)
    // 选中的字体大小
    var selectedFont = dzy_Font(15)
    //未选中颜色
    var normalColor = Font_Dark
    //选中颜色
    var selectedColor = MainColor
    // 线条颜色
    var lineColor = MainColor
    // 线条到底部的距离
    var lineToBottom: CGFloat = 5
    // 当前选中的按钮
    var selectedIndex = 0
    // 是否需要所在界面标记的线条
    var hasLine = true
    // 选中状态是否能够再次点击
    var isSelectedCanAction = true
    //类型
    let type:ScrollBtnType
    //相应闭包
    let block: (Int) -> ()
    
    init(_ type: ScrollBtnType, frame: CGRect, block: @escaping (Int) -> ()) {
        self.type = type
        self.block = block
        super.init(frame: frame)
        bounces = false
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        if intrinsicSize != .zero {
            return intrinsicSize
        }else {
            return UIView.layoutFittingExpandedSize
        }
    }
    
    //    MARK: - 提供给外部使用的
    func updateUI() {
        dzySubViews.forEach({$0.removeFromSuperview()})
        dzySubViews = []
        sizes = []
        createBtns()
    }
    
    func setBottomLine(_ color: UIColor) {
        let frame = CGRect(x: 0, y: dzy_h - 0.5, width: dzy_cSizeW, height: 0.5)
        let line = UIView(frame: frame)
        line.backgroundColor = color
        addSubview(line)
    }
    
    func updateSelectedBtn(_ index: Int) {
        if let btn = viewWithTag(index + 100) as? UIButton {
            btn.sendActions(for: .touchUpInside)
        }
    }

    //    MARK: - 实现的相关方法
    //创建按钮
    //swiftlint:disable:next function_body_length
    private func createBtns() {
        var x:CGFloat = 0
        for (index, str) in btns.enumerated() {
            var btnW :CGFloat = 0
            var lineW:CGFloat = 0
            switch type {
            case .arrange(let min):
                lineW = dzy_strSize(str: str, font: font, width: dzy_w).width + 10
                lineW = max(min, lineW)
                sizes.append(CGSize(width: lineW, height: DefaultLineH))
                btnW  = lineW
            case .arrange_custom(let min, let size):
                sizes.append(size)
                btnW = dzy_strSize(str: str, font: font, width: dzy_w).width + 10
                btnW = max(min, btnW)
                lineW = size.width
            case .arrange_four:
                lineW = dzy_strSize(str: str, font: font, width: dzy_w).width + 10
                sizes.append(CGSize(width: lineW, height: DefaultLineH))
                if btns.count > 4 {
                    btnW  = ScreenWidth / 4.0
                }else {
                    btnW  = ScreenWidth / CGFloat(btns.count)
                }
            case .scale_widthFit:
                //线的宽度和按钮的宽度不一样
                lineW = dzy_strSize(str: str, font: font, width: dzy_w).width + 10
                sizes.append(CGSize(width: lineW, height: DefaultLineH))
                btnW = dzy_w / CGFloat(btns.count)
            case .scale_custom(let size):
                sizes.append(size)
                btnW = dzy_w / CGFloat(btns.count)
                lineW = size.width
            default:
                lineW = dzy_w / CGFloat(btns.count)
                sizes.append(CGSize(width: lineW, height: DefaultLineH))
                btnW = lineW
            }
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: x, y: 0, width: btnW, height: dzy_h)
            btn.titleLabel?.font = selectedIndex == index ?  selectedFont : font
            btn.setTitle(str, for: .normal)
            btn.setTitleColor(normalColor, for: .normal)
            btn.setTitleColor(selectedColor, for: .selected)
            btn.tag = 100 + index
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
            btn.isSelected = selectedIndex == index
            addSubview(btn)
            dzySubViews.append(btn)
            x += btnW
            if btn.tag == 100 && hasLine {
                let line = createRedLine(lineW: lineW, btnW: btnW)
                dzySubViews.append(line)
            }
        }
        contentSize = CGSize(width: x, height: dzy_h)
    }
    
    private func createRedLine(lineW: CGFloat, btnW:CGFloat) -> UIView {
        let line = UIView(frame: CGRect(
            x: btnW / 2.0 - lineW / 2.0,
            y: dzy_h - 2 - lineToBottom,
            width: lineW,
            height: 1.5)
        )
        line.backgroundColor = lineColor
        line.layer.cornerRadius = 1
        line.layer.masksToBounds = true
        line.tag = 999
        addSubview(line)
        return line
    }
    
    @objc private func btnClick(_ button: UIButton) {
        let currentInt = button.tag - 100
        if button.isSelected {
            if isSelectedCanAction {
                block(currentInt)
            }
            return
        }
        //全部取消选中
        for x in 0...btns.count {
            let tag = x + 100
            if let btn = viewWithTag(tag) as? UIButton {
                btn.isSelected = false
                btn.titleLabel?.font = font
            }
        }
        //当前按钮选中
        button.isSelected = true
        button.titleLabel?.font = selectedFont
        selectedIndex = currentInt
        //线的滚动动画
        if hasLine {
            clickLineAnimate(button)
        }
        switch type {
        case .arrange, .arrange_four, .arrange_custom:
            //点击跟随滚动的效果
            arrangeTypeScrollAnimate(button)
        default:
            break
        }
        //回调闭包
        block(currentInt)
    }
    
    private func clickLineAnimate(_ btn: UIButton) {
        if let redLine = viewWithTag(999) {
            let size  = sizes[btn.tag - 100]
            let left  = btn.frame.midX - size.width / 2.0
            UIView .animate(withDuration: 0.2, animations: {
                redLine.frame = CGRect(
                    x: left,
                    y: self.dzy_h - 2 - self.lineToBottom,
                    width: size.width,
                    height: size.height
                )
            })
        }
    }
    
    private func arrangeTypeScrollAnimate(_ btn: UIButton) {
        if contentSize.width <= dzy_w {
            return
        }
        if btn.frame.midX <= dzy_w / 2.0 {
            setContentOffset(.zero, animated: true)
        }else if contentSize.width - btn.center.x <= dzy_w / 2.0 {
            let x = contentSize.width - dzy_w
            setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }else {
            let x = btn.dzy_x - (dzy_w - btn.dzy_w) / 2.0
            setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
    }
}
