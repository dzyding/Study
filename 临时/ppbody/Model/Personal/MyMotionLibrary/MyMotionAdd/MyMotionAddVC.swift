//
//  MyMotionAddVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MyMotionAddVC: BaseVC {
    
    @IBOutlet weak var scvContent: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var motionView: MotionGroupView!

    lazy var motionAddView = MyMotionAddView.instanceFromNib()
    lazy var motionTrainKeyView = MyMotionTrainKeyView.instanceFromNib()
    lazy var motionAddVideo = MyMotionAddVideo.instanceFromNib()
    lazy var motionTypeView = MyMotionAddTypeView.initFromNib()
    
    var currentCode = "MG10000"
    
    var coverImage:UIImage?
    var videoImage:UIImage?

    var uploadLoadingView: UploadLoadingView?
    
    var motionCode: String?
    
    lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("完成", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.dataDic.isEmpty {
            self.title = "创建自定义动作"
        }else{
            self.title = "编辑自定义动作"
            setInfoData()
        }
        
        self.motionView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnCommit)
        
        motionTypeView.updateUI(4)
        stackView.addArrangedSubview(motionTypeView)
        stackView.addArrangedSubview(motionAddView)
        stackView.addArrangedSubview(motionTrainKeyView)
        stackView.addArrangedSubview(motionAddVideo)
    }
    
    func setInfoData() {
        motionCode = self.dataDic["code"] as? String
        currentCode = motionView.setCodeAndScrollToItem(motionCode!)
        motionAddView.setData(self.dataDic,type: 10)
        motionTrainKeyView.setData(self.dataDic)
        motionAddVideo.setData(self.dataDic)
    }
    
    @objc func btnClick() {
        guard let typeMsg = motionTypeView.getInfo(),
            let nameMsg = motionAddView.getInfo(10),
            let trainingCoreMsg = motionTrainKeyView.getInfo(),
            let video = motionAddVideo.getInfo()
        else {return}
        
        btnCommit.isEnabled = false
        dataDic = typeMsg
        // actionPoint name
        dataDic.merge(nameMsg, uniquingKeysWith: {$1})
        // trainingCore
        dataDic.merge(trainingCoreMsg, uniquingKeysWith: {$1})
        if motionCode != nil {
            //编辑状态
            dataDic["code"] = motionCode
        }

        dataDic["planCode"] = currentCode

        coverImage = video["cover"] as? UIImage

        let videopath = video["videoPath"] as? String

        if videopath == nil && coverImage == nil {
            dataDic["video"] = video["videoId"] as! String
            dataDic["cover"] = video["coverUrl"] as! String
            //只改了文字
            publicMotionToServer()
        }else if videopath == nil && coverImage != nil
        {
            //改了图片
            let imgArr = AliyunUpload.upload.uploadAliOSS([self.coverImage!], type: .Motion) { (progress) in

            }
            dataDic["video"] = video["videoId"] as! String
            dataDic["cover"] = imgArr[0]
            publicMotionToServer()
        }else{
            //改了视频
            videoImage = video["videoImg"] as? UIImage

            getStsToken(videopath!)

            uploadLoadingView = UploadLoadingView.showUploadLoadingView()
            uploadLoadingView?.max = 1.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getStsToken(_ path:String)
    {
        AliyunUpload.upload.getStsToken { (token) in
            let info = VodSVideoInfo()
            info.title = "PPbody：\(ToolClass.decryptUserId(DataManager.userAuth()) ?? -1)"
            info.desc = (self.dataDic["name"] as! String)
            info.cateId = 1000012726
//            info.desc = "创建动作"
            
            let coverPath = PPBodyPathManager.compositionRootDir() + "/cover.png"
            let data = self.videoImage!.pngData()
            try! data?.write(to: URL(fileURLWithPath: coverPath))
            
            VideoUploadService.service.uploadCallback = self
            VideoUploadService.service.uploadWithVideoPath(path,imagePath: coverPath
                , svideoInfo: info, accessKeyId: token.tAccessKey, accessKeySecret: token.tSecretKey, accessToken: token.tToken)
        }
    }

    
    func publicMotionToServer() {
        let request = BaseRequest()
        request.dic = dataDic as! [String:String]
        request.isUser = true
        request.url = BaseURL.EditMotion
        request.start { (data, error) in
            self.btnCommit.isEnabled = true
            self.uploadLoadingView?.removeFromSuperview()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("上传成功", .Success)
            NotificationCenter.default.post(name: Config.Notify_AddMotionData, object: nil)
            ToolClass.dispatchAfter(after: 1, handler: {
                self.navigationController?.popViewController(animated: true)
            })

        }
    }
}


extension MyMotionAddVC: MotionSelectDelegate,VODUploadSVideoClientDelegate {
    func selectMotion(_ code: String) {
        print(code)
        
        currentCode = code
    }
    
    func uploadSuccess(with result: VodSVideoUploadResult!) {
        print("上传成功", result.videoId ?? "-1")
        self.dataDic["video"] = result.videoId
        
        if coverImage == nil {
            publicMotionToServer()
        }else{
            let imgArr = AliyunUpload.upload.uploadAliOSS([self.coverImage!], type: .Motion) { (progress) in
                
            }
            self.dataDic["cover"] = imgArr[0]
            publicMotionToServer()
        }
    }

    
    func uploadFailed(withCode code: String!, message: String!) {
        print("上传失败", message ?? "-1")
        self.btnCommit.isEnabled = true

    }
    
    func uploadProgress(withUploadedSize uploadedSize: Int64, totalSize: Int64) {
        DispatchQueue.main.async {
            let progressIndex = self.uploadLoadingView?.setProgress(Double(uploadedSize)/Double(totalSize))
            print(progressIndex ?? 0)
        }

    }
    
    func uploadTokenExpired() {
        print("上传超时")
        self.btnCommit.isEnabled = true

    }
    
    func uploadRetry() {
        print(" 开始重试")
        self.btnCommit.isEnabled = false

    }
    
    func uploadRetryResume() {
        print("重试完成，继续上传")
        self.btnCommit.isEnabled = false

    }
}
