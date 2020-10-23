//
//  YJFPickerBgView.swift
//  190418_渐变
//
//  Created by edz on 2019/4/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class YJFPickerBgView: UIView {
    
    private let padding: CGFloat = 10.0
    
    var pointX: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(
            x: rect.minX,
            y: rect.minY + padding)
        )
        context?.addLine(to: CGPoint(
            x: rect.minX,
            y: rect.maxY)
        )
        context?.addLine(to: CGPoint(
            x: rect.maxX,
            y: rect.maxY)
        )
        context?.addLine(to: CGPoint(
            x: rect.maxX,
            y: rect.minY + padding)
        )
        context?.addLine(to: CGPoint(
            x: pointX - rect.origin.x + padding,
            y: rect.minY + padding)
        )
        context?.addLine(to: CGPoint(
            x: pointX - rect.origin.x,
            y: rect.minY)
        )
        context?.addLine(to: CGPoint(
            x: pointX - rect.origin.x - padding,
            y: rect.minY + padding)
        )
        context?.addLine(to: CGPoint(
            x: rect.minX,
            y: rect.minY + padding)
        )
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
    }

}
