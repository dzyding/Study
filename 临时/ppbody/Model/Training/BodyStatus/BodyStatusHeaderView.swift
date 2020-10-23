//
//  BodyStatusHeaderView.swift
//  PPBody
//
//  Created by Mike on 2018/6/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BodyStatusHeaderView: UIView {

    
    @IBOutlet weak var lblHealthIndex: UILabel!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: self.bounds.size.width/2.0, y: 150), radius: 100, startAngle: .pi*135/180, endAngle: .pi * 1.5 + .pi*135/180, clockwise: true)
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2.0)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.ColorHex("#3023AE").cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineWidth = 10
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
        
        //动画
        let pathAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        pathAnimation.duration = 1.5;
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        pathAnimation.autoreverses = false //动画结束之后不开始了
        pathAnimation.repeatCount = 1;
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        shapeLayer.add(pathAnimation, forKey: "strokeEndAnimation")
        
        //两个渐变层拼接
        let layerG = CALayer.init()
        layerG.frame = self.bounds;
        let gradientLayer1 = CAGradientLayer.init()
        gradientLayer1.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width/2.0, height: self.bounds.size.height)
        gradientLayer1.colors = [UIColor.ColorHex("#B4EC51").cgColor, UIColor.ColorHex("#53A0FD").cgColor]
        gradientLayer1.locations = [NSNumber.init(value: 0.5),NSNumber.init(value: 1)]
        gradientLayer1.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer1.endPoint = CGPoint.init(x: 1, y: 0)
        layerG.addSublayer(gradientLayer1)
        
        let gradientLayer2 = CAGradientLayer.init()
        gradientLayer2.frame = CGRect.init(x: self.frame.size.width/2.0, y: 0, width: self.frame.size.width/2.0, height: self.bounds.size.height)
        gradientLayer2.colors = [UIColor.ColorHex("#53A0FD").cgColor, UIColor.ColorHex("#3023AE").cgColor]
        gradientLayer2.locations = [NSNumber.init(value: 0.3),NSNumber.init(value: 0.8)]
        gradientLayer2.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer2.endPoint = CGPoint.init(x: 1, y: 0)
        layerG.addSublayer(gradientLayer2)
        self.layer.insertSublayer(layerG, at: 0)
        layerG.mask = shapeLayer
        
    }
    
    class func instanceFromNib() -> BodyStatusHeaderView {
        return UINib(nibName: "BodyStatusHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BodyStatusHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = BackgroundColor
    }
    
}
