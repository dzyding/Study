//
//  MotionDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MotionDetailVC: BaseVC {
    
    @IBOutlet weak var videoH: NSLayoutConstraint!
    
    var isEdit = false
    // 播放视图
    @IBOutlet weak var videoView: UIView!
    // 进度条界面
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var actionLB: UILabel!
    @IBOutlet weak var coreLB: UILabel!
    
    var originVideoPlayFrame:CGRect?
 
    // 进度条
    var timer: Timer?
    
    var planCode = ""
    
    lazy var playerView:AVPlayerView = {[weak self] in
        let pv = AVPlayerView()
        pv.delegate = self
        return pv
    }()
    
    // 进度条
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = YellowMainColor
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "slider_image"), for: .normal)
        slider.addTarget(self, action: #selector(progressTouchBegin(_:)), for: .touchDown)
        slider.addTarget(self,
                         action: #selector(progressTouchEnd(_:)),
                         for: [.touchCancel, .touchUpOutside, .touchUpInside])
        return slider
    }()
    
    // 开始，暂停
    lazy var playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "video_start"), for: .normal)
        btn.setImage(UIImage(named: "video_pause"), for: .selected)
        btn.addTarget(self, action: #selector(pauseAndBeginAction(_:)), for: .touchUpInside)
        btn.isSelected = true
        return btn
    }()
    
    // 全屏
    lazy var fullBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "video_full"), for: .normal)
        btn.addTarget(self, action: #selector(fullPlay), for: .touchUpInside)
        return btn
    }()
    
    
    @IBAction func trainingAction(_ sender: UIButton) {
        
        if planCode == "MG10006"
        {
            //有氧训练
            let vc = MotionTrainingCardioVC()
            vc.dataDic = self.dataDic
            vc.planCode = planCode
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }

        let vc = MotionTrainingVC()
        vc.dataDic = self.dataDic
        vc.planCode = planCode
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myshowAction(_ sender: UIButton) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        playerView.cancelLoading()
    }
    override func viewWillAppear(_ animated: Bool) {
//        playerView.play()
    }
    
    deinit {
        playerView.cancelLoading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.dataDic["name"] as? String
        
        //编辑状态
        if isEdit
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "mind_nav_icon_edit"), style: .plain, target: self, action: #selector(editMotion))
        }

        setPlayerContentView()
        setProgressAndBtn()

        let videos = self.dataDic["video"] as? String

        if videos != nil && !((videos?.isEmpty)!) {
            let videoArr = videos!.components(separatedBy: "|")
            var video = ""

            if videoArr.count > 1
            {
                let user = DataManager.userInfo()
                let sex = user!["sex"] as! Int

                video = sex == 10 ? videoArr[0] : videoArr[1]
            }else{
                video = videos!
            }
            AlivideoPlayCache.cache.getUrlFromVid(video) { [weak self](vid,url) in
                self?.playUrl = url
                if video == vid {
                    self?.playerView.setPlayerSourceUrl(url: url)
                }
            }
        }

        actionLB.attributedText = ToolClass
            .rowSpaceText(self.dataDic["actionPoint"] as! String, system: 13)
        coreLB.attributedText = ToolClass
            .rowSpaceText(self.dataDic["trainingCore"] as! String, system: 13)
    }
    
    @objc func editMotion() {
        let vc = MyMotionAddVC()
        vc.dataDic = self.dataDic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setPlayerContentView(){
        //设置播放视图
        playerView.backgroundColor = BackgroundColor
        videoView.addSubview(playerView)
        videoView.isHidden = true
    }

    
    //    MARK: - 设置进度条
    func setProgressAndBtn() {
        progressView.addSubview(slider)
        progressView.addSubview(playBtn)
        progressView.addSubview(fullBtn)
        
        playBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.left.bottom.equalToSuperview()
        }
        
        fullBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.right.bottom.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.left.equalTo(playBtn.snp.right).offset(5)
            make.right.equalTo(fullBtn.snp.left).offset(-5)
            make.height.equalTo(10)
            make.centerY.equalTo(playBtn)
        }
    }
    
    //全屏
    @objc func fullPlay() {
        let h: CGFloat = videoH.constant == 200 ?
            (ScreenHeight - 32.0 - (isiPhoneXScreen() ? 88 : 64)) : 200.0
        videoH.constant = h
        self.view.layoutIfNeeded()
        if playerView.na_height > originVideoPlayFrame!.size.height
        {
            playerView.frame = originVideoPlayFrame!
        }else{
            let scaleWH = (playerView.videoSize?.height)! / (playerView.videoSize?.width)!
//            if aliyunVodPlayer.videoRotation > 0
//            {
//                //说明旋转 90°
//                scaleWH = CGFloat(self.videoWidth) / CGFloat(self.videoHeight)
//            }
            
            playerView.na_size = CGSize(width:ScreenWidth, height: scaleWH * ScreenWidth)
            playerView.center = videoView.center
        }
        
    }
    
    @objc func pauseAndBeginAction(_ sender: UIButton) {
        sender.isSelected ? { [weak self] in
            self?.playerView.pause()
            }() : { [weak self] in
                self?.playerView.play()
            }()
        sender.isSelected = !sender.isSelected
    }
    
    @objc func progressTouchBegin(_ sender: UISlider) {
    }
    
    // 拖动结束  (不要写到 valueChange 里面，性能不好)
    @objc func progressTouchEnd(_ sender: UISlider) {
        let percent = sender.value

        playerView.seekTo(percent)
    }

//    FIXME: - 临时的
    private var playUrl: String?
    // 连接
    @IBAction func urlAction(_ sender: Any) {
        playUrl.flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }
    
    // 动作要点
    @IBAction func pointAction(_ sender: Any) {
        dataDic.stringValue("actionPoint").flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }
    
    // 训练重点
    @IBAction func coreAction(_ sender: Any) {
        dataDic.stringValue("trainingCore").flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }
    
}

extension MotionDetailVC:AVPlayerUpdateDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        self.slider.setValue(Float(current / total), animated: true)
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            videoView.isHidden = false
            playerView.getVideoSize {[weak self]() in
                self?.playerView.na_size = CGSize(width: (self?.playerView.videoSize?.width)! * (self?.videoView.na_height)! / (self?.playerView.videoSize?.height)!, height: (self?.videoView.na_height)!)
                self?.playerView.center = (self?.videoView.center)!
                
                self?.originVideoPlayFrame = self?.playerView.frame
            }
     
            self.playerView.play()
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let topicCell = cell as! TopicCell
        topicCell.setData(dataArr[indexPath.row])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicCell", for: indexPath) as!TopicCell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
    }
    
    
    func collectionView(_ collectonView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 3*16)/2
        return CGSize(width: width, height: width+76)
    }
    
}




