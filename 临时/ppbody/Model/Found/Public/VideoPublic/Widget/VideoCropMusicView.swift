//
//  VideoCropMusicView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol VideoCropMusicViewDelegate:NSObjectProtocol {
    func selectStartTime(_ start: Int)
}

class VideoCropMusicView: UIView {
    
    var startLB: UILabel!
    
    var lineView: VideoCropMusicLineView!
    
    var duration = 0
    var origin = 0
    var path = ""
    var start = 0
    
    weak var delegate: VideoCropMusicViewDelegate?
    
    init(_ origin:Int, duration: Int, path: String,frame: CGRect)
    {
        self.origin = origin
        self.duration = duration
        self.path = path
        super.init(frame: frame)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()
    {
        
        let bgView = UIView(frame: self.bounds)
        bgView.backgroundColor = UIColor.clear
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidenCropMusic(_:))))
        self.addSubview(bgView)
        
        let bottomview = UIView(frame: CGRect(x: 0, y: self.na_height - CGFloat(200 + SafeBottom), width: self.na_width, height: 200))
        bottomview.backgroundColor = UIColor.clear
        self.addSubview(bottomview)
        
        startLB = UILabel()
        startLB.frame = CGRect(x: 20, y: 60, width: 100, height: 20)
        startLB.textColor = UIColor.white
        startLB.font = ToolClass.CustomFont(10)
        startLB.textAlignment = .center
        startLB.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        startLB.layer.cornerRadius = 10
        startLB.layer.masksToBounds = true
        bottomview.addSubview(startLB)
        
        let tipLB = UILabel()
        tipLB.textColor = UIColor.white
        tipLB.text = "左右拖动声谱裁剪音乐"
        tipLB.sizeToFit()
        tipLB.center = CGPoint(x: bottomview.na_centerX, y: 20)
        bottomview.addSubview(tipLB)
        
        let okBtn = UIButton(type: .custom)
        okBtn.frame = CGRect(x: bottomview.na_width - 75, y: 5, width: 55, height: 30)
        okBtn.backgroundColor = YellowMainColor
        okBtn.setTitle("确认", for: .normal)
        okBtn.titleLabel?.font = ToolClass.CustomFont(12)
        okBtn.setTitleColor(BackgroundColor, for: .normal)
        okBtn.layer.cornerRadius = 4
        okBtn.addTarget(self, action: #selector(okAction(_:)), for: .touchUpInside)
        bottomview.addSubview(okBtn)
        
        lineView = VideoCropMusicLineView.init(self.origin, duration: self.duration, frame: CGRect(x: 0, y: bottomview.na_height - 106 , width: bottomview.na_width, height: 106))
        lineView.delegate = self
         lineView.startAnimation()
        bottomview.addSubview(lineView)
        
        MusicPickPlayer.player.playCropItem(path: self.path, start: 0, duration: Float(duration))
    }
    
    @objc func hidenCropMusic(_ tap : UITapGestureRecognizer)
    {
        MusicPickPlayer.player.destroy()
        self.delegate?.selectStartTime(-1)
        self.removeFromSuperview()
    }

    @objc func okAction(_ sender: UIButton)
    {
        MusicPickPlayer.player.destroy()
        self.delegate?.selectStartTime(start)
        self.removeFromSuperview()
    }
}

extension VideoCropMusicView:VideoCropMusicLineViewDragDelegate
{
    func selectStartTime(_ start: Int) {
        self.startLB.text = "当前从" + ToolClass.showDuration(start) + "开始"
        MusicPickPlayer.player.playCropItem(path: self.path, start: Float(start), duration: Float(duration))
        self.start = start
    }
}
