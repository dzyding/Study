//
//  LinearGradientView.swift
//  190418_渐变
//
//  Created by edz on 2019/4/18.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

//final class GradientView: UIView {
//
//    override class var layerClass: AnyClass { return CAGradientLayer.self }
//
//    var colors: (start: UIColor, end: UIColor)? {
//        didSet { updateLayer() }
//    }
//
//    private func updateLayer() {
//        let layer = self.layer as! CAGradientLayer
//        layer.colors = colors.map { [$0.start.cgColor, $0.end.cgColor] }
//    }
//}

// 渐变视图
class LinearGradientView: UIView {
    
    private let startColor: UIColor
    
    private let finishColor: UIColor
    
    init(_ frame: CGRect, startColor: UIColor, finishColor: UIColor) {
        self.startColor = startColor
        self.finishColor = finishColor
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(
            in: rect,
            startingWith: startColor.cgColor,
            finishingWith: finishColor.cgColor
        )
    }
}

private extension CGContext {
    func drawLinearGradient(
        in rect: CGRect,
        startingWith startColor: CGColor,
        finishingWith endColor: CGColor
        ) {
        // 1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 2
        let locations = [0.0, 1.0] as [CGFloat]
        
        // 3
        let colors = [startColor, endColor] as CFArray
        
        // 4
        guard let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: locations
            ) else {
                return
        }
        
        // 5
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        // 6
        saveGState()
        
        // 7
        addRect(rect)
        clip()
        drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: CGGradientDrawingOptions()
        )
        
        restoreGState()
    }
}
