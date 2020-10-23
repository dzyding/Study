//
//  NaRulerView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol NaRulerViewDelegate: class {
    func naRulerView(scroll: NaRulerScrollView)
}

class NaRulerView: UIView {
    
    weak var delegate: NaRulerViewDelegate?
    
    
    lazy var rulerScrollView:NaRulerScrollView = {
        let rScrollView = NaRulerScrollView()
        rScrollView.delegate = self
        rScrollView.showsHorizontalScrollIndicator = false
        return rScrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rulerScrollView.rulerWidth = frame.size.width
        self.rulerScrollView.rulerHeight = frame.size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.rulerScrollView.rulerWidth = ScreenWidth
        self.rulerScrollView.rulerHeight = frame.size.height
    }
    
    func showRulerScrollViewWithCount(_ min:Int, max:Int, lowCount:CGFloat?, highCount:CGFloat?, average:CGFloat, currentValue:CGFloat, smallMode:Bool)
    {
        
        let count = CGFloat(max - min) / average
        
        rulerScrollView.rulerAverage = average
        rulerScrollView.rulerCount = Int(count)
        rulerScrollView.rulerValue = currentValue - CGFloat(min)
        rulerScrollView.mode = smallMode
        rulerScrollView.min = min
        rulerScrollView.max = max
        
        rulerScrollView.lowValue = lowCount == nil ? 0 :  lowCount!
        rulerScrollView.highValue = highCount == nil ? 0 :  highCount!
        
        if lowCount != nil
        {
            let lowValue = CGFloat(lowCount! - CGFloat(min)) / rulerScrollView.rulerAverage
            rulerScrollView.lowCount = Int(lowValue)
        }else{
            rulerScrollView.lowCount = 0
        }
        
        if highCount != nil
        {
            let hightValue = CGFloat(highCount! - CGFloat(min)) / rulerScrollView.rulerAverage
            rulerScrollView.highCount = Int(hightValue)
        }else{
            rulerScrollView.highCount = Int(count)
        }
        
        
        rulerScrollView.lineWidth = 2
        
        rulerScrollView.backgroundColor = CardColor
        
        rulerScrollView.drawRuler()
        self.addSubview(rulerScrollView)
        self.drawRacAndLine()
    }
    
    func min() -> Int
    {
        return rulerScrollView.min
    }
    
    func max() -> Int
    {
        return rulerScrollView.max
    }
    
    func lowValue() -> CGFloat
    {
        return rulerScrollView.lowValue
    }
    
    func highValue() -> CGFloat
    {
        return rulerScrollView.highValue
    }
    
    //刷新布局
    func refresh(lowCount:CGFloat?, highCount:CGFloat?, currentValue:CGFloat)
    {
        
        if lowCount != nil
        {
            let lowValue = CGFloat(lowCount! - CGFloat(rulerScrollView.min)) / rulerScrollView.rulerAverage
            rulerScrollView.lowCount = Int(lowValue)
            rulerScrollView.lowValue = lowCount!
        }else{
            rulerScrollView.lowCount = 0
        }
        
        if highCount != nil
        {
            let hightValue = CGFloat(highCount! - CGFloat(rulerScrollView.min)) / rulerScrollView.rulerAverage
            rulerScrollView.highCount = Int(hightValue)
            rulerScrollView.highValue = highCount!
        }else{
            rulerScrollView.highCount = rulerScrollView.rulerCount
        }
        
        rulerScrollView.rulerValue = currentValue != 0 ?  currentValue - CGFloat(rulerScrollView.min)  : rulerScrollView.rulerValue
        rulerScrollView.mode = true
        rulerScrollView.drawRuler()
    }
    
    func drawRacAndLine()
    {
        // 渐变
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.rulerScrollView.rulerWidth, height: self.rulerScrollView.rulerHeight)
        
        gradient.colors = [BackgroundColor.withAlphaComponent(1).cgColor,
                           BackgroundColor.withAlphaComponent(0).cgColor,
                           BackgroundColor.withAlphaComponent(1).cgColor]
        
        gradient.locations = [NSNumber(value: 0.0),NSNumber(value: 0.6)]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.addSublayer(gradient)
        
        // 红色指示器
        let shapeLayerLine = CAShapeLayer()
        shapeLayerLine.strokeColor = YellowMainColor.cgColor
        shapeLayerLine.fillColor = YellowMainColor.cgColor
        shapeLayerLine.lineWidth = 2.0
        shapeLayerLine.lineCap = CAShapeLayerLineCap.square
        
        //        let ruleHeight:CGFloat = 20.0
        let pathLind = CGMutablePath()
        
        pathLind.move(to: CGPoint(x: ScreenWidth / 2, y: NaRulerScrollView.DISTANCETOPANDBOTTOM-16))
        //        pathLind.addLine(to: CGPoint(x: self.frame.size.width / 2, y:  8))
        pathLind.addLine(to: CGPoint(x: ScreenWidth / 2 + 8, y: NaRulerScrollView.DISTANCETOPANDBOTTOM-16-11))
        pathLind.addLine(to: CGPoint(x: ScreenWidth / 2 - 8, y: NaRulerScrollView.DISTANCETOPANDBOTTOM-16-11))
        //        pathLind.addLine(to: CGPoint(x: self.frame.size.width / 2 + 8 , y: NaRulerScrollView.DISTANCETOPANDBOTTOM-16-11))
        pathLind.closeSubpath()
        shapeLayerLine.path = pathLind
        
        self.layer.addSublayer(shapeLayerLine)
    }
}

extension NaRulerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let rulerScrollView = scrollView as! NaRulerScrollView
        let offSetX = rulerScrollView.contentOffset.x + self.frame.size.width / 2 - NaRulerScrollView.DISTANCELEFTANDRIGHT;
        let ruleValue = (offSetX / NaRulerScrollView.DISTANCEVALUE) * rulerScrollView.rulerAverage
        
        if ruleValue < 0
        {
            return
        } else if ruleValue > CGFloat(rulerScrollView.rulerCount) * rulerScrollView.rulerAverage
        {
            return
        }
        if self.delegate != nil
        {
            if !rulerScrollView.mode{
                rulerScrollView.rulerValue = ruleValue
            }
            rulerScrollView.mode = false
            self.delegate?.naRulerView(scroll: rulerScrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.animationRebound(scrollView as! NaRulerScrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.animationRebound(scrollView as! NaRulerScrollView)
    }
    
    func animationRebound(_ scrollView:NaRulerScrollView)
    {
        let offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - NaRulerScrollView.DISTANCELEFTANDRIGHT
        var oX = (offSetX / NaRulerScrollView.DISTANCEVALUE) * scrollView.rulerAverage
        
        oX = notRounding(oX, afterPoint: valueIsInteger(oX) ? 0 : 1)
        
        let offX = (oX / scrollView.rulerAverage) * NaRulerScrollView.DISTANCEVALUE + NaRulerScrollView.DISTANCELEFTANDRIGHT - self.frame.size.width/2
        UIView.animate(withDuration: 0.2, animations: {
            scrollView.contentOffset = CGPoint(x: offX, y: 0)
        })
    }
    
    func notRounding(_ price: CGFloat, afterPoint:Int)->CGFloat
    {
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(afterPoint), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let ouncesDecimal = NSDecimalNumber(value: Float(price))
        let roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
        return CGFloat(roundedOunces.floatValue)
    }
    
    func valueIsInteger(_ number:CGFloat) -> Bool{
        let value = Int(number)
        if number - CGFloat(value) == 0
        {
            return true
        }else{
            return false
        }
    }
}
