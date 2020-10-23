//
//  VideoMusicDiscView.swift
//  PPBody
//
//  音乐选中的转盘
//
//  Created by Nathan_he on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class VideoMusicDiscView: UIView
{
    
    var coverIV: UIImageView!
    
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
        let bg = UIImageView(frame: self.bounds)
        bg.image = UIImage(named: "music_play_background")
        self.addSubview(bg)
        
        coverIV = UIImageView(frame: CGRect(x: self.na_width/5, y: self.na_height/5, width: self.na_width * 3/5, height: self.na_height * 3/5))
        coverIV.contentMode = .scaleAspectFill
        coverIV.layer.cornerRadius = self.coverIV.na_width/2
        coverIV.clipsToBounds = true
        
//        coverIV.setCoverImageUrl(DataManager.getHead())
        coverIV.image = UIImage(named: "video_music")
        self.addSubview(coverIV)
    }
    
    func setCover(_ url: String)
    {
        self.coverIV.setCoverImageUrl(url)
    }
    
    func startRotate() {
        let rotateAni = CABasicAnimation(keyPath: "transform.rotation")
        rotateAni.fromValue = 0.0
        rotateAni.toValue = .pi * 2.0
        rotateAni.duration = 10
        rotateAni.repeatCount = MAXFLOAT
        self.layer.add(rotateAni, forKey: nil)
    }
    
    func pauseRotate() {
        let pauseTime = self.layer.convertTime(CACurrentMediaTime(), to: nil)
        self.layer.speed = 0.0
        self.layer.timeOffset = pauseTime
    }
    
    func resumeRotate() {
        let pauseTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), to: nil) - pauseTime
        self.layer.beginTime = timeSincePause
    }
}
