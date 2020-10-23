//
//  AssetImageGenerator.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum AssetInfoType {
    case video
    case image
}

class AssetInfo: NSObject
{
    var path: String!
    var type: AssetInfoType!
    var startTime: CGFloat!
    var duration: CGFloat?
    var animDuration: CGFloat!
    
    private var generator : AVAssetImageGenerator?
    
    func realDuration()->CGFloat
    {
        return duration! - animDuration
    }
    
    func captureImageAtTime(_ time: CGFloat, outputSize: CGSize) -> UIImage
    {
        if type == .image
        {
            return self.imageFromImageWithOutputSize(outputSize)
        }else{
            return self.imageFromVideoWithOutputSize(outputSize, at: time)
        }
    }
    
    func imageFromImageWithOutputSize(_ outputSize: CGSize)-> UIImage
    {
        let image = UIImage(contentsOfFile: path)!
        let imageRatio = image.size.width / image.size.height
        
        var outputSizeNew = outputSize
        
        if image.size.width > image.size.height
        {
            outputSizeNew.height = outputSizeNew.width / imageRatio
        }else{
            outputSizeNew.width = outputSizeNew.height * imageRatio
        }
        UIGraphicsBeginImageContext(outputSizeNew)
        image.draw(in: CGRect(x: 0, y: 0, width: outputSizeNew.width, height: outputSizeNew.height))
        let picture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return picture!
    }
    
    func imageFromVideoWithOutputSize(_ outputSize: CGSize, at time: CGFloat) -> UIImage
    {
        if generator == nil{
            generator = AVAssetImageGenerator(asset: self.composition()!)
            generator?.maximumSize = outputSize
            generator?.appliesPreferredTrackTransform = true
            generator?.requestedTimeToleranceAfter = CMTime.zero
            generator?.requestedTimeToleranceBefore = CMTime.zero
        }
        
        let cmtime = CMTime(value: CMTimeValue((time<0 ? 0 : time) * 1000), timescale: 1000)
        let image = try! generator?.copyCGImage(at: cmtime, actualTime: nil)
        let picture = UIImage(cgImage: image!)
        return picture
    }
    
    func composition()->AVComposition?
    {
        let compsition = AVMutableComposition()
        let compositionVideoTrack = compsition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)

        var assetTrackVideo:AVAssetTrack?
        if asset.tracks(withMediaType: .video).count != 0
        {
            assetTrackVideo = asset.tracks(withMediaType: .video)[0]
        }
        
        if assetTrackVideo != nil
        {
            let start = CMTime(value:CMTimeValue((startTime - animDuration)*1000), timescale: 1000)
            var duration = assetTrackVideo?.timeRange.duration
            
            if self.duration != nil{
                duration = CMTime(value: CMTimeValue(self.duration! * 1000), timescale: 1000)
            }
            
            try! compositionVideoTrack?.insertTimeRange(CMTimeRange(start: start, duration: duration!), of: assetTrackVideo!, at: CMTime.zero)
            compositionVideoTrack?.preferredTransform = (assetTrackVideo?.preferredTransform)!
            return compsition
    
        }
        return nil
    }
}


class AssetImageGenerator: NSObject
{
    var outputSize: CGSize?
    var imageCount: Int = 0
    var duration: CGFloat?
    
    private var assets: [AssetInfo]?
    private var shouldCancel = false
    
    let queue = DispatchQueue(label: "com.qx1024.ppbody.generator")

    
    
    override init() {
        super.init()
        assets = [AssetInfo]()
        imageCount = 8
        outputSize = CGSize(width: 50, height: 50)
        duration = 0
    }
    
    func addImageWithPath(_ path: String, duration: CGFloat, animDuration: CGFloat)
    {
        let info = AssetInfo()
        info.path = path
        info.duration = duration
        info.animDuration = animDuration
        info.type = .image
        assets?.append(info)
        
        self.duration! += info.realDuration()
    }
    
    func addVideoWithPath(_ path: String, startTime:CGFloat, duration:CGFloat, animDuration:CGFloat)
    {
        let info = AssetInfo()
        info.path = path
        info.duration = duration
        info.animDuration = animDuration
        info.startTime = startTime
        info.type = .video
        assets?.append(info)
        
        self.duration! += info.realDuration()
    }
    
    func generateWithCompleteHandler(_ handler:@escaping (UIImage)->())
    {
        shouldCancel = false
        queue.async {
            let step = self.duration! / CGFloat(self.imageCount)
            var currentDuration :CGFloat = 0
            var index = 0
            
            for info in self.assets!
            {
                let duration = info.realDuration()
                currentDuration += duration
                let count = Int(currentDuration/step)
                
                for i in index..<count
                {
                    let time = CGFloat(i)*step - (currentDuration - duration)
                    let image = info.captureImageAtTime(time, outputSize: self.outputSize!)
                    handler(image)
                    if self.shouldCancel
                    {
                        break
                    }
                }
                
                index = count
                if self.shouldCancel
                {
                    break
                }
            }
            
        }
    }
    
    func cancel()
    {
        self.shouldCancel = true
    }
}
