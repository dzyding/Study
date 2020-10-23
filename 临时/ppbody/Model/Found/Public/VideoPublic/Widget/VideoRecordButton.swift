//
//  VideoRecordButton.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol VideoRecordButtonDelegate: NSObjectProtocol {
    func startRecording()
    func stopRecording()
}

@objc public enum VideoRecordButtonState : Int {
    case recording, idle, hidden;
}

@objc open class VideoRecordButton : UIButton {
    
    open var buttonColor: UIColor! = .blue{
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = buttonColor.withAlphaComponent(0.5).cgColor
        }
    }
    open var progressColor: UIColor!  = .red {
        didSet {
//            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    
    /// Closes the circle and hides when the RecordButton is finished
    open var closeWhenFinished: Bool = false
    
    weak var delegate: VideoRecordButtonDelegate?
    
    var isPress = true
    
    open var buttonState : VideoRecordButtonState = .idle {
        didSet {
            switch buttonState {
            case .idle:
                self.alpha = 1.0
                currentProgress = 0
                setProgress(0)
                setRecording(false)
            case .recording:
                self.alpha = 1.0
                setRecording(true)
            case .hidden:
                self.alpha = 0
            }
        }
        
    }
    
    fileprivate var circleLayer: CALayer!
    fileprivate var circleBorder: CALayer!
    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var gradientMaskLayer: CAGradientLayer!
    fileprivate var currentProgress: CGFloat! = 0
    
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchUp), for: .touchUpOutside)
        
        self.drawButton()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(VideoRecordButton.didTouchUp), for: .touchUpOutside)
        
        self.drawButton()
    }
    
    
    fileprivate func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        
        let size: CGFloat = self.frame.size.width / 1.5
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 4
        circleBorder.borderColor = buttonColor.withAlphaComponent(0.5).cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: size + 14, height: size + 14)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.cornerRadius = (size + 14) / 2
        layer.insertSublayer(circleBorder, at: 0)
        
//        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi / 2)
//        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi / 2)
//        let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
//        gradientMaskLayer = self.gradientMask()
//        progressLayer = CAShapeLayer()
//        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
//        progressLayer.backgroundColor = UIColor.clear.cgColor
//        progressLayer.fillColor = nil
//        progressLayer.strokeColor = UIColor.black.cgColor
//        progressLayer.lineWidth = 4.0
//        progressLayer.strokeStart = 0.0
//        progressLayer.strokeEnd = 0.0
//        gradientMaskLayer.mask = progressLayer
//        layer.insertSublayer(gradientMaskLayer, at: 0)
    }
    
    fileprivate func setRecording(_ recording: Bool) {
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = CALayerContentsGravity(rawValue: "center")
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 0.88
        scale.toValue = recording ? 0.88 : 1
        scale.duration = duration
        scale.fillMode = CAMediaTimingFillMode.forwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = CAMediaTimingFillMode.forwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = CAMediaTimingFillMode.forwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = CAMediaTimingFillMode.forwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? progressColor.withAlphaComponent(0.5).cgColor : buttonColor.withAlphaComponent(0.5).cgColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 0.88
        borderScale.toValue = recording ? 0.88 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = CAMediaTimingFillMode.forwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = CAMediaTimingFillMode.forwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
//        let fade = CABasicAnimation(keyPath: "opacity")
//        fade.fromValue = recording ? 0.0 : 1.0
//        fade.toValue = recording ? 1.0 : 0.0
//        fade.duration = duration
//        fade.fillMode = kCAFillModeForwards
//        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
//        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    fileprivate func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor!.cgColor, bottomColor!.cgColor]
        return gradientLayer
    }
    
    override open func layoutSubviews() {
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        super.layoutSubviews()
    }
    
    
    @objc open func didTouchDown(){
        if isPress
        {
            self.buttonState = .recording
            self.delegate?.startRecording()
        }
    }
    
    @objc open func didTouchUp() {
        
        if isPress
        {
            if(closeWhenFinished) {
//                self.setProgress(1)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.buttonState = .hidden
                }, completion: { completion in
//                    self.setProgress(0)
                    self.currentProgress = 0
                })
            } else {
                self.buttonState = .idle
                self.delegate?.stopRecording()
            }
        }else{
            //点击
            if self.buttonState == .recording
            {
                self.buttonState = .idle
                self.delegate?.stopRecording()
            }else if self.buttonState == .idle{
                self.buttonState = .recording
                self.delegate?.startRecording()
            }
        }
        

    }
    
    
    /**
     Set the relative length of the circle border to the specified progress
     
     - parameter newProgress: the relative lenght, a percentage as float.
     */
    open func setProgress(_ newProgress: CGFloat) {
//        progressLayer.strokeEnd = newProgress
    }
    
    
}
