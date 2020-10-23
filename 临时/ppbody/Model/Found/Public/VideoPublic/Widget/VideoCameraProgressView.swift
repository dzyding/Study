//
//  VideoProgressView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class VideoCameraProgressView: UIView {
    
    var videoCount = 0 {
        didSet{
            
            if oldValue < self.videoCount
            {
                pointArray.append(progress)
            }else{
                if pointArray.count != 0
                {
                    pointArray.removeLast()
                }
            }
            self.videoCount = self.videoCount < 0 ? 0 : self.videoCount
            selectedIndex = -1
        }
    }
    
    var selectedIndex = -1
    
    var showBlink = false
    {
        didSet{
            self.destroyTimer()
            if showBlink
            {
                self.startTimer()
            }
        }
    }
    var showNoticePoint = false
    var minDuration: CGFloat = 0
    var maxDuration: CGFloat = 0
    
    var pointArray = [CGFloat]()
    
    var colorProgress:UIColor!
    var colorSelect:UIColor!
    var colorNotice:UIColor!
    var colorSepatorPoint:UIColor!
    
    
    var timer:Timer!
    var times = 0
    var progress:CGFloat = 0
    var lineWidth: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray
        self.defaultParam()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func defaultParam(){
        lineWidth = self.na_height * ScreenScale
        colorNotice = UIColor.white
        colorProgress = YellowMainColor
        colorSepatorPoint = UIColor.white
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setNeedsDisplay(_:)), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func destroyTimer()
    {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func updateProgress(_ progress: CGFloat)
    {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        
        let w = self.superview?.na_width
        
        for i in 0..<videoCount
        {
            let sp = pointArray[i]
            if i == selectedIndex
            {
                context?.setStrokeColor(colorSelect.cgColor)
            }else{
                context?.setStrokeColor(colorProgress.cgColor)
            }
            var x = sp / maxDuration * w!
            context?.move(to: CGPoint(x: x, y: 0))
            x = progress / maxDuration * w!
            context?.addLine(to: CGPoint(x: x, y: 0))
            context?.strokePath()
        }
        
        for p in pointArray
        {
            context?.setStrokeColor(colorSepatorPoint.cgColor)
            let x = p / maxDuration * w!
            context?.move(to: CGPoint(x: x-1, y: 0))
            context?.addLine(to: CGPoint(x: x, y: 0))
            context?.strokePath()
        }
    }

    func endPointX() -> CGFloat
    {
        return progress / maxDuration * self.na_width
    }
    
    func reset()
    {
        videoCount = 0
        pointArray = [CGFloat]()
        self.updateProgress(0.0)
    }
    
}
