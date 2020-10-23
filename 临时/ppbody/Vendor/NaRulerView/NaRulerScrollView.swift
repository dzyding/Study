//
//  NaRulerScrollView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class NaRulerScrollView: UIScrollView {
    static let DISTANCELEFTANDRIGHT:CGFloat = 8.0 // 标尺左右距离
    static let DISTANCEVALUE:CGFloat = 8.0 // 每隔刻度实际长度8个点
    static let DISTANCETOPANDBOTTOM:CGFloat = 28.0 // 标尺上下距离
    
    var rulerCount:Int = 0//表示多少个刻度
    var rulerAverage:CGFloat = 0
    var rulerHeight:CGFloat = 0
    var rulerWidth:CGFloat = 0
    var rulerValue:CGFloat = 0
    var mode = false
    
    var lowColor = UIColor.ColorHex("#8654FF")
    var normalColor = UIColor.ColorHex("#F8E71C")
    var highColor = UIColor.ColorHex("#46E0B5")
    
    var min: Int = 0
    var max: Int = 0
    var lowValue: CGFloat = 0
    var highValue: CGFloat = 0
    
    
    var lowCount = 0//最低值
    var highCount = 0//最高值
    
    var lineWidth = 1
    

    
    func drawRuler()
    {
        //更新的时候移除以前的layer
        if self.layer.sublayers != nil
        {
            for layer in self.layer.sublayers!
            {
                layer.removeFromSuperlayer()
            }
        }
        
        
        let pathRef1 = CGMutablePath()
        let pathRef2 = CGMutablePath()
        let pathRef3 = CGMutablePath()
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.strokeColor = lowColor.cgColor
        shapeLayer1.fillColor = UIColor.clear.cgColor
        shapeLayer1.lineWidth = CGFloat(lineWidth)
        shapeLayer1.lineCap = CAShapeLayerLineCap.butt
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.strokeColor = normalColor.cgColor;
        shapeLayer2.fillColor = UIColor.clear.cgColor;
        shapeLayer2.lineWidth = CGFloat(lineWidth)
        shapeLayer2.lineCap = CAShapeLayerLineCap.butt;
        
        let shapeLayer3 = CAShapeLayer()
        shapeLayer3.strokeColor = highColor.cgColor;
        shapeLayer3.fillColor = UIColor.clear.cgColor;
        shapeLayer3.lineWidth = CGFloat(lineWidth)
        shapeLayer3.lineCap = CAShapeLayerLineCap.butt;
        
        for i in 0...self.rulerCount {
//            let rule = UILabel()
//            rule.textColor = UIColor.black
//            rule.text = "\(Int(CGFloat(i) * self.rulerAverage))"
//            let textSize = rule.text!.getSize(with: rule.font)
            
            var currentPath = CGMutablePath()
            if i < lowCount
            {
                currentPath = pathRef1
            }else if i > highCount
            {
                currentPath = pathRef3
            }else{
                currentPath = pathRef2
            }
            /*
//            if i%10 == 0
//            {
//                currentPath.move(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y: NaRulerScrollView.DISTANCETOPANDBOTTOM + 20))
//                currentPath.addLine(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y: self.rulerHeight - NaRulerScrollView.DISTANCETOPANDBOTTOM - textSize.height))
//                rule.frame = CGRect(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i) - textSize.width/2, y: self.rulerHeight - NaRulerScrollView.DISTANCETOPANDBOTTOM - textSize.height, width: 0, height: 0)
//                rule.sizeToFit()
//                self.addSubview(rule)
            }else*/ if i%5 == 0
            {
                currentPath.move(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y: NaRulerScrollView.DISTANCETOPANDBOTTOM))
                currentPath.addLine(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y:NaRulerScrollView.DISTANCETOPANDBOTTOM + 40.0))
            }else{
                currentPath.move(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y: NaRulerScrollView.DISTANCETOPANDBOTTOM))
                currentPath.addLine(to: CGPoint(x: NaRulerScrollView.DISTANCELEFTANDRIGHT + NaRulerScrollView.DISTANCEVALUE * CGFloat(i), y:NaRulerScrollView.DISTANCETOPANDBOTTOM + 20.0))
            }
            
        }
        
        shapeLayer1.path = pathRef1
        shapeLayer2.path = pathRef2
        shapeLayer3.path = pathRef3
        self.layer.addSublayer(shapeLayer1)
        self.layer.addSublayer(shapeLayer2)
        self.layer.addSublayer(shapeLayer3)
        
        self.frame = CGRect(x: 0, y: 0, width: self.rulerWidth, height: self.rulerHeight)
        
        // 开启最小模式
        if mode {
            let edge = UIEdgeInsets(top: 0, left: self.rulerWidth/2 - NaRulerScrollView.DISTANCELEFTANDRIGHT, bottom: 0, right: self.rulerWidth/2 - NaRulerScrollView.DISTANCELEFTANDRIGHT)

            self.contentInset = edge
            self.contentOffset = CGPoint(x: NaRulerScrollView.DISTANCEVALUE * (self.rulerValue / self.rulerAverage) - self.rulerWidth + (self.rulerWidth / 2 + NaRulerScrollView.DISTANCELEFTANDRIGHT), y: 0)
            
        }else
        {
            self.contentOffset = CGPoint(x: NaRulerScrollView.DISTANCEVALUE * (self.rulerValue / self.rulerAverage) - self.rulerWidth - (self.rulerWidth / 2 + NaRulerScrollView.DISTANCELEFTANDRIGHT), y: 0)
        }
        self.contentSize = CGSize(width: CGFloat(self.rulerCount) * NaRulerScrollView.DISTANCEVALUE + NaRulerScrollView.DISTANCELEFTANDRIGHT * 2, height: self.rulerHeight)

    }
}
