//
//  AVPlayerManager.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/13.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//
import Foundation
import AVFoundation

class AVPlayerManager: NSObject {
    
    var playerArray = [AVPlayer]()
    
    private static let instance = { () -> AVPlayerManager in
        return AVPlayerManager.init()
    }()
    
    private override init() {
        super.init()
    }
    
    class func shared() -> AVPlayerManager {
        return instance
    }
    
    static func setAudioMode() {
        do {
            if #available(iOS 10.0, *) {
                try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("setAudioMode error:" + error.localizedDescription)
        }
        
    }
    
    func play(player:AVPlayer) {
        for object in playerArray {
            object.pause()
        }
        if !playerArray.contains(player) {
            playerArray.append(player)
        }
        player.play()
    }
    
    func remove(player:AVPlayer)
    {
        if playerArray.contains(player)
        {
            playerArray.remove(at: playerArray.firstIndex(of: player)!)
        }
    }
    
    func pause(player:AVPlayer) {
        if playerArray.contains(player) {
            player.pause()
        }
    }
    
    func pauseAll() {
        for object in playerArray {
            object.pause()
        }
    }
    
    func replay(player:AVPlayer) {
        for object in playerArray {
            object.pause()
        }
        if playerArray.contains(player) {
            player.seek(to: CMTime.zero)
            play(player: player)
        } else {
            playerArray.append(player)
            play(player: player)
        }
    }
}
