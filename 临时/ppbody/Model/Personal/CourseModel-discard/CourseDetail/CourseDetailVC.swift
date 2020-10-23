//
//  CourseDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import ZKProgressHUD

class CourseDetailVC: BaseVC {
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var starview: NaRatingBar!
    @IBOutlet weak var backTV: IQTextView!
    
    @IBOutlet weak var addMotionBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var courseId:Int?
    var courseDic: [String:Any]?
    
    var uploadArr = [[String:Any]]()
    
    var motionIndex = 0
    
    var sourceIndex = -1
    
    var sourcePathArr = [Any]() //上传前的媒体属性
    var sourceArr = [Int]() //每一个动作的资源数量
    var sourceResult = [String]() //上传完成的结果
    
    var star:Float = 0
    
    var videoUrlCache = [String:String]()
    
    lazy var avPlayerView:AVPlayerView = {
        let pv = AVPlayerView()
        pv.delegate = self
        return pv
    }()
    
    lazy var playView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideAction)))
        return view
    }()
    
    lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.addTarget(self, action: #selector(saveAllMotionData), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "课程记录表"
        
        starview.callBack = {(count:Float) -> () in
            self.star = count
            print(self.star)
        }
        
        self.courseDetailAction()
        
        setPlayerContentView(self.playView)
    }
    
    @IBAction func addMotionToCourse(_ sender: UIButton) {
        
        let vc = PlanSelectMotionVC(.edit)
        vc.setData(self.dataArr)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func setPlayerContentView(_ parent: UIView){
        
        //设置播放视图
        parent.backgroundColor = UIColor.ColorHexWithAlpha("#000000", 0.5)
        
        if avPlayerView.superview != parent
        {
            avPlayerView.removeFromSuperview()
            parent.addSubview(avPlayerView)
            
            avPlayerView.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    @objc func hideAction()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.playView.alpha = 0
        }) { (finish) in
            if finish{
                self.avPlayerView.pause()
                self.playView.removeFromSuperview()
                
            }
        }
    }
    
    
    func courseDetailAction() {
        let request = BaseRequest()
        request.url = BaseURL.CourseDetail
        request.dic = ["courseId":"\(courseId!)"]
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.courseDic = data?["course"] as? [String:Any]
            let isEdit = self.courseDic!["isEdit"] as! Int
            
            self.dataArr = data?["list"] as! [[String:Any]]
            
            for dic in self.dataArr
            {
                let motionView = CourseDetailMotion.instanceFromNib()
                motionView.setData(dic, edit: (isEdit == 1 ? false : true))
                motionView.delegate = self
                motionView.courseDic = self.courseDic
                self.stackview.addArrangedSubview(motionView)
            }
            
            if isEdit == 1
            {
                //查看状态
                self.addMotionBtn.removeFromSuperview()
                self.bottomView.snp.makeConstraints({ (make) in
                    make.top.equalTo(self.stackview.snp.bottom).offset(16)
                })
                self.backTV.isEditable = false
                self.starview.isUserInteractionEnabled = false
                
                let star = (self.courseDic!["star"] as! NSNumber).floatValue
                self.starview.setStar(CGFloat(star))
                self.backTV.text = self.courseDic!["feedback"] as? String
            }else{
                
                if DataManager.isCoach()
                {
                    //教练可以编辑
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.btnCommit)
                }else{
                    self.addMotionBtn.removeFromSuperview()
                    self.bottomView.snp.makeConstraints({ (make) in
                        make.top.equalTo(self.stackview.snp.bottom).offset(16)
                    })
                    self.backTV.isEditable = false
                    self.starview.isUserInteractionEnabled = false
                    self.backTV.text = "教练还没给你任何反馈信息"
                }
                
                
            }
            
            self.scrollview.isHidden = false
        }
    }
    

    
    @objc func saveAllMotionData()
    {
        
        self.sourcePathArr.removeAll()
        self.sourceArr.removeAll()
        self.uploadArr.removeAll()
        
        for view in self.stackview.subviews
        {
            if let motionDetail = view as? CourseDetailMotion
            {
                let back = motionDetail.getMotionData()
                if let motionview = back as? CourseDetailMotion
                {
                    self.scrollview.setContentOffset(CGPoint(x: motionview.na_left, y: motionview.na_top), animated: true)
                    break
                }else{
                    var data = back as! [String:Any]
                    
                    var num = 0
                    //图片
                    if let imgs = data["imgs"] as? [UIImage]
                    {
                        num = imgs.count
                        
                        for img in imgs
                        {
                            self.sourcePathArr.append(img)
                        }
                    }
                    //视频
                    if let video = data["video"] as? [String:Any]
                    {
                        num = 1
                        self.sourcePathArr.append(video)
                    }
                    
                    data.removeValue(forKey: "imgs")
                    data.removeValue(forKey: "video")
                    
                    self.sourceArr.append(num)
                    self.uploadArr.append(data)
                }
            }
        }
        
        if self.star == 0
        {
            ToolClass.showToast("请给训练成果评星", .Failure)
            return
        }
        
        if self.backTV.text.isEmpty
        {
            ToolClass.showToast("请输入训练反馈", .Failure)
            return
        }
        ZKProgressHUD.showProgress(0)
        
        btnCommit.isEnabled = false
        
        checkNeddUpload()
    }
    
    //单个单个的上传资源
    func uploadMedia()
    {
        let object = self.sourcePathArr[self.sourceIndex]
        if let img = object as? UIImage
        {
            var progressIndex:Double = 0
            let imgList = AliyunUpload.upload.uploadAliOSS([img], type: .Course) { (progress) in
                
                DispatchQueue.main.async {
                    if progress == -1 {
                        //上传失败
                        ToolClass.showToast("网络异常，上传终止", .Failure)
                        self.uploadMedia()
                        return
                    }
                    progressIndex = progressIndex + progress
                    progressIndex = progressIndex > 1 ? 1 : progressIndex
                    ZKProgressHUD.showProgress((CGFloat(self.sourceIndex) + CGFloat(progressIndex))/CGFloat(self.sourcePathArr.count))
                    if progress == 1 {
                        //上传完成
                        print("图片上传完成",self.sourceIndex)
                        self.checkNeddUpload()
                    }
                }
            }
            self.sourceResult.append(imgList[0])
            
        }else if let videoDic = object as? [String:Any]{
            AliyunUpload.upload.getStsToken { (token) in
                let info = VodSVideoInfo()
                info.title = "PPbody：\(ToolClass.decryptUserId(DataManager.userAuth()) ?? -1)"
                info.desc = "课程内容"
                info.cateId = 1000012727
                
                let path = videoDic["path"] as! String
                let cover = videoDic["cover"] as! String
                
                VideoUploadService.service.uploadCallback = self
                VideoUploadService.service.uploadWithVideoPath(path,imagePath: cover, svideoInfo: info, accessKeyId: token.tAccessKey, accessKeySecret: token.tSecretKey, accessToken: token.tToken)
            }
        }
    }
    
    //检查是否上传完毕所有的资源
    func checkNeddUpload()
    {
        self.sourceIndex += 1
        
        if self.sourceIndex < self.sourcePathArr.count
        {
            self.uploadMedia()
        }else{
            ZKProgressHUD.dismiss()
            //上传完毕
            print("所有的资源上传完毕")
            //重新组装所有的动作数据媒体
            var hasRewrite = 0
            for i in 0..<self.sourceArr.count
            {
                let sourceNum = self.sourceArr[i]
                var motionData = self.uploadArr[i]
                if sourceNum > 0
                {
                    var mediaDic = [String]()
                    for index in hasRewrite..<(hasRewrite + sourceNum)
                    {
                        mediaDic.append(self.sourceResult[index])
                    }
                    hasRewrite += sourceNum
                    
                    motionData["media"] = mediaDic
                    
                    self.uploadArr[i] = motionData
                }
                
            }
            
            print(self.uploadArr)
            
            self.publicCourseDetail()
            
        }
    }
    
    deinit {
        self.avPlayerView.cancelLoading()
    }
    
    //上传 数据到服务器
    func publicCourseDetail()
    {
        let plan = ToolClass.toJSONString(dict: self.uploadArr)
        
        
        let request = BaseRequest()
        request.dic = ["courseId":"\(self.courseId!)","plan":plan,"feedback":self.backTV.text!,"star":"\(self.star)"]
        request.isUser = true
        request.url = BaseURL.AddCourseDetail
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.btnCommit.isEnabled = true
                return
            }
            
            ToolClass.showToast("课程记录上传成功", .Success)
            
            ToolClass.dispatchAfter(after: 1, handler: {
                 self.navigationController?.popViewController(animated: true)
            })
           
        }
    }
    
}

extension CourseDetailVC: CourseDetailMotionDelegate,PlanSelectMotionDelegate,VODUploadSVideoClientDelegate
{
    func uploadSuccess(with result: VodSVideoUploadResult!) {
        print("视频上传成功", result.videoId ?? "-1", self.sourceIndex)
        DispatchQueue.main.async {
            self.sourceResult.append(result.videoId)
            self.checkNeddUpload()
        }
    }
    
    func uploadFailed(withCode code: String!, message: String!) {
        self.uploadMedia()
    }
    
    func uploadProgress(withUploadedSize uploadedSize: Int64, totalSize: Int64) {
        DispatchQueue.main.async {
            print("视频上传",CGFloat(uploadedSize)/CGFloat(totalSize))
            ZKProgressHUD.showProgress((CGFloat(self.sourceIndex) + CGFloat(uploadedSize)/CGFloat(totalSize))/CGFloat(self.sourcePathArr.count))
        }
    }
    
    func uploadTokenExpired() {
        
    }
    
    func uploadRetry() {
        print("retry 上传视频")
    }
    
    func uploadRetryResume() {
        
    }
    
    //MARK: ------------PlanSelectMotionViewDelegate
    func returnMotions(_ data: [[String : Any]]) {
        
    }
    /*
    func returnMotionPlan(_ data: [[String : Any]]) {
        var detailMotionViews = self.stackview.arrangedSubviews as! [CourseDetailMotion]
        for dic in data
        {
            let motion = dic["motion"] as! [String:Any]
            let code = motion["code"] as! String
            
            var hasExit = false
            
            for i in 0..<detailMotionViews.count
            {
                let cell = detailMotionViews[i]
                if cell.motionCode == code
                {
                    cell.refreshTarget(dic)
                    detailMotionViews.remove(at: i)
                    hasExit = true
                    break
                }
            }
            
            if !hasExit
            {
                let isEdit = self.courseDic!["isEdit"] as! Int
                
                let motionView = CourseDetailMotion.instanceFromNib()
                motionView.setData(dic, edit: (isEdit == 1 ? false : true))
                motionView.delegate = self
                motionView.courseDic = self.courseDic
                self.stackview.addArrangedSubview(motionView)
            }
        }
        
    }
     */
    
    func deleteCourseDetailMotion(_ cell: CourseDetailMotion) {
        
        UIView.animate(withDuration: 0.25, animations: {
            cell.isHidden = true
            cell.alpha = 0
            self.stackview.layoutIfNeeded()
        }) { (finish) in
            self.stackview.removeArrangedSubview(cell)
            cell.removeFromSuperview()
            
            for i in 0..<self.dataArr.count
            {
                let dic = self.dataArr[i]
                let motion = dic["motion"] as! [String:Any]
                let code = motion["code"] as! String
                if cell.motionCode == code
                {
                    self.dataArr.remove(at: i)
                    break
                }
            }
        }
    }
    
    func playVideo(_ frame: CGRect, path: String?, video: String?) {
        self.navigationController?.view.addSubview(self.playView)
        self.playView.frame = frame
        if path != nil
        {
            if path!.contains("/")
            {
                self.avPlayerView.setPlayerSourceUrl(url: path!)
            }else{
                AlivideoPlayCache.cache.getUrlFromVid(path!) { [weak self](vid,url) in
                    if vid == path!
                    {
                        self?.avPlayerView.setPlayerSourceUrl(url: url)
                    }
                }
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.playView.frame = ScreenBounds
            self.playView.alpha = 1
        }
        
        ZKProgressHUD.show()
    }
}

extension CourseDetailVC: AVPlayerUpdateDelegate
{
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            self.avPlayerView.play()
            ZKProgressHUD.dismiss()
        case .failed:
            ZKProgressHUD.dismiss()
        @unknown default:
            break
        }
    }
}


