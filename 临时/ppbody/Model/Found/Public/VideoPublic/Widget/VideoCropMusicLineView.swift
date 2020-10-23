//
//  VideoCropMusicLineView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol VideoCropMusicLineViewDragDelegate:NSObjectProtocol {
    func selectStartTime(_ start: Int)
}

class VideoCropMusicLineView: UIView {
    
    var scrollView: UIScrollView!
    var maskLayer:CALayer?
    
    var duration = 0
    var origin = 0
    var scale: CGFloat = 0
    
    weak var delegate: VideoCropMusicLineViewDragDelegate?
    
    init(_ origin:Int, duration: Int,frame: CGRect)
    {
        self.origin = origin
        self.duration = duration
        self.scale = CGFloat(origin) / CGFloat(duration)
        super.init(frame: frame)
        configSubview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configSubview()
    }
    
    func configSubview()
    {

        let image1 = UIImage(named: "pic_yinlang_gray")
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.na_width, height: self.na_height)
        scrollView.contentSize = CGSize(width: self.na_width * self.scale, height: 0)
        scrollView.backgroundColor = UIColor.init(patternImage: image1!)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.delegate = self
    }
    
    func startAnimation()
    {
        
        let offsetX = scrollView.contentOffset.x
        let start = offsetX * CGFloat(duration) / self.na_width
        self.delegate?.selectStartTime(Int(start))
        
        maskLayer?.removeAllAnimations()
        maskLayer?.removeFromSuperlayer()
        
        let image = UIImage(named: "pic_yinlang_blue")
        maskLayer = CALayer()
        maskLayer?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        maskLayer?.backgroundColor = UIColor(patternImage: image!).cgColor
        self.scrollView.layer.addSublayer(maskLayer!)
        
        let widthAnimation = CABasicAnimation(keyPath: "bounds")
        widthAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: scrollView.contentOffset.x, height: self.na_height))
        widthAnimation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: scrollView.contentOffset.x + self.na_width, height: self.na_height))
        
        let aniAnchorPoint =
            CABasicAnimation(keyPath: "anchorPoint")
        aniAnchorPoint.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
        aniAnchorPoint.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
        
        let group = CAAnimationGroup()
        group.animations = [widthAnimation,aniAnchorPoint]
        group.duration = CFTimeInterval(duration)
        group.repeatCount = Float.infinity
        maskLayer?.add(group, forKey: "coverScroll")
        
    }
    
    func stopAnimation()
    {
        maskLayer?.removeAllAnimations()
        maskLayer?.removeFromSuperlayer()
    }
    
    
}

extension VideoCropMusicLineView: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView
        {

        }
        
        stopAnimation()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAnimation()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            startAnimation()
        }
    }
}
