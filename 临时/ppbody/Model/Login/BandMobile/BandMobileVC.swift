//
//  BandMobileVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import HBDNavigationBar

class BandMobileVC: BaseVC {
    
    private let maxNum = 5
    
    @IBOutlet weak var progressView: RegisterProgressView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    let registerMobileView = RegisterMobileView.instanceFromNib()
    let registerVercodeView = RegisterVercodeView.instanceFromNib()
    let registerSexView = RegisterSexView.instanceFromNib()
    let registerHeightweightView = RegisterHeightweightView.instanceFromNib()
    let registerAgeView = RegisterAgeView.instanceFromNib()
    
    
    var index = 1
    
    //注册的验证码
    var time : Timer?
    var codeSeconds = 60
    
    lazy var actionBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth, y: ScreenHeight, width: 114, height: 40)
        btn.layer.cornerRadius = 20
        btn.setTitle("获取验证码", for: .normal)
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(UIColor.ColorHex("#000000"), for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn.isHidden = true
        self.view.addSubview(btn)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.rate = CGFloat(index)/CGFloat(maxNum)
        setupSubviews()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func setupSubviews()
    {
        registerMobileView.titleLB.text = "绑定手机号"
        
        self.stackview.addArrangedSubview(registerMobileView)
        self.stackview.addArrangedSubview(registerVercodeView)
        self.stackview.addArrangedSubview(registerSexView)
        self.stackview.addArrangedSubview(registerHeightweightView)
        self.stackview.addArrangedSubview(registerAgeView)
        
        registerMobileView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollview.snp.width)
            make.height.equalTo(self.scrollview.snp.height)
        }
        
        registerVercodeView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollview.snp.width)
            make.height.equalTo(self.scrollview.snp.height)
        }
        
        registerVercodeView.editComplete = { (code) in
            
            self.loadVerifyApi(self.dataDic["mobile"] as! String, code: code)
        }
    
        
        registerSexView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollview.snp.width)
            make.height.equalTo(self.scrollview.snp.height)
        }
        
        registerSexView.nextAction = { (sex) in
            self.dataDic["sex"] = sex
            self.setProgress(4)
        }
        
        registerHeightweightView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollview.snp.width)
            make.height.equalTo(self.scrollview.snp.height)
        }
        
        registerHeightweightView.nextAction = {() in
            let result = self.registerHeightweightView.getHeightWeight()
            self.dataDic["height"] = result.height
            self.dataDic["weight"] = result.weight
            self.setProgress(5)
        }
        
        registerAgeView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollview.snp.width)
            make.height.equalTo(self.scrollview.snp.height)
        }
        
        registerAgeView.registAction = {() in
            let age = self.registerAgeView.getAge()
            self.dataDic["age"] = age
            self.bandOtherApi(self.dataDic)
        }
    }
    
    private func startTime() {
        if self.time != nil {
            self.time?.invalidate()
            self.time = nil
            self.actionBtn.isUserInteractionEnabled = true
        }
        self.codeSeconds = 60
        self.time = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(codeTimer), userInfo: nil, repeats: true)
        self.time?.fire()
        self.actionBtn.isUserInteractionEnabled = false
        self.actionBtn.setTitleColor(UIColor.ColorHex("#ffffff"), for: .normal)
        self.actionBtn.backgroundColor = Text1Color
    }
    
    @objc func codeTimer() {
        self.codeSeconds = self.codeSeconds - 1
        if self.codeSeconds >= 0 {
            self.actionBtn.setTitle("重新发送(\(self.codeSeconds)s)", for: .normal)
        }
        else {
            self.time?.invalidate()
            self.time = nil
            self.actionBtn.setTitle("获取验证码", for: .normal)
            self.actionBtn.isUserInteractionEnabled = true
            self.actionBtn.setTitleColor(BackgroundColor, for: .normal)
            self.actionBtn.backgroundColor = YellowMainColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    @objc func btnAction(_ sender: UIButton)
    {
        switch index {
        case 1:
            let mobileDic = registerMobileView.getMobileDic()
            if mobileDic != nil
            {
                for (key,value) in mobileDic!
                {
                    self.dataDic[key] = value
                }
                self.setProgress(2)
            }
            break
            
        case 2:
            self.loadSendCodeApi(self.dataDic["mobile"] as! String)
            break
            
        default:
            break
        }
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let deltaY = keyBoardBounds.size.height
        
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.actionBtn.frame = CGRect(x: ScreenWidth - 16 - self.actionBtn.na_width, y: ScreenHeight-deltaY-50, width: self.actionBtn.na_width, height: self.actionBtn.na_height)
        }
        
        var delay = 0.0
        if self.actionBtn.isHidden
        {
            self.actionBtn.isHidden = false
            self.actionBtn.frame = CGRect(x: ScreenWidth, y: ScreenHeight-deltaY-50, width: self.actionBtn.na_width, height: self.actionBtn.na_height)
            delay = duration
        }
        
        
        UIView.animate(withDuration: 0.25, delay: delay, options: .curveLinear, animations: animations, completion: nil)
        
    }
    
    @objc func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.actionBtn.isHidden = true
        self.actionBtn.frame = CGRect(x: ScreenWidth, y: self.actionBtn.na_top, width: self.actionBtn.na_width, height: self.actionBtn.na_height)
        let animations:(() -> Void) = {
            //键盘的偏移量
            
        }
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations) { (finish) in
                if finish
                {
                }
            }
        }else{
            animations()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //设置注册进度
    func setProgress(_ progress: Int)
    {
        self.index = progress
        self.progressView.rate = CGFloat(index)/CGFloat(maxNum)
        self.scrollview.scrollRectToVisible(CGRect(x: self.scrollview.na_width * CGFloat(self.index - 1), y: 0, width: self.scrollview.na_width, height: self.scrollview.na_height), animated: true)
        
        switch progress {
        case 2:
            let mobile = self.dataDic["mobile"] as! String
            self.loadSendCodeApi(mobile)
            registerVercodeView.setMobile(mobile)
            break
        default:
            break
        }
    }
    
    /** ================== API ================= **/

    
    func loadSendCodeApi(_ mobile: String) {
        let request = BaseRequest()
        request.dic = ["mobile":mobile,"type":"40", "valid":"300"]
        request.url = BaseURL.CommonSendCode
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.startTime()
            
        }
    }
    
    func loadVerifyApi(_ mobile: String, code: String) {
        
        var dic = self.dataDic
        dic["mobile"] = mobile
        dic["verCode"] = code
        
        let request = BaseRequest()
        request.dic = dic as! [String : String]
        request.url = BaseURL.VerifyRegisterCode
        request.start { (data, error) in
            self.dismissLoading()
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            if self.time != nil {
                self.time?.invalidate()
                self.time = nil
                self.actionBtn.isUserInteractionEnabled = true
            }
            
            let user = data!["user"] as? [String:Any]
            
            if user != nil
            {
                DataManager.saveUserInfo(user!)
                
                ToolClass.dispatchAfter(after: 1, handler: {
                    
                    let vc = PPBodyMainVC()
                    let nav = HBDNavigationController(rootViewController: vc)
                    nav.pphero.isEnabled = true
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                })
            }else{
                self.setProgress(3)
            }
        }
    }
    
    //第三方账户绑定
    func bandOtherApi(_ dic: [String: Any]) {
        registerAgeView.isEnable(false)
        let request = BaseRequest()
        request.dic = dic as! [String : String]
        request.url = BaseURL.BandOther
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                self.registerAgeView.isEnable(true)
                
                return
            }
            ToolClass.showToast("绑定成功", .Success)
            DataManager.saveFirstRegister(1)
            let user = data!["user"] as! [String:Any]
            DataManager.saveUserInfo(user)
            let review = user["review"] as! Int
            if review == 5 {
                isFistCoachTip = true
            }
            ToolClass.dispatchAfter(after: 1, handler: {
                let vc = PPBodyMainVC()
                let nav = HBDNavigationController(rootViewController: vc)
                nav.pphero.isEnabled = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
//                if type == "user"
//                {
//                    ToolClass.dispatchAfter(after: 1, handler: {
//
//                        let vc = PPBodyMainVC()
//                        let nav = HBDNavigationController(rootViewController: vc)
//                        nav.pphero.isEnabled = true
//                        self.present(nav, animated: true, completion: nil)
//                    })
//                }else{
//
//                    //跳到教练基础信息
//                    let vc = SetCoachInfoVC()
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
            })
            
        }
    }

}
