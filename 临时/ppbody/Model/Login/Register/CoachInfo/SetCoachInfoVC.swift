//
//  SetCoachInfoVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SetCoachInfoVC: BaseVC {

    @IBOutlet weak var scrollContent: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    lazy var headView: SetCoachView = {
        let head = SetCoachView.instanceFromNib()
        return head
    }()
    
    lazy var sepcialView: SetSpecialismView = {
        let sepcial = SetSpecialismView.instanceFromNib()
        return sepcial
    }()
    
    lazy var fitCertifyView: SetKeepFitCertifyView = {
        let fit = SetKeepFitCertifyView.instanceFromNib()
        return fit
    }()
    
    lazy var identifyView: SetIdentityCardView = {
        let identify = SetIdentityCardView.instanceFromNib()
        return identify
    }()
    
//     lazy var getWayView: SetGetWayView = {
//        let getWay = SetGetWayView.instanceFromNib()
//        return getWay
//    }()
    
    lazy var commitView: SetCommitView = {
        let view = SetCommitView.instanceFromNib()
        return view
    }()
    
    var uploadLoadingView: UploadLoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let childs = self.navigationController?.children
        
        //移除子试图
        for vc in childs!
        {
            if let register = vc as? RegisterVC
            {
                register.view.removeFromSuperview()
                register.removeFromParent()
            }
        }
        
        self.title = "基础信息"
        self.scrollContent.backgroundColor = BackgroundColor
        self.scrollContent.showsVerticalScrollIndicator = false
        self.scrollContent.showsHorizontalScrollIndicator = false
        
        stackView.addArrangedSubview(headView)
        stackView.addArrangedSubview(sepcialView)
        stackView.addArrangedSubview(fitCertifyView)
        stackView.addArrangedSubview(identifyView)
//        stackView.addArrangedSubview(getWayView)
        stackView.addArrangedSubview(commitView)
        
        commitView.btnCommit.addTarget(self, action: #selector(btnCommitClick(_:)), for: .touchUpInside)
        
    }
    
    func commitData() {
        if headView.getDicData() == nil || sepcialView.getDicData() == nil || fitCertifyView.getkeepFitCertifyPic() == nil || identifyView.getIDCardPic() == nil {
            return
        }
        self.dataDic = headView.getDicData()!
        self.dataDic["tags"] = sepcialView.getDicData()
        
        uploadLoadingView = UploadLoadingView.showUploadLoadingView()
        var imgArr = [UIImage]()
        
        for photo in identifyView.getIDCardPic()!
        {
            imgArr.append(photo)
        }
        
        let cerImg = fitCertifyView.getkeepFitCertifyPic()
        if cerImg != nil
        {
            imgArr.append(cerImg!)
        }
        
//        let inviteCode = getWayView.getInviteCode()
//        if !(inviteCode?.isEmpty)!
//        {
//            self.dataDic["inviteCode"] = inviteCode
//        }
        
        uploadLoadingView?.max = Double(imgArr.count)
        
        self.commitView.btnCommit.isEnabled = false
        
        var imgList = [String]()
        
        DispatchQueue.global().async {
            imgList = AliyunUpload.upload.uploadAliOSS(imgArr, type: .Coach) { (progress) in
                if progress == -1 {
                    //上传失败
                    DispatchQueue.main.sync {
                        //上传失败
                        ToolClass.showToast("网络异常，上传终止", .Failure)
                        self.uploadLoadingView?.removeFromSuperview()
                        self.commitView.btnCommit.isEnabled = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    let progressIndex = self.uploadLoadingView?.setProgress(progress)
                    if progressIndex == 1 && self.dataDic["idImgs"] == nil {
                        self.dataDic["idImgs"] = ToolClass.toJSONString(dict: [imgList.first!, imgList[1]])
                        self.dataDic["proCert"] = imgList.last
                        self.postCoachInfo()
                    }
                }
            }
        }
    }
    
    func postCoachInfo() {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String : String]
        request.isUser = true
        request.url = BaseURL.ApplyCoach
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.commitView.btnCommit.isEnabled = true
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.uploadLoadingView?.removeFromSuperview()
            ToolClass.showToast("申请信息提交成功", .Success)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                let vc = CoachCertifyStatusVC()
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    @objc func btnCommitClick(_ sender: UIButton) {
        self.commitData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
