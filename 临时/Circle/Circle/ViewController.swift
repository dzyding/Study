//
//  ViewController.swift
//  Circle
//
//  Created by edz on 2020/1/10.
//  Copyright © 2020 灰s. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var startTime: CFTimeInterval = 0
    
    lazy var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 10.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        return animation
    }()
    
    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineJoin = .round
        shapeLayer.lineWidth = 5.0
        shapeLayer.lineCap = .round
        return shapeLayer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let w = view.frame.width
        let h = view.frame.height
        let path = UIBezierPath(arcCenter: CGPoint(x: w/2.0, y: h/2.0), radius: min(w, h) / 2.0, startAngle: -CGFloat(Double.pi / 2.0), endAngle: CGFloat(Double.pi * 3.0 / 2.0), clockwise: true)
        
        shapeLayer.path = path.cgPath
        view.layer.addSublayer(shapeLayer)
        shapeLayer.add(animation, forKey: "strokeEndAnimation")
        
        startTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
    }

    @IBAction func stop(_ sender: Any) {
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }
    
    @IBAction func start(_ sender: Any) {
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
    }
    
    @IBAction func addTen(_ sender: Any) {
        shapeLayer.removeAllAnimations()
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        // 已经过去的时长
        let start = pausedTime - startTime
        // 动画总时长
        let total = animation.duration + 10
        // 这里新的动画时长需要减掉已经过去的
        animation.duration = total - start
        // 这里用完整的动画时长才计算百分比
        animation.fromValue = start / total
        animation.toValue = 1.0
        
        shapeLayer.add(animation, forKey: "strokeEndAnimation")
        print(shapeLayer.convertTime(CACurrentMediaTime(), from: nil))
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print(shapeLayer.convertTime(CACurrentMediaTime(), from: nil))
    }
}

