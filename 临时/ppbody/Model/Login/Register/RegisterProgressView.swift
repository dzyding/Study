//
//  RegisterProgressView.swift
//  PPBody
//
//  Created by Mike on 2018/6/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import CoreGraphics

class RegisterProgressView: UIView {

    var rate : CGFloat = 0  {
        didSet{
            setPercent(percent: rate)
        }
    }
    
    //渐变进度条
    var progressLayer:CAShapeLayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawGradientlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.drawGradientlayer()
    }
    
    //设置进度（可以设置是否播放动画，以及动画时间）
    func setPercent(percent:CGFloat, animated:Bool = true) {
        //改变进度条终点，并带有动画效果（如果需要的话）
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(1.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut))
        progressLayer.strokeEnd = percent
        CATransaction.commit()

    }
    
    
    
     func drawGradientlayer() {
        
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.init(x: 0, y: self.bounds.size.height/2.0))
        bezierPath.addLine(to: CGPoint.init(x: self.bounds.size.width , y: self.bounds.size.height/2.0))
        
        progressLayer = CAShapeLayer.init()
        progressLayer.frame = self.bounds
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.ColorHex("#3023AE").cgColor
        progressLayer.lineCap = CAShapeLayerLineCap.butt
        progressLayer.lineJoin = CAShapeLayerLineJoin.round
        progressLayer.lineWidth = self.bounds.size.height
        progressLayer.path = bezierPath.cgPath
        progressLayer.strokeEnd = self.rate
        self.layer.addSublayer(progressLayer)

        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width , height: self.bounds.size.height)
        gradientLayer.colors = [UIColor.ColorHex("#ffb700").cgColor, UIColor.ColorHex("#ffdd06").cgColor]
        gradientLayer.locations = [NSNumber.init(value: 0.5),NSNumber.init(value: 1)]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        gradientLayer.mask = progressLayer
        
    }
}
