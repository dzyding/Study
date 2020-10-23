//
//  VideoEditZoneView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol VideoEditZoneViewDelegate: NSObjectProtocol {
    func currentTouchPoint(_ point:CGPoint)
    func mv(fp:CGPoint ,to tp:CGPoint)
    func touchEnd()
}

class VideoEditZoneView: UIView
{
    weak var delegate:VideoEditZoneViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let preLocation = touches.first!.previousLocation(in: self)
        self.delegate?.currentTouchPoint(preLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first!
        let fp = touch.previousLocation(in: self)
        let tp = touch.location(in: self)
        
        self.delegate?.mv(fp: fp, to: tp)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.delegate?.touchEnd()
    }
}
