//
//  NaAVAsset.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

extension AVAsset {
    
    func avAssetNaturalSize()-> CGSize
    {
        var assetTrackVideo:AVAssetTrack?
        let videoTracks = self.tracks(withMediaType: .video)
        if videoTracks.count > 0
        {
            assetTrackVideo = videoTracks[0]
        }
        
        var sw = assetTrackVideo?.naturalSize.width
        var sh = assetTrackVideo?.naturalSize.height
        
        var isAssetPortrait = false
        let trackTrans = assetTrackVideo?.preferredTransform
        
        if (trackTrans?.b == 1.0 && trackTrans?.c == -1.0) || (trackTrans?.b == -1.0 && trackTrans?.c == 1.0)
        {
            isAssetPortrait = true
        }
        
        if isAssetPortrait
        {
            let t = sw
            sw = sh
            sh = t
        }
        
        return CGSize(width: sw!, height: sh!)
    }
    
    func frameRate()->Float
    {
        var assetTrackVideo:AVAssetTrack?
        let videoTracks = self.tracks(withMediaType: .video)
        if videoTracks.count > 0
        {
            assetTrackVideo = videoTracks[0]
        }
        return (assetTrackVideo?.nominalFrameRate)!
    }
    
    func avAssetVideoTrackDuration() -> CGFloat
    {
        let videoTracks = self.tracks(withMediaType: .video)
        if videoTracks.count > 0
        {
            let assetTrackVideo = videoTracks[0]
            return CGFloat(CMTimeGetSeconds(CMTimeRangeGetEnd(assetTrackVideo.timeRange)))
        }
        
        let audioTracks = self.tracks(withMediaType: .audio)
        if audioTracks.count > 0
        {
            let assetTrackAudio = audioTracks[0]
            return CGFloat(CMTimeGetSeconds(CMTimeRangeGetEnd(assetTrackAudio.timeRange)))
        }
        
        return -1
    }
    
}
