//
//  TPPCountDownView.swift
//  PPBody
//
//  Created by edz on 2020/4/29.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TPPCountDownView: UIView, InitFromNibEnable {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var timeLB: UILabel!
    
    private var timer: Timer?
    // 动画开始的时间
    private var startTime: TimeInterval = 0
    // 动画的时长
    private var maxTime: TimeInterval = 0
    
    // 倒数时间的 block
    var timerHl: ((TimeInterval)->())?
    // 时间结束的 block
    var finishedHl: ((CFTimeInterval?)->())?
    // 更改时间的 block
    var changeTimeHl: ((TimeInterval)->())?

    func initUI() {
        bgView.layer.addSublayer(bgLayer)
        bgView.layer.addSublayer(gradientLayer)
    }
    
    func start(_ time: TimeInterval,
               timerHl: @escaping (TimeInterval)->(),
               finishedHl: @escaping (CFTimeInterval?) -> (),
               changeTimeHl: @escaping (TimeInterval) -> ()) {
        self.timerHl = timerHl
        self.finishedHl = finishedHl
        self.changeTimeHl = changeTimeHl
        maxTime = time
        timeLB.text = "\(Int(time))"
        animation.duration = time
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.timeOffset = 0.0
        animation.beginTime = 0.0
        yLayer.add(animation, forKey: "strokeEndAnimation")
        
        startTime = yLayer.convertTime(CACurrentMediaTime(), from: nil)
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func finished(_ c: CFTimeInterval? = nil) {
        timer?.invalidate()
        timer = nil
        finishedHl?(c)
        
        timerHl = nil
        changeTimeHl = nil
        finishedHl = nil
        (superview as? DzyPopView)?.hide()
    }
    
    /// 还剩多少秒
    private func lastValue() -> CFTimeInterval {
        let now = yLayer.convertTime(CACurrentMediaTime(), from: nil)
        return startTime + maxTime + 1 - now
    }
    
    /// 已经过了多少秒
    private func useValue() -> CFTimeInterval {
        let now = yLayer.convertTime(CACurrentMediaTime(), from: nil)
        return now - startTime
    }
    
    @objc private func timerAction() {
        let x = lastValue()
        timeLB.text = "\(Int(x))"
        timerHl?(x)
        
        if x <= 0 {
            finished()
        }
    }
    
    @IBAction private func closeAction(_ sender: Any) {
        (superview as? DzyPopView)?.hide()
    }
    
    // 跳过
    @IBAction func jumpAction(_ sender: Any) {
        let x = useValue()
        finished(x)
    }
    
    // 加 减时间
    @IBAction func updateTimeAction(_ sender: UIButton) {
        yLayer.removeAllAnimations()
        let now = yLayer.convertTime(CACurrentMediaTime(), from: nil)
        let started = now - startTime
        // 1减 2加
        maxTime = sender.tag == 1 ?
            (maxTime - 10) :
            (maxTime + 10)
        guard maxTime > 0, maxTime - started > 0 else {
            finished()
            return
        }
        changeTimeHl?(maxTime)
        animation.duration = maxTime - started
        animation.fromValue = 1.0 - started / maxTime
        animation.toValue = 0
        yLayer.add(animation, forKey: "strokeEndAnimation")
    }
    
    //    MARK: - 懒加载
    private lazy var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        return animation
    }()
    
    private lazy var path: UIBezierPath = {
        let w = bgView.frame.width
        let h = bgView.frame.height
        return UIBezierPath(arcCenter: CGPoint(x: w/2.0, y: h/2.0), radius: (w - 10.0) / 2.0, startAngle: -CGFloat(Double.pi / 2.0), endAngle: CGFloat(Double.pi * 3.0 / 2.0), clockwise: true)
    }()
    
    private lazy var bgLayer: CAShapeLayer = {
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.12)
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineJoin = .round
        layer.lineWidth = 10.0
        layer.lineCap = .round
        layer.path = path.cgPath
        return layer
    }()
    
    // 黄色的主动画 layer
    private lazy var yLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = YellowMainColor.cgColor
        layer.lineJoin = .round
        layer.lineWidth = 10.0
        layer.lineCap = .round
        layer.path = path.cgPath
        return layer
    }()
    
    // 设置渐变色
    private lazy var gradientLayer: CALayer = {
        let w = bgView.frame.width
        let h = bgView.frame.height
        let layer = CALayer()
        let glayer = CAGradientLayer()
        glayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        glayer.colors = [
            dzy_HexColor(0xF4BA07).cgColor,
            dzy_HexColor(0xF8E71C).cgColor
        ]
        glayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1),
        ]
        layer.addSublayer(glayer)
        layer.mask = yLayer
        return layer
    }()
}

extension TPPCountDownView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {return}
        finished()
    }
}
