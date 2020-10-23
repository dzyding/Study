//
//  VideoEditVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import ZKProgressHUD

//FIXME: - 12
class VideoEditVC: BaseVC
{
    var taskPath = PPBodyPathManager.createEditDir()
    var movieView: UIView!
//    var editor: AliyunEditor!
//    var player: AliyunIPlayer!
//    var exporter: AliyunIExporter!
    var clipConstructor: AliyunIClipConstructor!
//    var pasterManager: AliyunPasterManager!
    var editZoneView: VideoEditZoneView!
    var timelineView: TimelineView!
    var currentTimeLabel: UILabel!
    
    var outputSize: CGSize = AliyunOutputVideoSize
    var isExporting = false
    var prePlaying = false
    var outPath = PPBodyPathManager.getVideoOutPut()
    
    var musicDic:[String:Any]?

    var topView: UIView!
    
    var musicPath = PPBodyPathManager.getEditMusic()
    
    var cropMusic : AliyunCrop?
    
    var musicSlider : UISlider!
    
    lazy var musicBtn: VideoMusicDiscView = {
        let btn = VideoMusicDiscView(frame: CGRect(x: 10, y: 90, width: 40, height: 40))
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(musicAction)))
        return btn
    }()
    
    lazy var cropMusicBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 146, width: 44, height: 44)
        btn.setImage(UIImage(named: "clip_musicn"), for: .normal)
        btn.addTarget(self, action: #selector(clipMusicAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var saveBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存", for: .normal)
        btn.frame = CGRect(x: Int(ScreenWidth - 64), y: SafeTop + 26, width: 56, height: 24)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        btn.backgroundColor = YellowMainColor
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.enableInterval = true
        return btn
    }()
    
    lazy var volumeView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        view.isHidden = true
        view.backgroundColor = UIColor.ColorHexWithAlpha("#000000", 0.5)
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        let slider = UISlider(frame: CGRect(x: 30, y: 5, width: 260, height: 40))
        slider.backgroundColor = UIColor.clear
        // UISlider 滑桿按鈕右邊 尚未填滿的顏色
        slider.maximumTrackTintColor = UIColor.white
        // UISlider 滑桿按鈕左邊 已填滿的顏色
        slider.minimumTrackTintColor = YellowMainColor
        // UISlider 滑桿按鈕的顏色
        slider.thumbTintColor = ColorLine
        // UISlider 的最小值
        slider.minimumValue = 0
        // UISlider 的最大值
        slider.maximumValue = 100
        // UISlider 預設值
        slider.value = 0
        // UISlider 是否可以在變動時同步執行動作
        // 設定 false 時 則是滑動完後才會執行動作
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderChange(_:)), for: UIControl.Event.valueChanged)
        view.addSubview(slider)
        
        musicSlider = slider
        
        let leftLabel = UILabel()
        leftLabel.text = "原声"
        leftLabel.textColor = UIColor.white
        leftLabel.font = ToolClass.CustomFont(12)
        leftLabel.sizeToFit()
        leftLabel.center = CGPoint(x: leftLabel.na_width/2 + 5, y: view.na_height/2)
        view.addSubview(leftLabel)

        let rightLabel = UILabel()
        rightLabel.text = "音乐"
        rightLabel.textColor = UIColor.white
        rightLabel.font = ToolClass.CustomFont(12)
        rightLabel.sizeToFit()
        rightLabel.center = CGPoint(x: view.na_width - rightLabel.na_width/2 - 5, y: view.na_height/2)
        view.addSubview(rightLabel)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.addSubviews()
        
        self.movieView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playController)))
        /*
        self.editor = AliyunEditor(path: taskPath, preview: self.movieView)
        self.editor.delegate = self as AliyunIExporterCallback & AliyunIPlayerCallback & AliyunIRenderCallback
        
        self.editor.setRenderBackgroundColor(UIColor.black)
        
        self.player = self.editor.getPlayer()
        
        self.exporter = self.editor.getExporter()
        
        self.clipConstructor = self.editor.getClipConstructor()
        */
        editZoneView = VideoEditZoneView(frame: self.movieView.bounds)
        editZoneView.delegate = self
        
        self.movieView.addSubview(editZoneView)
        
        /*
        self.pasterManager = self.editor.getPasterManager()
        self.pasterManager.displaySize = self.editZoneView.bounds.size
        self.pasterManager.outputSize = outputSize
        self.pasterManager.previewRenderSize = self.editor.getPreviewRenderSize()
        self.pasterManager.delegate = self
        */
        let clips = self.clipConstructor.mediaClips()
        var mediaClips = [TimelineMediaInfo]()
        for clip in clips!
        {
            let yunClip = clip
            let mediaInfo = TimelineMediaInfo()
            mediaInfo.mediaType = TimelineMediaInfoType(rawValue: Int(Float((yunClip.mediaType).rawValue)))
            mediaInfo.path = yunClip.src
            mediaInfo.duration = yunClip.duration
            mediaInfo.startTime = yunClip.startTime
            mediaClips.append(mediaInfo)
        }
        self.timelineView.setMediaClips(mediaClips, segment: 8.0, photos: 8)

        self.addNotifications()
    }
    
    func addSubviews(){
        
        topView = UIView(frame: CGRect(x: Int(self.view.na_width) - 60, y: SafeTop, width: 60, height: 250))
        
        self.view.addSubview(topView)
        self.topView.addSubview(self.musicBtn)
        self.topView.addSubview(self.cropMusicBtn)
        
        
        let factor = outputSize.height/outputSize.width

        self.movieView = UIView(frame: CGRect(x: 0, y:  0, width: ScreenWidth, height: ScreenWidth  * factor))
        self.movieView.backgroundColor = UIColor.brown.withAlphaComponent(0.3)
        self.movieView.center = self.view.center
        self.view.insertSubview(self.movieView, at: 0)
        
        
        self.timelineView = TimelineView(frame: CGRect(x: 0, y: ScreenHeight - ScreenWidth/8 - CGFloat(SafeBottom), width: ScreenWidth, height: ScreenWidth/8))
        self.timelineView.delegate = self
        self.view.addSubview(self.timelineView)
        
        self.currentTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 12))
        self.currentTimeLabel.textColor = UIColor.white
        self.currentTimeLabel.textAlignment = .center
        self.currentTimeLabel.backgroundColor = BackgroundColor
        self.currentTimeLabel.font = ToolClass.CustomFont(11)
        self.currentTimeLabel.center = CGPoint(x: ScreenWidth/2, y: self.timelineView.na_top - 14)
        self.view.addSubview(self.currentTimeLabel)
        
        self.view.addSubview(self.saveBtn)
        
        volumeView.center = CGPoint(x: ScreenWidth/2, y: self.currentTimeLabel.na_centerY - 40)
        self.view.addSubview(self.volumeView)
    }
    
    func addNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeNotifications()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidBecomeActive()
    {
        if isExporting
        {
            isExporting = false
        }else{
            
        }
        
//        self.player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        self.editor.startEdit()
        self.player.play()
        self.timelineView.actualDuration = CGFloat(self.player.getDuration()) //为了让导航条播放时长匹配，必须在这里设置时长
        */
        prePlaying = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.player.stop()
//        self.editor.stopEdit()
        
    }
    
    deinit {
        self.removeNotifications()
    }
    
    @objc func playController()
    {
        /*
        if prePlaying
        {
            self.player.pause()
            prePlaying = false
        }else{
            self.player.resume()
            prePlaying = true
        }
        */
    }
    
    @objc func musicAction()
    {
        let vc = MusicPickVC()
        vc.deleagte = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func clipMusicAction()
    {
        if self.musicDic == nil{
            return
        }
        
        let duration = VideoDuration
        let origin = self.musicDic!["duration"] as! Int
        
        if origin > duration {
            
//            self.player.pause()
            
            self.volumeView.isHidden = true
            self.timelineView.isHidden = true
            
            let url = self.musicDic!["path"] as! String
            let path = ToolClass.getMusicLocalPath(url)
            
            let view = VideoCropMusicView.init(origin, duration: duration, path: path, frame: ScreenBounds)
            view.delegate = self
            UIApplication.shared.keyWindow?.addSubview(view)
        }
    }
    
    @objc func saveAction(){
        
//        VideoUploadService.service.exportCallback = self
//        VideoUploadService.service.exportWithTaskPath(taskPath, outputPath: self.outPath)
//        self.player.pause()
//        self.exporter.startExport(self.outPath)
        self.isExporting = true
//        self.editor.stopEdit()
    }
    
    
    @objc func sliderChange(_ slider: UISlider)
    {
//        self.editor.setAudioMixWeight(Int32(slider.value))
    }

}

extension VideoEditVC: /*AliyunIPlayerCallback,AliyunIExporterCallback,AliyunIRenderCallback, AliyunPasterManagerDelegate,*/ VideoEditZoneViewDelegate,TimelineViewDelegate,MusicPickSelectDelegate,VideoCropMusicViewDelegate,AliyunCropDelegate
{
    //MARK: AliyunCropDelegate
    func crop(onError error: Int32) {
        print("crop:error",error)

    }
    
    func cropTask(onProgress progress: Float) {
        print("cropTask")

    }
    
    func cropTaskOnComplete() {
        ZKProgressHUD.dismiss()
        let duration = self.musicDic!["duration"] as! Int
        let effectMusic = AliyunEffectMusic(file: musicPath)
        effectMusic?.startTime = 0
        effectMusic?.duration = CGFloat(duration)
//        self.editor.apply(effectMusic)
        
    }
    
    func cropTaskOnCancel() {
        print("cropTaskOnCancel")
    }
    
    //MARK: VideoCropMusicViewDelegate
    func selectStartTime(_ start: Int) {
        
        self.volumeView.isHidden = false
        self.timelineView.isHidden = false
        
        if start < 0
        {
            return
        }
        
//        self.editor.removeMusics()
        
        let url = self.musicDic!["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        
        let duration = self.musicDic!["duration"] as! Int
        
        cropMusic = AliyunCrop(delegate: self)
        
        cropMusic?.inputPath = path
        cropMusic?.outputPath = musicPath
        cropMusic?.startTime =  Float(start)
        cropMusic?.endTime = Float(duration)
        //开始裁剪
        cropMusic?.start()
        
        ZKProgressHUD.show()
    }
    
    //MARK: MusicPickSelectDelegate
    func selectMusic(_ dic: [String : Any]) {
        
//        self.editor.removeMusics()
        
        self.musicDic = dic
        
        let url = dic["path"] as! String
        let path = ToolClass.getMusicLocalPath(url)
        
        let duration = dic["duration"] as! Int
        
        let effectMusic = AliyunEffectMusic(file: path)
        effectMusic?.startTime = 0
        effectMusic?.duration = CGFloat(duration)
//        self.editor.apply(effectMusic)
        
        //显示音乐调频页面
        self.volumeView.isHidden = false
//        self.editor.setAudioMixWeight(Int32(self.musicSlider.value))
        
        self.musicBtn.setCover(dic["cover"] as! String)
    }
    
    
    func playProgress(_ playSec: Double, streamProgress streamSec: Double) {
        self.timelineView.seekToTime(CGFloat(streamSec))
        self.currentTimeLabel.text = ToolClass.showDuration(Int(streamSec))
    }
    
    func timelineDraggingTimelineItem(_ item: TimelineItem) {
//        for pasterController in self.pasterManager.getAllPasterControllers()
//        {
//            let paster = pasterController as? AliyunPasterController
//            if paster === item.obj
//            {
//                paster?.pasterStartTime = item.startTime
//                paster?.pasterEndTime = item.endTime
//                break
//            }
//        }
    }
    
    func timelineBeginDragging() {
        
    }
    
    func timelineDraggingAtTime(_ time: CGFloat) {
//        self.player.seek(Float(time))
        self.currentTimeLabel.text = ToolClass.showDuration(Int(time))
//        self.currentTimeLabel.sizeToFit()
    }
    
    func timelineEndDraggingAndDecelerate(_ time: CGFloat) {
        if prePlaying
        {
//            self.player.resume()
        }
    }
    
    func timelineCurrentTime(_ time: CGFloat, duration: CGFloat) {
        
    }
    
    //Mark: AliyunPasterManagerDelegate =========
//    func pasterManagerWillDelete(_ pasterController: AliyunPasterController!) {
//
//    }
    
    //Mark: VideoEditZoneViewDelegate =========
    func currentTouchPoint(_ point: CGPoint) {
        
    }
    
    func mv(fp: CGPoint, to tp: CGPoint) {
        
    }
    
    func touchEnd() {
        
    }
    
    //Mark: AliyunIPlayerCallback =========
    func playerDidStart() {
       print("play start")
    }
    
    func playerDidEnd() {
        
        if !isExporting
        {
//            self.player.play()
            self.isExporting = false
        }
    }
    
    func seekDidEnd() {
        
    }
    
    func playProgress(_ sec: Double) {
        self.timelineView.seekToTime(CGFloat(sec))
        self.currentTimeLabel.text = ToolClass.showDuration(Int(sec))
//        self.currentTimeLabel.sizeToFit()
    }
    
    func playError(_ errorCode: Int32) {
//        self.player.pause()
    }
    
    //Mark: AliyunIExporterCallback =========
    func exporterDidStart() {
    }
    
    func exporterDidEnd(_ outputPath: String!) {
        ZKProgressHUD.dismiss()
        
        if isExporting
        {
            isExporting = false
            
            let vc = VideoPublicVC()
            vc.outpath = outputPath
            vc.hbd_barAlpha = 0
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func exporterDidCancel() {
        print("exporterDidCancel")
    }
    
    func exportProgress(_ progress: Float) {
        print("progress",progress)
        ZKProgressHUD.showProgress(CGFloat(progress))
//         ZKProgressHUD.showProgress(CGFloat(progress), status: "合成中", maskStyle: ZKProgressHUDMaskStyle.visible, onlyOnceFont: UIFont.systemFont(ofSize: 12))

    }
    
    func exportError(_ errorCode: Int32) {
        print(errorCode)

    }
    
    
}
