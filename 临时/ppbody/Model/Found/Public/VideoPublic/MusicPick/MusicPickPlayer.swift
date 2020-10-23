//
//  MusicPickPlayer.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MusicPickPlayer: NSObject {
    
    static let player = MusicPickPlayer()
    
    var player:AVPlayer!
    
    var start:Float = 0
    var duration:Float = 0
    var currentPath: String = ""
    
    override init() {
        super.init()
        player = AVPlayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func destroy()
    {
        self.player.pause()
        self.currentPath = ""
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //返回播放状态
    func getStatus(_ path: String) -> Int
    {
        if currentPath != path
        {
            return 0
        }
        
        if self.player.timeControlStatus == .playing || self.player.timeControlStatus == .waitingToPlayAtSpecifiedRate{
            return 1
        }
        
        return 2
    }
    
    @objc func playerItemDidReachEnd()
    {
        if currentPath == ""
        {
            return
        }
        let composition = self.generateMusicWithPath(path: currentPath, start: start, duration: duration)
        self.player.replaceCurrentItem(with: AVPlayerItem(asset: composition))
        self.player.play()
    }
    
    func playCurrentItem(path: String, start: Float, duration: Float)
    {
        
        self.start = start
        self.duration = duration
        if currentPath != path
        {
            let composition = self.generateMusicWithPath(path: path, start: start, duration: duration)
            self.player.replaceCurrentItem(with: AVPlayerItem(asset: composition))
            self.player.play()
            
            currentPath = path
        }else{
            if self.player.timeControlStatus == .playing
            {
                self.player.pause()
            }else {
                self.player.play()
            }
        }

    }
    
    func playCropItem(path: String, start: Float, duration: Float)
    {
        self.start = start
        self.duration = duration
        self.currentPath = path
        
        let composition = self.generateMusicWithPath(path: path, start: start, duration: duration)
        self.player.replaceCurrentItem(with: AVPlayerItem(asset: composition))
        self.player.play()
    }
    
    
    func generateMusicWithPath(path: String, start: Float, duration: Float) -> AVMutableComposition
    {
        
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let mutableComposition = AVMutableComposition()
        let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = asset.tracks(withMediaType: .audio)[0]
        let startTime = CMTime(value: CMTimeValue(1000*start), timescale: 1000)
        let stopTime = CMTime(value: CMTimeValue(1000*(start + duration)), timescale: 1000)
        let exportTimeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
        try! mutableCompositionAudioTrack?.insertTimeRange(exportTimeRange, of: audioTrack, at: CMTime.zero)
        return mutableComposition
    }
    
}
