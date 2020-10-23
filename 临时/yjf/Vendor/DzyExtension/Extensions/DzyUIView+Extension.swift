//
//  DzyUIView+Extension.swift
//  HousingMarket
//
//  Created by dzy_PC on 2018/11/26.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

extension UIView {
    func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}

extension UIView {
    var dzyLayout: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
}

extension UIView {
//    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Use InitFromNibEnable instead.")
    static func initFromNib<T: UIView>(_ type: T.Type) -> T {
        let name = String(describing: type)
        // swiftlint:disable:next force_cast
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil).first as! T
    }
    
    /// 添加阴影
    func dzy_shadow(_ color: UIColor, _ opacity: Float = 0.5, _ raidus: CGFloat = 3) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = raidus
        layer.shadowOffset = CGSize.zero
        
        /*
         offset 的 x 是控制左右的， y 是控制 上下的
         raidus 宽度
         */
    }
    
    /// 解除阴影
    func dzy_delShadow() {
        layer.shadowRadius = 0
    }
    
    /// 添加虚线边框
    @discardableResult
    func dzy_dashBorder(_ color: UIColor, cornerRadius: CGFloat = 0) -> CAShapeLayer {
        let border = CAShapeLayer()
        border.strokeColor = color.cgColor
        border.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        border.path = path.cgPath
        border.frame = bounds
        border.lineWidth = 1
        // 线条样式?
//        border.lineCap = .square
        border.lineDashPattern = [NSNumber(value: 4), NSNumber(value: 2)]
        
        if cornerRadius != 0 {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
        layer.addSublayer(border)
        return border
    }
}
