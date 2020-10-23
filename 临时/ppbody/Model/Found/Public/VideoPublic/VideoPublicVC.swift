//
//  VideoPublicVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class VideoPublicVC: BaseVC {

    @IBOutlet weak var textview: IQTextView!
    @IBOutlet weak var textviewHeight: NSLayoutConstraint!

    @IBOutlet weak var coverIV: UIImageView!
    
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLB: UILabel!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var cityLB: UILabel!
    
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var showLB: UILabel!
    
    @IBOutlet weak var redirectView: UIView!
    @IBOutlet weak var redirectStackview: UIStackView!
    
    var publicBtn:UIButton!

    var dataTopic = ["display":"30"] //上传信息 初始值是公开的

    var outpath = ""
    var musicId:Int?
    
    var player: AVPlayer?
    var timer: CMTime?
    var coverPath = ""
    
    var remindUserList = [StudentUserModel]()

    
    @IBOutlet weak var playView: UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发布视频"
        
        addNavigationBar()

        topicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topicAction)))
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationAction)))
        showView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAction)))
        redirectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(remindAction)))
        
        self.coverIV.image = ToolClass.getCoverFromVideo(self.outpath)
        
        coverPath = PPBodyPathManager.compositionRootDir() + "/cover.png"
        let data = self.coverIV.image!.pngData()
        try! data?.write(to: URL(fileURLWithPath: coverPath))
        
        self.coverIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playAction)))
        self.playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideAction)))
        
        let videoURL = URL(fileURLWithPath: self.outpath)

        player = AVPlayer(url: videoURL)
        //设置大小和位置（全屏）
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame =  ScreenBounds
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspect
        //添加到界面上
        self.playView.layer.addSublayer(playerLayer)
  
        if TopicTag != nil
        {
            self.tagView.isHidden = false
            self.tagLB.text = "#" + TopicTag!
            dataTopic["tag"] = TopicTag!
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.playView.frame = self.coverIV.frame
    }
    
    
    @objc func playbackFinished(_ notify: Notification)
    {
        if !playView.isHidden
        {
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
    
    @objc func appBecomeActive(_ notify: Notification)
    {
        if !playView.isHidden
        {
            if self.timer != nil
            {
                self.player?.seek(to: self.timer!, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (finish) in
                    if finish
                    {
                        self.player?.play()
                    }
                })
            }
        }
    }
    @objc func appWillResignActive(_ notify: Notification)
    {
        
        self.player?.pause()
        self.timer = self.player?.currentTime()
        
    }
    
    func addNavigationBar()
    {
        publicBtn = UIButton(type: .custom)
        publicBtn.setTitle("发表", for: .normal)
        publicBtn.backgroundColor = YellowMainColor
        publicBtn.setTitleColor(BackgroundColor, for: .normal)
        publicBtn.frame = CGRect(x: 0, y: 0, width: 56, height: 24)
        publicBtn.layer.cornerRadius = 4
        publicBtn.titleLabel?.font = ToolClass.CustomFont(13)
        publicBtn.addTarget(self, action: #selector(publicAction), for: .touchUpInside)
        publicBtn.enableInterval = true
        
        let rightBar = UIBarButtonItem(customView: publicBtn)
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    @objc func playAction()
    {
        self.playView.isHidden = false
        player?.seek(to: CMTime.zero)
        player?.play()
        
        UIView.animate(withDuration: 0.2) {
            self.playView.frame = ScreenBounds
        }
    }
    
    @objc func hideAction()
    {
        self.playView.isHidden = true
        self.player?.pause()
        
        UIView.animate(withDuration: 0.2) {
            self.playView.frame = self.coverIV.frame
        }
    }
    
    @objc func topicAction()
    {
        let vc = TopicTagVC(.select)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func locationAction()
    {
        let vc = SearchAddressVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showAction()
    {
        let vc = TopicAuthVC()
        if dataTopic["display"] != nil {
            vc.display = dataTopic["display"]
        }
        if dataTopic["tribeIds"] != nil
        {
            vc.tribeIds = ToolClass.getArrayFromJSONString(jsonString: dataTopic["tribeIds"]!) as? [String]
        }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func remindAction()
    {
        let vc = TopicAttentionVC()
        vc.originUserList = remindUserList
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //增加用户提醒
    func setRemindView()
    {
        for view in self.redirectStackview.arrangedSubviews
        {
            self.redirectStackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for user in self.remindUserList
        {
            let iv = UIImageView()
            iv.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            iv.layer.masksToBounds = true
            iv.layer.cornerRadius = 15
            iv.setHeadImageUrl(user.head!)
            iv.snp.makeConstraints { (make) in
                make.width.height.equalTo(30)
            }
            self.redirectStackview.addArrangedSubview(iv)
        }
    }
    
    //点击发布按钮
    @objc func publicAction()
    {
        if self.textview.text.isEmpty
        {
            ToolClass.showToast("大人，还是随便写写吧", .Failure)
            self.textview.becomeFirstResponder()
            return
        }
        

        self.dataTopic["content"] = self.textview.text

        
        if self.musicId != nil
        {
            self.dataTopic["musicId"] = "\(self.musicId!)"
        }
        
        if self.remindUserList.count != 0
        {
            self.dataTopic["remind"] = getJsonRemind()
        }
        
        self.publicBtn.isEnabled = false
        
        let loading = VideoUploadLoadingView(frame: CGRect(x: 16, y: SafeTop + 16, width: 50, height: 50))
        loading.videoPath = self.outpath
        loading.imagePath = self.coverPath
        loading.dataTopic = self.dataTopic
        
        loading.getStsToken()
        UIApplication.shared.keyWindow?.addSubview(loading)
        
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //获取提醒人的json字符串
    func getJsonRemind() -> String
    {
        var remindArr = [[String:Any]]()
        for model in self.remindUserList
        {
            var dic = [String:Any]()
            dic["uid"] = model.uid!
            dic["nickname"] = model.name!
            dic["head"] = model.head
            remindArr.append(dic)
        }
        
        return ToolClass.toJSONString(dict:remindArr)
    }
    
}

private typealias PrivateAPI = VideoPublicVC
extension PrivateAPI: SelectTopicTagDelegate,SelectAddressDelegate,SelectTopicAuthDelegate,TopicAttentionSelectDelegate {
    
    func selectAuth(_ auth: [String : String]) {
        let display = auth["display"]
        self.showLB.text = display == "30" ? "公开" : "仅部落可见"
        
        dataTopic["display"] = display
        if display == "20"
        {
            dataTopic["tribeIds"] = auth["tribeIds"]
        }else{
            dataTopic.removeValue(forKey: "tribeIds")
        }
    }
    
    func selectTag(_ name: String) {
        if name == ""
        {
            self.tagView.isHidden = true
            dataTopic.removeValue(forKey: "tag")
        }else{
            self.tagView.isHidden = false
            self.tagLB.text = "#" + name
            
            dataTopic["tag"] = name
            
        }
    }
    
    func selectAddress(_ address: [String : String]) {
        if address.isEmpty
        {
            self.cityLB.text = ""
            
            dataTopic.removeValue(forKey: "address")
            dataTopic.removeValue(forKey: "latitude")
            dataTopic.removeValue(forKey: "longitude")
        }else{
            self.cityLB.text = address["name"]
            dataTopic["address"] = address["name"]
            dataTopic["latitude"] = address["latitude"]
            dataTopic["longitude"] = address["longitude"]
        }
        
    }
    
    func selectRemindUser(_ userList: [StudentUserModel]) {
        self.remindUserList = userList
        self.setRemindView()
    }

}

