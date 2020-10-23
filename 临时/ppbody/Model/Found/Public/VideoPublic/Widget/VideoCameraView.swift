//
//  VideoCameraView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol VideoCameraViewDelegate: NSObjectProtocol {
    func backBtnClick()
    func flashBtnClick() -> String
    func cameraBtnClick()
    func recordBtnTouchesBegin()
    func recordBtnTouchesEnd()
    func musicBtnClick()
    func deleteBtnClick()
    func cropMusicBtnClick()
    func finishBtnClick()
    func ablumBtnClick()
    func recordingProgressDuration(_ duration: TimeInterval)
    func didSelectRate(_ rate: CGFloat)
}

class VideoCameraView: UIView {
    
    var maxDuration:CGFloat!
    
    var topView: UIView!
    var centerView: UIView!
    var previewView: UIView!
    
    weak var delegate:VideoCameraViewDelegate?
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: SafeTop + 8, width: 44, height: 44)
        btn.setImage(UIImage(named: "video_back"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var musicBtn: VideoMusicDiscView = {
        let btn = VideoMusicDiscView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(musicAction)))
        return btn
    }()
    
    lazy var cameraBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 10, width: 44, height: 44)
        btn.setImage(UIImage(named: "photo_switch"), for: .normal)
        btn.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var flashBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 62, width: 44, height: 44)
        btn.setImage(UIImage(named: "close_flash"), for: .normal)
        btn.addTarget(self, action: #selector(flashAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var cropMusicBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 114, width: 44, height: 44)
        btn.setImage(UIImage(named: "clip_musicn"), for: .normal)
        btn.addTarget(self, action: #selector(clipMusicAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth - 140, y: ScreenHeight - CGFloat(80) - CGFloat(SafeBottom), width: 44, height: 44)
        btn.setImage(UIImage(named: "video_delete"), for: .normal)
        btn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var finishBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth - 80, y: ScreenHeight - CGFloat(80) - CGFloat(SafeBottom), width: 44, height: 44)
        btn.setImage(UIImage(named: "complete_highlight"), for: .normal)
        btn.setImage(UIImage(named: "complete"), for: .disabled)
        btn.addTarget(self, action: #selector(finishAction), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
    
    lazy var ablumBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth/2 - 100, y: ScreenHeight - CGFloat(80) - CGFloat(SafeBottom), width: 44, height: 44)
        btn.setImage(UIImage(named: "video_album"), for: .normal)
        btn.addTarget(self, action: #selector(ablumAction), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var progressView: VideoCameraProgressView = {
        let progressView = VideoCameraProgressView(frame: CGRect(x: 8, y: SafeTop, width: Int(ScreenWidth) - 16, height: 4))
        progressView.showBlink = false
        progressView.maxDuration = 1
        progressView.minDuration = 0
        progressView.colorProgress = YellowMainColor
        progressView.backgroundColor = UIColor.ColorHexWithAlpha("#000000", 0.2)
        return progressView
    }()
    
    lazy var captureBtn:VideoRecordButton = {
         let btn = VideoRecordButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        btn.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight - CGFloat(SafeBottom + 60))
        btn.progressColor = YellowMainColor
        btn.buttonColor = UIColor.ColorHex("#FD2D57")
        btn.delegate = self
        btn.isPress = false
        return btn
    }()
    
    lazy var captureView: UIView = {
        let captureView = UIView(frame: CGRect(x: ScreenWidth - 10, y: ScreenHeight - 20, width: 100, height: 20))
        captureView.backgroundColor = UIColor.clear
        
        let tx1 = UILabel()
        tx1.text = "单机拍"
        tx1.font = ToolClass.CustomFont(13)
        tx1.textColor = UIColor.white
        tx1.tag = 11
        tx1.isUserInteractionEnabled = true
        tx1.sizeToFit()
        tx1.na_origin = CGPoint(x: 0, y: 0)
        captureView.addSubview(tx1)
        
        let tx2 = UILabel()
        tx2.text = "长按拍"
        tx2.font = ToolClass.CustomFont(13)
        tx2.textColor = UIColor.white
        tx2.alpha = 0.5
        tx2.tag = 12
        tx2.isUserInteractionEnabled = true
        tx2.sizeToFit()
        tx2.na_origin = CGPoint(x: 30 + tx1.na_width, y: 0)
        captureView.addSubview(tx2)
        
        captureView.na_size = CGSize(width: tx1.na_width * 2 + 30, height: 20)
        
        tx1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCaptureView(_:))))
        tx2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCaptureView(_:))))
        
        return captureView
    }()
    
    lazy var rateView: VideoRateSelectView = {
        let rateView = VideoRateSelectView(items: ["极慢","慢","标准","快","极快"])
        rateView.frame = CGRect(x: 40, y: ScreenHeight - CGFloat(150+SafeBottom), width: ScreenWidth - CGFloat(80), height: 40)
        rateView.selectedSegmentIndex = 2
        rateView.addTarget(self, action: #selector(rateChanged(_:)), for: .valueChanged)
        return rateView
    }()
    
    var videoSize: CGSize!
    
    init(frame: CGRect, videoSize: CGSize) {
        super.init(frame: frame)
        self.videoSize = videoSize
        setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubview()
    {
        topView = UIView(frame: CGRect(x: Int(self.na_width) - 60, y: SafeTop, width: 60, height: 250))
        
        self.addSubview(topView)
        
        self.addSubview(self.backBtn)
        self.topView.addSubview(self.cameraBtn)
        self.topView.addSubview(self.flashBtn)
//        self.topView.addSubview(self.musicBtn)
        self.topView.addSubview(self.cropMusicBtn)
        
        self.topView.backgroundColor = UIColor.clear
        
        let whRatio = videoSize.width/videoSize.height
        var w:CGFloat,h:CGFloat
        if whRatio <= 1
        {
            h = self.na_height
            w = h * whRatio
        }else{
            w = self.na_width
            h = w / whRatio
        }
        
        centerView = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        centerView.center = self.center
        self.insertSubview(centerView, at: 0)
        
        previewView = UIView(frame: centerView.bounds)
        centerView.addSubview(previewView)
        
        self.addSubview(self.rateView)
        self.addSubview(self.progressView)
        self.addSubview(self.captureBtn)
        
         self.captureView.na_origin = CGPoint(x: ScreenWidth/2 - (self.captureView.na_width - 30)/4, y: self.captureBtn.na_bottom)
        
        self.addSubview(self.captureView)
        
        self.addSubview(self.deleteBtn)
        self.addSubview(self.finishBtn)
        
        self.addSubview(self.ablumBtn)
    }
    
    func setHide(_ hide:Bool)
    {
        self.topView.isHidden = hide
        self.deleteBtn.isHidden = hide
        self.rateView.isHidden = hide
        self.finishBtn.isHidden = hide
        self.ablumBtn.isHidden = hide
        self.captureView.isHidden = hide
    }
    
    func setAllHide(_ hide:Bool)
    {
        self.topView.isHidden = hide
        self.deleteBtn.isHidden = hide
        self.rateView.isHidden = hide
        self.finishBtn.isHidden = hide
        self.captureBtn.isHidden = hide
        self.ablumBtn.isHidden = hide
        self.captureView.isHidden = hide
    }
    
    //隐藏音乐剪辑 等等
    func setFilterHide(_ hide:Bool)
    {
        self.musicBtn.isHidden = hide
        self.cropMusicBtn.isHidden = hide
        self.rateView.isHidden = hide
    }
    
    //正常录制
    func setFilterNormalHide(_ hide: Bool)
    {
        self.topView.isHidden = hide
        self.deleteBtn.isHidden = hide
        self.finishBtn.isHidden = hide
        self.ablumBtn.isHidden = hide
        self.captureView.isHidden = hide
    }
    
    
    func recordingPercent(_ percent:CGFloat)
    {
        self.progressView.updateProgress(percent)
    }
    
    func destroy()
    {
        
    }
    
    //Mark Action
    
    @objc func tapCaptureView(_ tap: UITapGestureRecognizer)
    {
        let tag = tap.view?.tag
        if tag == 11
        {
            UIView.animate(withDuration: 0.2) {
                self.captureView.na_origin = CGPoint(x: ScreenWidth/2 - (self.captureView.na_width  - 30)/4, y: self.captureBtn.na_bottom)
                let view1 = self.captureView.viewWithTag(11)
                let view2 = self.captureView.viewWithTag(12)
                view1?.alpha = 1.0
                view2?.alpha = 0.5

            }
            self.captureBtn.isPress = false
            
        }else{
            UIView.animate(withDuration: 0.2) {
                self.captureView.na_origin = CGPoint(x: ScreenWidth/2 - self.captureView.na_width + (self.captureView.na_width - 30)/4, y: self.captureBtn.na_bottom)
                let view1 = self.captureView.viewWithTag(11)
                let view2 = self.captureView.viewWithTag(12)
                view1?.alpha = 0.5
                view2?.alpha = 1.0
            }
            self.captureBtn.isPress = true

        }
        
    }
    
    @objc func backAction()
    {
        self.delegate?.backBtnClick()
    }
    
    @objc func flashAction(_ sender: UIButton)
    {
        let imageName = self.delegate?.flashBtnClick()
        sender.setImage(UIImage(named: imageName!), for: .normal)
    }
    
    @objc func ablumAction(_ sender: UIButton)
    {
        self.delegate?.ablumBtnClick()
    }
    
    @objc func cameraAction()
    {
        self.delegate?.cameraBtnClick()
    }
    
    @objc func musicAction()
    {
        self.delegate?.musicBtnClick()
    }
    
    @objc func clipMusicAction()
    {
        self.delegate?.cropMusicBtnClick()
    }
    
    @objc func deleteAction()
    {
        self.delegate?.deleteBtnClick()
    }
    
    @objc func finishAction()
    {
        self.delegate?.finishBtnClick()
    }
    
    @objc func rateChanged(_ rateView: VideoRateSelectView)
    {
        var rate:CGFloat = 1.0
        switch rateView.selectedSegmentIndex {
        case 0:
            rate = 0.5
        case 1:
            rate = 0.75
        case 2:
            rate = 1.0
        case 3:
            rate = 1.5
        case 4:
            rate = 2.0
        default:
            break
        }
        self.delegate?.didSelectRate(rate)
    }
    
}

extension VideoCameraView: VideoRecordButtonDelegate
{
    func startRecording() {
        self.progressView.showBlink = false
        self.progressView.videoCount += 1
        self.delegate?.recordBtnTouchesBegin()
    }
    
    func stopRecording() {
        self.progressView.showBlink = false
        self.delegate?.recordBtnTouchesEnd()
    }
}
