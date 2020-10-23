//
//  VideoPublicVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import ZKProgressHUD
import DKImagePickerController
import HBDNavigationBar
class VideoRecordVC: BaseVC
{
    
    var lastCameraPosition: AliyunIRecorderCameraPosition!
    
    lazy var cameraView: VideoCameraView = {
        let camera = VideoCameraView(frame: ScreenBounds, videoSize: AliyunOutputVideoSize)
        camera.delegate = self
        return camera
    }()
    
    var recorder: AliyunIRecorder!
    
    var clipManager: AliyunClipManager!
    
    var suspend = false
    
    var musicDic:[String:Any]?
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func loadView() {
        super.loadView()
        self.view = self.cameraView
    }
    
    
    var lastPinchDistance:CGFloat = 0
    var recordingDuration: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BackgroundColor
        
        let videoPath = PPBodyPathManager.getVideoOutPut()
        
        let taskPath = PPBodyPathManager.createRecrodDir()
        if FileManager.default.fileExists(atPath: taskPath)
        {
            try? FileManager.default.removeItem(atPath: taskPath)
        }
        
        recorder = AliyunIRecorder(delegate: self, videoSize: AliyunOutputVideoSize)
        recorder.preview = self.cameraView.previewView
        recorder.outputPath = videoPath
        recorder.outputType = .type420f
        recorder.taskPath = taskPath
        recorder.beautifyStatus = true
        recorder.beautifyValue = 80
        recorder.useFaceDetect = true
        recorder.backCaptureSessionPreset = AVCaptureSession.Preset.hd1280x720.rawValue
        recorder.frontCaptureSessionPreset = AVCaptureSession.Preset.hd1280x720.rawValue
        recorder.faceDetectCount = 2
        recorder.faceDectectSync = false
        
        //录制片段设置
        clipManager = recorder.clipManager
        //教练 1分钟 用户15秒
        clipManager.maxDuration = CGFloat(VideoDuration)
        clipManager.minDuration = 10
        
        self.cameraView.maxDuration = clipManager.maxDuration
        lastCameraPosition = AliyunIRecorderCameraPosition.front
        UIApplication.shared.isIdleTimerDisabled = true
        
        addGesture()
        addNotification()

    }
    override func viewWillAppear(_ animated: Bool) {
        recorder.startPreview(withPositon: lastCameraPosition)
        self.cameraView.setHide(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recorder.stopPreview()
    }
    
    deinit {
        MusicPickPlayer.player.destroy()
        recorder.destroy()
        recorder = nil
    }
    
    func addGesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToFocusPoint(_:)))
        self.recorder.preview.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        self.recorder.preview.addGestureRecognizer(pinchGesture)
        
    }
    
    func addNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    //MARK: Gesture Action
    @objc func tapToFocusPoint(_ tap: UITapGestureRecognizer)
    {
        let view = tap.view
        let point = tap.location(in: view)
        recorder.focusPoint = point
    }
    
    @objc func pinchGesture(_ pin: UIPinchGestureRecognizer)
    {
        if pin.numberOfTouches != 2
        {
            return
        }
        
        let p1 = pin.location(ofTouch: 0, in: recorder.preview)
        let p2 = pin.location(ofTouch: 1, in: recorder.preview)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let dist = sqrt(dx*dx+dy*dy)
        if pin.state == UIGestureRecognizer.State.began
        {
            lastPinchDistance = dist
        }
        
        var change = dist - lastPinchDistance
        change = change / (recorder.preview.na_width * 0.8) * 2.0
        recorder.videoZoomFactor = change
        lastPinchDistance = dist
    }
    
    //MARK: Notification Action
    @objc func appDidEnterBackground(_ noti: Notification) {
        DispatchQueue.main.async {
            self.recorder.stopPreview()
        }
    }
    
    @objc func appWillEnterForeground(_ noti: Notification) {
        DispatchQueue.main.async {
            self.recorder.startPreview()
            self.cameraView.flashBtn.isUserInteractionEnabled = self.recorder.cameraPosition.rawValue != 0
            
            let mode = self.recorder.torchMode
            if mode == AliyunIRecorderTorchMode.on{
                self.cameraView.flashBtn.setImage(UIImage(named: "open_flash"), for: .normal)
            }else if mode == AliyunIRecorderTorchMode.off
            {
                self.cameraView.flashBtn.setImage(UIImage(named: "close_flash"), for: .normal)
            }else{
                self.cameraView.flashBtn.setImage(UIImage(named: "video_auto_flash"), for: .normal)
            }
        }
    }
    
    @objc func appWillResignActive(_ noti: Notification)
    {
        DispatchQueue.main.async {
            if self.recorder.isRecording {
                self.recorder.stopRecording()
                self.recorder.stopPreview()
                self.suspend = true
            }
        }
    }
    
    @objc func appDidBecomeActive(_ noti: Notification)
    {
        DispatchQueue.main.async {
            if self.suspend {
                self.suspend = false
                self.recorder.startPreview()
                self.cameraView.setHide(false)
            }
        }
    }
    
    //MARK: 合成视频
    func exportVideo()
    {
//        VideoUploadService.service.exportCallback = self
//        VideoUploadService.service.exportWithTaskPath(self.recorder.taskPath, outputPath: self.recorder.outputPath)
    }
    
}

extension VideoRecordVC:VideoCameraViewDelegate,AliyunIRecorderDelegate,MusicPickSelectDelegate,VideoCropMusicViewDelegate/*,AliyunIExporterCallback*/
{
    //MARK: AliyunIExporterCallback 代理方法
    func exporterDidStart() {
       
    }
    
    func exporterDidEnd(_ outputPath: String!) {
        ZKProgressHUD.dismiss()

        //跳转
        let vc = VideoPublicVC()
        vc.outpath = self.recorder.outputPath
        if musicDic != nil
        {
            vc.musicId = self.musicDic!["id"] as? Int
        }
        vc.hbd_barAlpha = 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func exporterDidCancel() {
        
    }
    
    func exportProgress(_ progress: Float) {
         ZKProgressHUD.showProgress(CGFloat(progress))
    }
    
    func exportError(_ errorCode: Int32) {
        ZKProgressHUD.showError("录制出错了")

    }
    

    //MARK: VideoCropMusicViewDelegate 代理方法
    func selectStartTime(_ start: Int) {
        self.cameraView.setAllHide(false)
        let url = self.musicDic!["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        
        let duration = self.musicDic!["duration"] as! Int
        
        let effectMusic = AliyunEffectMusic(file: path)
        effectMusic?.startTime = CGFloat(start)
        effectMusic?.duration = CGFloat(duration)
        recorder.apply(effectMusic)
    }
    
    //MARK: MusicPickSelectDelegate 代理方法
    func selectMusic(_ dic: [String : Any]) {
        
        self.musicDic = dic
        
        let url = dic["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        
        let duration = dic["duration"] as! Int
        
        let effectMusic = AliyunEffectMusic(file: path)
        effectMusic?.startTime = 0
        effectMusic?.duration = CGFloat(duration)
        recorder.apply(effectMusic)
        
        self.cameraView.musicBtn.setCover(dic["cover"] as! String)
    }
    
    //MARK: AliyunIRecorderDelegate 代理方法
    func recorderDeviceAuthorization(_ status: AliyunIRecorderDeviceAuthor) {
        var title = ""
        var msg = ""
        var showAlert = false
        if status == .audioDenied
        {
            title = "麦克风访问受限"
            msg = "点击【设置】,允许访问您的麦克风"
            showAlert = true
        }else if status == .videoDenied
        {
            title = "摄像头访问受限"
            msg = "点击【设置】,允许访问您的摄像头"
            showAlert = true
        }
        
        if !showAlert
        {
            return
        }
        
        let alertController = UIAlertController(title: title, message:msg, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "设置", style: UIAlertAction.Style.default) { (alertAction) in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(alertAction)
        
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
            
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    //录制实时时长
    func recorderVideoDuration(_ duration: CGFloat) {
        DispatchQueue.main.async{
            let percent = duration / self.clipManager.maxDuration
            self.cameraView.recordingPercent(percent)
            self.recordingDuration = TimeInterval(duration)
        }
    }
    
    //录制到最大时长时的回调，可应用于录制到最大时长时直接跳转界面
    func recorderDidStopWithMaxDuration() {
        self.cameraView.flashBtn.isUserInteractionEnabled = recorder.cameraPosition != .front
        self.cameraView.progressView.videoCount += 1
        self.cameraView.progressView.showBlink = false
        self.recorder.finishRecording()
        self.cameraView.destroy()
        ZKProgressHUD.show()
        //合成视频
//        self.exportVideo()
    }
    
    //停止录制回调
    func recorderDidStopRecording() {
        self.cameraView.finishBtn.isEnabled = clipManager.partCount > 0 && self.recordingDuration >= 10
        self.cameraView.musicBtn.isUserInteractionEnabled = clipManager.partCount == 0
        self.cameraView.destroy()
    }
    
    //录制结束的回调
    func recorderDidFinishRecording() {
        ZKProgressHUD.dismiss()
        if !suspend
        {
            //跳转
            let vc = VideoPublicVC()
            vc.outpath = self.recorder.outputPath
            if musicDic != nil
            {
                vc.musicId = self.musicDic!["id"] as? Int
            }
            vc.hbd_barAlpha = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK: VideoCameraViewDelegate 代理方法
    func backBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func flashBtnClick() -> String {
        let mode = recorder.switchTorchMode()
        if mode == AliyunIRecorderTorchMode.on{
            return "open_flash"
        }else if mode == AliyunIRecorderTorchMode.off
        {
            return "close_flash"
        }else{
            return "video_auto_flash"
        }
    }
    
    func ablumBtnClick() {
        let pickerController = DKImagePickerController()
        
        pickerController.assetType = .allVideos
        pickerController.allowsLandscape = true
        pickerController.allowMultipleTypes = false
        pickerController.singleSelect = true
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        pickerController.sourceType = .photo
        pickerController.exportsWhenCompleted = true
        pickerController.exportStatusChanged = { status in
            switch status {
            case .exporting:
                print("exporting")
                ZKProgressHUD.show()
            case .none:
                print("none")
                ZKProgressHUD.dismiss()
            }
        }
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            if assets.count == 0
            {
                return
            }
            
            let asset = assets[0]
            if asset.type == .video
            {
                
                if pickerController.exportsWhenCompleted {
                    for asset in assets {
                        if let error = asset.error {
                            print("exporterDidEndExporting with error:\(error.localizedDescription)")
                        } else {
                            print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
                            
                            let cutInfo = CropVideoInfo()
                            cutInfo.startTime = 0
                            cutInfo.endTime = 0
                            cutInfo.duration = 0
                            cutInfo.path = asset.localTemporaryPath!.path
                            cutInfo.outputSize = AliyunOutputVideoSize
                            DispatchQueue.main.async {
                                let vc = CropVideoVC()
                                vc.cutInfo = cutInfo
                                vc.hbd_barHidden = true
                                self.navigationController?.pushViewController(vc, animated: true)
                                //                            self.present(HBDNavigationController(rootViewController: vc), animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }
    
    
    func cameraBtnClick() {
        recorder.switchCameraPosition()
        lastCameraPosition = recorder.cameraPosition
        
        cameraView.flashBtn.isUserInteractionEnabled = recorder.cameraPosition.rawValue != 0
        
        let mode = recorder.torchMode
        if mode == AliyunIRecorderTorchMode.on{
            cameraView.flashBtn.setImage(UIImage(named: "open_flash"), for: .normal)
        }else if mode == AliyunIRecorderTorchMode.off
        {
            cameraView.flashBtn.setImage(UIImage(named: "close_flash"), for: .normal)
        }else{
            cameraView.flashBtn.setImage(UIImage(named: "video_auto_flash"), for: .normal)
        }
    }
    
    func recordBtnTouchesBegin() {
        recorder.startRecording()
        self.cameraView.setHide(true)
    }
    
    func recordBtnTouchesEnd() {
        recorder.stopRecording()
        self.cameraView.setHide(false)
    }
    
    func musicBtnClick() {
        
        recorder.stopPreview()
        
        let vc = MusicPickVC()
        vc.deleagte = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func cropMusicBtnClick() {
        
        if self.musicDic == nil{
            return
        }
        
        let duration = VideoDuration
        let origin = self.musicDic!["duration"] as! Int
        
        if origin > duration {
            //可以裁剪
            self.cameraView.setAllHide(true)
            
            let url = self.musicDic!["path"] as! String
            let path = ToolClass.getMusicLocalPath(url)
            
            let view = VideoCropMusicView.init(origin, duration: duration, path: path, frame: ScreenBounds)
            view.delegate = self
            self.view.addSubview(view)
        }
    }
    
    func deleteBtnClick() {
        clipManager.deletePart()
        self.cameraView.progressView.videoCount -= 1
        let percent = clipManager.duration / clipManager.maxDuration
        self.cameraView.recordingPercent(percent)
        recordingDuration = TimeInterval(clipManager.duration)
        
        self.cameraView.finishBtn.isEnabled = clipManager.partCount > 0 && self.recordingDuration >= 10
        self.cameraView.musicBtn.isUserInteractionEnabled = clipManager.partCount == 0
    }
    
    func finishBtnClick() {
        if clipManager.partCount != 0
        {
            recorder.finishRecording()
            ZKProgressHUD.show()
//            self.exportVideo()
        }
    }
    
    func recordingProgressDuration(_ duration: TimeInterval) {
        
    }
    
    func didSelectRate(_ rate: CGFloat) {
        self.recorder.setRate(rate)
    }
    
    
}
