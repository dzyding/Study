//
//  VideoUploadSuspendView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import LKAWaveCircleProgressBar

class VideoUploadLoadingView: UIView {
    
    var wcView:LKAWaveCircleProgressBar?
    var text: UILabel?
    
    var videoPath = ""
    var imagePath = ""
    
    var dataTopic:[String:String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubview()
    }
    
    func setupSubview()
    {
        let wcView = LKAWaveCircleProgressBar(frame: self.bounds)
        wcView.center = self.center
        wcView.startWaveRollingAnimation()
        wcView.borderColor = YellowMainColor
        wcView.progress = 0
        wcView.progressAnimationDuration = 0.5
        wcView.progressTintColor = YellowMainColor.withAlphaComponent(0.5)
        self.addSubview(wcView)
        self.wcView = wcView
        
        let tx = UILabel()
        tx.textColor = UIColor.white
        tx.font = ToolClass.CustomBoldFont(10)
        tx.text = "0%"
        tx.sizeToFit()
        self.addSubview(tx)
        tx.center = wcView.center
   
        self.text = tx
    }
    
    func getStsToken()
    {
        AliyunUpload.upload.getStsToken { (token) in
            let info = VodSVideoInfo()
            info.title = "PPbody：\(ToolClass.decryptUserId(DataManager.userAuth()) ?? -1)"
            if let tag = self.dataTopic["tag"]
            {
//                info.tags = tag
                info.desc = tag

            }
            info.cateId = 1000010729
            
            VideoUploadService.service.uploadCallback = self
            VideoUploadService.service.uploadWithVideoPath(self.videoPath,imagePath: self.imagePath, svideoInfo: info, accessKeyId: token.tAccessKey, accessKeySecret: token.tSecretKey, accessToken: token.tToken)
        }
    }
    
    //发布话题到服务器
    func publicTopicToServer()
    {
        let request = BaseRequest()
        request.dic = dataTopic
        request.isUser = true
        request.url = BaseURL.PublicTopic
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            NotificationCenter.default.post(name: Config.Notify_PublicTopic, object: nil)

            self.removeFromSuperview()
        }
    }
}

extension VideoUploadLoadingView:VODUploadSVideoClientDelegate
{
    
    func uploadSuccess(with result: VodSVideoUploadResult!) {
        print("上传成功", result.videoId ?? "-1")
        dataTopic["video"] = result.videoId
        publicTopicToServer()
    }
    
    func uploadFailed(withCode code: String!, message: String!) {
        print("上传失败", message ?? "-1")
        
    }
    
    func uploadProgress(withUploadedSize uploadedSize: Int64, totalSize: Int64) {
        DispatchQueue.main.async {
            self.wcView?.setProgress( Float(uploadedSize)/Float(totalSize), animated: true)
            let progress = String.init(format: "%.0f",  Float(uploadedSize) * 100/Float(totalSize))
            self.text?.text = progress + "%"
            self.text?.sizeToFit()
        }
    }
    
    func uploadTokenExpired() {
        print("上传超时")
    }
    
    func uploadRetry() {
        print(" 开始重试")
    }
    
    func uploadRetryResume() {
        print("重试完成，继续上传")
    }
    
    
}
