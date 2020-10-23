//
//  ImageVerifyVC.swift
//  YJF
//
//  Created by edz on 2019/6/4.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ImageVerifyVC: BaseVC {
    
    private let imgSize = PublicConfig.sysConfigIntValue(.imageSize) ?? 200
    
    private let arrKeys = ["propertyCert", "userImgs"]
    
    private let imgKeys = ["cover", "ownerIdN", "ownerIdP", "auth", "agentIdP", "agentIdN"]
    
    private let house: [String : Any]
    
    private var code: String?
    
    @IBOutlet weak var codeIV: UIImageView!
    
    @IBOutlet weak var codeTF: UITextField!
    // 需要上传的数量
    private var needCount: Int = 0
    // 当前上传的张数
    private var currentCount: Int = 0
    // 上传进度
    private weak var msgView: CustomWaitView?
    // 锁
    private var lock = NSLock()
    
    init(_ house: [String : Any]) {
        self.house = house
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "图片验证"
        imageCodeFunc()
        initTapAction()
        getNeedUpdateCount()
    }
    
    //    MARK: - 设置点击功能
    private func initTapAction() {
        codeIV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        codeIV.addGestureRecognizer(tap)
    }
    
    @objc func tapAction() {
        imageCodeFunc()
    }
    
    //MARK: -  更新图片
    private func imageCodeFunc() {
        imageCodeApi { [weak self] (data) in
            self?.initImage(data)
        }
    }
    
    //    MARK: - 计算总共需要上传的图片
    private func getNeedUpdateCount() {
        var count = 0
        arrKeys.forEach { (key) in
            if let imgs = house[key] as? [(UIImage?, String?)] {
                let imgCount = imgs.filter({$0.0 != nil}).count
                count += imgCount
            }
        }
        imgKeys.forEach { (key) in
            if let img = house[key] as? (UIImage?, String?),
                img.0 != nil
            {
                count += 1
            }
        }
        needCount = count
    }
    
    //    MARK: - 更新上传图片数量
    private func updateUploadNum() {
        lock.lock()
        currentCount += 1
        msgView?.updateUI(currentCount, total: needCount)
        lock.unlock()
    }
    
    //    MARK: - 上传完成
    private func uploadComplete(_ data: [String : Any]?) {
        NotificationCenter.default.post(
            name: PublicConfig.Notice_AddHouseSuccess,
            object: nil,
            userInfo: ["result" : data != nil]
        )
        msgView?.end()
        popView.hide()
        PublicFunc.checkPayOrTrain(.sellDeposit) { [weak self] (result, _) in
            if result {
                self?.dzy_popRoot()
            }else {
                let vc = PaySellDepositVC(
                    .jump(PublicConfig.Pay_Notice_Deposit)
                )
                self?.dzy_push(vc)
            }
        }
    }

    //    MARK: - 初始化验证图片
    private func initImage(_ data: [String : Any]?) {
        code = data?.stringValue("code")
        if let imageStr = data?.stringValue("image")?
            .replacingOccurrences(of: "data:image/jpeg;base64,", with: ""),
            let data = Data(base64Encoded: imageStr, options: .ignoreUnknownCharacters)
        {
            let image = UIImage(data: data)
            codeIV.image = image
        }
    }

    //    MARK: - 确认按钮
    @IBAction func sureAction(_ sender: DzySafeBtn) {
        view.endEditing(true)
        guard
            let codeStr = codeTF.text,
            codeStr.count > 0,
            codeStr.lowercased() == code?.lowercased()
        else {
            showMessage("请输入正确的验证码")
            return
        }
        changeImageToImageUrl()
    }
    
    private func changeImageToImageUrl() {
        var dic = house
        DispatchQueue.global().async {
            var count = 0
            self.arrKeys.forEach { (key) in
                self.changeArrImgs(dic, key: key) { (urls) in
                    if urls.count > 0 {
                        dic.updateValue(
                            ToolClass.toJSONString(dict: urls),
                            forKey: key)
                    }else {
                        dic.updateValue("[]", forKey: key)
                    }
                    count += 1
                    if count == self.arrKeys.count {
                        self.changeOthersImg(dic)
                    }
                }
            }
        }
        popView.show()
        msgView?.begin()
        msgView?.updateUI(currentCount, total: needCount)
    }
    
    // 先把 imgs 数组处理掉
    private func changeArrImgs(_ dic: [String : Any],
                               key: String,
                               complete: @escaping ([String]) -> ())
    {
        let group = DispatchGroup()
        var imgUrls: [String] = []
        if let imgs = dic[key] as? [(UIImage?, String?)] {
            imgs.forEach { (image) in
                if let img = image.0 {
                    group.enter()
                    let data = ToolClass
                        .resetSizeOfImageData(source_image: img,
                                              maxSize: imgSize)
                    PublicFunc.bgUploadApi(data, success: { (imgUrl) in
                        if let url = imgUrl {
                            imgUrls.append(url)
                        }
                        group.leave()
                        DispatchQueue.main.async {
                            self.updateUploadNum()
                        }
                    })
                }else {
                    imgUrls.append(image.1 ?? "")
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            complete(imgUrls)
        }
    }
    
    // 处理其他的
    private func changeOthersImg(_ dic: [String : Any]) {
        var result = dic
        let group = DispatchGroup()
    
        func updateImageToUrl(_ key: String) {
            if let image = dic[key] as? (UIImage?, String?) {
                if let img = image.0 {
                    group.enter()
                    let data = ToolClass.resetSizeOfImageData(
                        source_image: img, maxSize: imgSize
                    )
                    PublicFunc.bgUploadApi(data, success: { (imgUrl) in
                        let url = imgUrl ?? ""
                        result.updateValue(url, forKey: key)
                        group.leave()
                        DispatchQueue.main.async {
                            self.updateUploadNum()
                        }
                    })
                }else {
                    let url = image.1 ?? ""
                    result.updateValue(url, forKey: key)
                }
            }
        }
        
        imgKeys.forEach { (key) in
            updateImageToUrl(key)
        }
        group.notify(queue: DispatchQueue.main) {
            self.editHouseApi(result)
        }
    }
    
    // 获取验证码图片
    private func imageCodeApi(_ success: @escaping ([String : Any]?) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.imageCode
        request.dzy_start { (data, _) in
            success(data)
        }
    }
    
    // 上传房源
    private func editHouseApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.editHouse
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            DataManager.saveStaffMsg(nil)
            self.uploadComplete(data)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var popView: DzyPopView = {
        let msgView = CustomWaitView
            .initFromNib(CustomWaitView.self)
        let view = DzyPopView(.POP_center_above, viewBlock: msgView)
        self.msgView = msgView
        view.isBgCanClick = false
        return view
    }()
}
