//
//  CropVideoVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import ZKProgressHUD

enum CropPlayerStatus {
    case pause                //结束或暂停
    case playing              //播放中
    case playingBeforeSeek    // 拖动之前是播放状态
}

class CropVideoInfo: NSObject {
    
    var path:String?
    var duration:CGFloat?
    var startTime:CGFloat?
    var endTime:CGFloat?
    var rotate:Int?
    var outputSize: CGSize?
    var minDuration:CGFloat?
    var maxDuration:CGFloat?
}

protocol CropVideoCompleteDelegate: NSObjectProtocol {
    func cropComplete(_ path: String)
}

class CropVideoVC: BaseVC {
    
    static let PlayerItemStatus = "status"
    
    var cutInfo: CropVideoInfo!
    
    var avAsset: AVAsset!
    var playerItem: AVPlayerItem!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    var playerStatus:CropPlayerStatus?
    
    var thumbnailView: CropVideoThumbnailView!
    
    var originalMediaSize: CGSize!
    var orgVideoRatio: CGFloat!
    
    var destRatio: CGFloat!
    
    var outputSize: CGSize!
    
    var preview:UIView!
    
    var isCancel = false //是否取消了
    var hasError = false // 裁剪发生错误
    
    var cutPanel: AliyunCrop?
    
    var onlyCrop = false
    
    var delegate: CropVideoCompleteDelegate?
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: SafeTop + 10, width: 44, height: 44)
        btn.setImage(UIImage(named: "video_back"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var cropBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("裁剪", for: .normal)
        btn.frame = CGRect(x: Int(ScreenWidth - 64), y: SafeTop + 26, width: 56, height: 24)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.addTarget(self, action: #selector(cropAction), for: .touchUpInside)
        btn.backgroundColor = YellowMainColor
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.enableInterval = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        ToolClass.removeChildController(self, removeClass: VideoRecordVC.self)
        
        self.cutInfo.minDuration = 8
        self.cutInfo.maxDuration = CGFloat(VideoDuration)
        
        setupSubViews()
        
        
        let sourceUrl = URL(fileURLWithPath: (cutInfo?.path)!)
        avAsset = AVAsset(url: sourceUrl)
        
        originalMediaSize = avAsset.avAssetNaturalSize()
        destRatio = cutInfo.outputSize!.width / cutInfo.outputSize!.height
        
        orgVideoRatio = originalMediaSize.width / originalMediaSize.height
        
        
        //视频等比例缩放
        if originalMediaSize.width <= cutInfo.outputSize!.width
        {
            self.outputSize = originalMediaSize
        }else{
            self.outputSize = CGSize(width: cutInfo.outputSize!.width, height: cutInfo.outputSize!.width / orgVideoRatio)
        }
        
        //比例必须是偶数
        self.outputSize.width = (self.outputSize.width.truncatingRemainder(dividingBy: 2) == 0) ? self.outputSize.width : self.outputSize.width + 1
        self.outputSize.height = (self.outputSize.height.truncatingRemainder(dividingBy: 2) == 0) ? self.outputSize.height : self.outputSize.height + 1

        
        self.setAVPlayer()
        
        self.addNotification()
        thumbnailView.avAsset = avAsset
    }
    
    func setupSubViews()
    {
        self.preview = UIView(frame: self.view.bounds)
        self.preview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewTapGesture)))
        self.view.addSubview(self.preview)
        
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.cropBtn)
        
        thumbnailView = CropVideoThumbnailView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(SafeBottom+12) - ScreenWidth / 4 - 50, width: ScreenWidth, height: ScreenWidth / 4 + 12), cutinfo: self.cutInfo)
        thumbnailView.delegate = self
        self.view.addSubview(thumbnailView)
        
    }
    
    func setAVPlayer()
    {
        playerItem = AVPlayerItem(asset: avAsset!)
        playerItem.addObserver(self, forKeyPath: CropVideoVC.PlayerItemStatus, options: [.new, .old], context: nil)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.preview.bounds
        self.preview.layer.addSublayer(avPlayerLayer)
        
    }
    
    func addNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        avPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //MARK: Notification Action
    @objc func appDidEnterBackground(_ noti: Notification)
    {
        
    }
    
    @objc func appDidBecomeActive(_ noti: Notification)
    {
        if self.navigationController?.visibleViewController == self
        {
            self.playVideo()
        }
        
    }
    
    @objc func playerItemDidReachEnd(_ noti: Notification)
    {
        if self.navigationController?.visibleViewController == self
        {
            avPlayer.pause()
            let p = noti.object as! AVPlayerItem
            p.seek(to: CMTime(value: CMTimeValue(cutInfo.startTime! * 1000), timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: nil)
            avPlayer.play()
            playerStatus = .playing
        }
        
    }
    
    @objc override func backAction()
    {
        self.pauseVideo()
        self.didStopCut()
        super.backAction()
    }
    
    @objc func cropAction()
    {
        didStartClip()
    }
    
    //开始裁剪
    func didStartClip()
    {
        self.pauseVideo()
//        self.thumbnailView.isUserInteractionEnabled = false
        
        //进入编辑页面
        if !onlyCrop
        {
            self.createEditorWorkspace(cutInfo.path!)
            return
        }
        
        //不需要裁剪
        if cutInfo.endTime! - cutInfo.startTime! == cutInfo.duration!
        {
//            self.createEditorWorkspace(cutInfo.path!)
            self.delegate?.cropComplete(cutInfo.path!)

            self.navigationController?.popViewController(animated: true)
            return
        }
        
        
        cutPanel?.cancel()
        
        cutPanel = AliyunCrop()
        cutPanel?.delegate = self
        
        cutPanel?.inputPath = cutInfo.path
        cutPanel?.outputPath = PPBodyPathManager.getVideoOutPut()
        
        cutPanel?.outputSize = self.outputSize
        
        cutPanel?.cropMode = .cutModeScaleAspectFill
        cutPanel?.fillBackgroundColor = UIColor.black
        cutPanel?.videoQuality = .veryHight
        
        cutPanel?.startTime = Float(cutInfo.startTime!)
        cutPanel?.endTime = Float(cutInfo.endTime!)
        
        cutPanel?.start()
        
        isCancel = false
        hasError = false
        
    }
    
    //取消裁剪
    func didStopCut()
    {
        self.thumbnailView.isUserInteractionEnabled = true
        self.cropBtn.isEnabled = true
        cutPanel?.cancel()
        isCancel = true
    }
    
    func destoryAVPlayer()
    {
        if (self.avPlayer != nil)
        {
            self.avPlayer = nil
            self.avPlayerLayer = nil
        }
    }
    
    @objc func previewTapGesture()
    {
        if playerStatus == .playing
        {
            self.pauseVideo()
        }else{
            self.playVideo()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == CropVideoVC.PlayerItemStatus
        {
            let status = playerItem.status
            if status == .readyToPlay
            {
                cutInfo?.duration = playerItem.asset.avAssetVideoTrackDuration()
                if cutInfo?.endTime == 0
                {
                    cutInfo?.startTime = 0
                    cutInfo?.endTime = cutInfo?.maxDuration
                }
                
                playerStatus = .playingBeforeSeek
                self.playVideo()
                thumbnailView.loadThumbnailData()
                playerItem.removeObserver(self, forKeyPath: CropVideoVC.PlayerItemStatus)
            }else{
                print("系统播放器无法播发视频",keyPath ?? "")
            }
        }
        
    }
    
    func playVideo()
    {
        if playerStatus == .playingBeforeSeek
        {
            avPlayer.seek(to: CMTime(value: CMTimeValue((cutInfo?.startTime)! * 1000), timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
        avPlayer.play()
        
        playerStatus = .playing
    }
    
    func pauseVideo()
    {
        if playerStatus == .playing
        {
            playerStatus = .pause
            avPlayer.pause()
        }
    }
    
    //创建编辑区域
    func createEditorWorkspace(_ videoPath: String)
    {
        let taskPath = PPBodyPathManager.createEditDir()
        if FileManager.default.fileExists(atPath: taskPath)
        {
            try? FileManager.default.removeItem(atPath: taskPath)
        }
    
//        FIXME: AliyunImporter
        /*
        let importer = AliyunImporter(path: taskPath, outputSize: self.outputSize)
        let videoParam = AliyunVideoParam()
        videoParam.scaleMode = AliyunScaleMode.fit
        videoParam.videoQuality = .veryHight
        let clip = AliyunClip(videoPath: videoPath, startTime: cutInfo.startTime!, duration: cutInfo.endTime! - cutInfo.startTime!, animDuration: 0)
//        let clip = AliyunClip(videoPath: videoPath, animDuration: 0)
        importer?.setVideoParam(videoParam)
        importer?.addMediaClip(clip)
        importer?.generateProjectConfigure()
        */
        let vc = VideoEditVC()
        vc.outputSize = self.outputSize
        vc.taskPath = taskPath
        vc.hbd_barAlpha = 0.0
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CropVideoVC: CropVideoThumbnailViewDelegate,AliyunCropDelegate
{
    //MARK: AliyunCropDelegate
    func crop(onError error: Int32) {
        print(error)
        
        if isCancel
        {
            isCancel = false
        }else{
            //裁剪错误
            ZKProgressHUD.showError("裁剪出错")
            
            hasError = true
            cutPanel?.cancel()
            self.thumbnailView.isUserInteractionEnabled = true
            self.cropBtn.isEnabled = true
            self.destoryAVPlayer()
            self.setAVPlayer()
        }
    }
    
    func cropTask(onProgress progress: Float) {
        print("cropTask")
        
        if isCancel
        {
            return
        }
        
        ZKProgressHUD.showProgress(CGFloat(progress))
    }
    
    func cropTaskOnComplete() {
        print("cropTaskOnComplete")
        
        if isCancel
        {
            isCancel = false
        }else{
            if hasError{
                hasError = false
                return
            }
            
            ZKProgressHUD.dismiss()
            
            self.delegate?.cropComplete((cutPanel?.outputPath)!)
            self.navigationController?.popViewController(animated: true)

//            self.createEditorWorkspace((cutPanel?.outputPath)!)
            
        }
    }
    
    func cropTaskOnCancel() {
        print("裁剪任务被取消")
    }
    
    //MARK: CropVideoThumbnailViewDelegate
    func cutBarTouchesDidEnd() {
        playerItem.forwardPlaybackEndTime = CMTime(value: CMTimeValue(cutInfo.endTime! * 1000), timescale: 1000)
        if playerStatus == .playingBeforeSeek
        {
            
            self.playVideo()
        }
        
    }
    
    func cutBarDidMovedToTime(_ time: CGFloat) {
        if playerItem.status == .readyToPlay{
            avPlayer.seek(to: CMTime(value: CMTimeValue(time * 1000), timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            if playerStatus == .playing
            {
                avPlayer.pause()
                playerStatus = .playingBeforeSeek
            }
        }
    }
}
