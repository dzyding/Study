//
//  MineTribeDetailEditVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol MineTribeDetailEditVCDelegate: NSObjectProtocol {
    func editTribeSuccess(_ data: [String:Any])
}

class MineTribeDetailEditVC: BaseVC {
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!    
    
    let noticeView = MineTribeEditNoticeView.instanceFromNib()
    let selectView = MineTribeEditSelectView.instanceFromNib()
    
    weak var delegate:MineTribeDetailEditVCDelegate?

    lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "部落详情编辑"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnCommit)
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = BackgroundColor
        stackView.addArrangedSubview(noticeView)
        stackView.addArrangedSubview(selectView)
        
        setData()
        // Do any additional setup after loading the view.
    }
    
    func setData() {
        noticeView.txtContent.text = dataDic["notice"] as? String
        selectView.txtName.text = dataDic["name"] as? String
        selectView.imgBG.setHeadImageUrl(dataDic["cover"] as! String)
        selectView.txtSign.text = dataDic["slogan"] as? String
        selectView.cityLB.text = dataDic["city"] as? String
    }
    
    @objc func btnClick() {
        if noticeView.getNotice() == nil || selectView.getSelectData() == nil {
            return
        }
        let postData = NSMutableDictionary.init(dictionary: selectView.getSelectData()!)
        postData.addEntries(from: noticeView.getNotice()!)
        postData["ctid"] = dataDic["ctid"]
        
        if selectView.tribeImg == nil {
            self.saveData(data: postData)
        }
        else {
            //修改了图片 上传oss
            var imgArr = [UIImage]()

            imgArr.append(selectView.tribeImg!)
            
            self.btnCommit.isEnabled = false
            var imgList = [String]()
            DispatchQueue.global().async {
                imgList = AliyunUpload.upload.uploadAliOSS(imgArr, type: .Topic) { (progress) in
                    DispatchQueue.main.async {
                        if progress == -1 {
                            //上传失败
                            ToolClass.showToast("网络异常，上传终止", .Failure)
                            self.btnCommit.isEnabled = true
                            return
                        }
                        
                        if imgList.count == 1 && postData["cover"] == nil {
                            postData["cover"] = imgList.last
                            self.saveData(data: postData)
                        }
                    }
                }
            }
        }
        
    }
    
    func saveData(data: NSMutableDictionary) {
        let request = BaseRequest()
        request.dic = data as! [String : String]
        request.url = BaseURL.EditTribe
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.btnCommit.isEnabled = true
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.delegate?.editTribeSuccess(data!)
            ToolClass.showToast("部落信息修改成功", .Success)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
