//
//  UIView+LineGraph.swift
//  BezierPath_190212
//
//  Created by edz on 2019/2/13.
//  Copyright © 2019 dzy. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func drawLineGraph(_ values: [Int], keys: [String]) {
        // 横向的左间距
        let xS: CGFloat = 65.0
        // 横向的右间距
        let xE: CGFloat = 35.0
        // 纵向的上边距
        let yS: CGFloat = 30.0
        // 纵向的下边距
        let yE: CGFloat = 50.0
        // 总高度
        let height = frame.height - (yS + yE)
        
        // 横向平分值
        let x = (frame.width - (xS + xE)) / 4.0
        // 纵向平分值
        let y = height / 3.0
        
        guard let maxNum = values.max() else {return}
        
        keys.enumerated().forEach { (i, str) in
            let label = UILabel()
            label.text = str
            label.font = UIFont.systemFont(ofSize: 12)
            label.sizeToFit()
            addSubview(label)
            
            let left = xS + CGFloat(i) * x - label.frame.width / 2.0
            label.snp.makeConstraints({ (make) in
                make.bottom.equalTo(-16)
                make.left.equalTo(left)
            })
        }
        
        (0...3).forEach { (i) in
            let label = UILabel()
            label.text = "\(i * maxNum / 3)"
            label.font = UIFont.systemFont(ofSize: 12)
            label.sizeToFit()
            label.textAlignment = .center
            addSubview(label)
            
            let bottom = yE + CGFloat(i) * y - label.frame.height / 2.0
            label.snp.makeConstraints({ (make) in
                make.left.equalTo(10)
                make.width.equalTo(20)
                make.bottom.equalTo(-bottom)
            })
            
            let line = UIView()
            line.backgroundColor = .lightGray
            addSubview(line)
            
            line.snp.makeConstraints({ (make) in
                make.centerY.equalTo(label)
                make.left.equalTo(xS)
                make.height.equalTo(1)
                make.right.equalTo(-xE)
            })
        }
        
        let path = UIBezierPath()
        let points = values.enumerated().map { (i, num) -> CGPoint in
            let px = xS + CGFloat(i) * x
            let py = (frame.height - yE) - CGFloat(num) / CGFloat(maxNum) * height
            
            return CGPoint(x: px, y: py)
        }
        
        (0..<points.count - 1).forEach { (i) in
            let startP = points[i]
            let endP = points[i + 1]
            let control1 = CGPoint(x: (endP.x - startP.x) / 2.0 + startP.x, y: startP.y)
            let control2 = CGPoint(x: (endP.x - startP.x) / 2.0 + startP.x, y: endP.y)
            path.move(to: startP)
            path.addCurve(to: endP, controlPoint1: control1, controlPoint2: control2)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.frame = bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(shapeLayer)
    }
}
