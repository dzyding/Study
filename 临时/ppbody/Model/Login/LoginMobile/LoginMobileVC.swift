//
//  LoginMobileVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SpinKit
import IQKeyboardManagerSwift
import HBDNavigationBar

class LoginMobileVC: BaseVC {
    
    lazy var actionBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth - 120, y: ScreenHeight - 60, width: 114, height: 40)
        btn.layer.cornerRadius = 20
        btn.setTitle("登录", for: .normal)
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn.isHidden = true
        self.view.addSubview(btn)
        return btn
    }()
    
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var vercodeBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    var isFixed = false
    let accountView = AccountMobileView.instanceFromNib()
    let vercodeView = AccountVercodeView.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.containerView.addSubview(accountView)
        
        accountView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    @IBAction func selectLoginType(_ sender: UIButton) {
        
        if sender == self.accountBtn {
            //账号登录
            self.accountBtn.isSelected = true
            self.vercodeBtn.isSelected = false
            
            if !self.containerView.subviews.contains(accountView)
            {
                vercodeView.removeFromSuperview()
                self.containerView.addSubview(accountView)
                
                accountView.snp.makeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                }
            }
            
        }else{
            
            self.accountBtn.isSelected = false
            self.vercodeBtn.isSelected = true
            
            if !self.containerView.subviews.contains(vercodeView)
            {
                accountView.removeFromSuperview()
                self.containerView.addSubview(vercodeView)
                
                vercodeView.snp.makeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                }
            }
        }
    }
    
    @objc func btnAction(_ sender: UIButton)
    {
        if sender.titleLabel?.text == "登录" {
            var data:[String:String]?
            var parentPoint:CGPoint?
            if self.accountBtn.isSelected
            {
                data = self.accountView.getAccountData()
                parentPoint = self.accountView.convert(CGPoint(x: self.accountView.na_centerX, y: self.accountView.na_bottom + 30), to: self.view)
            }else{
                data = self.vercodeView.getMobileVercodeData()
                parentPoint = self.vercodeView.convert(CGPoint(x: self.vercodeView.na_centerX, y: self.vercodeView.na_bottom + 30), to: self.view)
            }
            
            if data == nil {
                return
            }
            
            isFixed = true
            
            accountView.registerResponder()
            vercodeView.registerResponder()
            
            sender.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.25, animations: {
                sender.na_size = CGSize(width: sender.na_height, height: sender.na_height)
                sender.center = parentPoint!
            }) { (finish) in
                if finish
                {
                    let spinkit = RTSpinKitView(style: RTSpinKitViewStyle.styleArc, color: BackgroundColor)
                    
                    spinkit?.spinnerSize = 30
                    sender.addSubview(spinkit!)
                    spinkit?.snp.makeConstraints({ (make) in
                        make.center.equalToSuperview()
                    })
                    
                    spinkit?.startAnimating()
                    
                    if self.accountBtn.isSelected
                    {
                        self.loginAPI(data!,type: 10)
                    }else{
                        self.loginAPI(data!,type: 20)
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let deltaY = keyBoardBounds.size.height
        
  
        if isFixed
        {
            return
        }
        
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
        
        if isFixed
        {
            return
        }
        
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
    
    func loginAPI(_ dic: [String:String], type:Int)
    {
        let request = BaseRequest()
        request.dic = dic
        request.url = type == 10 ? BaseURL.Login : BaseURL.LoginVercode
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.actionBtn.setTitle("登录", for: .normal)
                self.isFixed = false
                self.actionBtn.isHidden = true
                self.actionBtn.subviews.last?.removeFromSuperview()
                self.actionBtn.frame = CGRect(x: ScreenWidth, y: ScreenHeight, width: 114, height: 40)
                self.accountView.passwordTF.becomeFirstResponder()
                self.accountView.passwordTF.text = ""
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("登录成功", .Success)
            
            let user = data!["user"] as! [String:Any]
            
            DataManager.saveUserInfo(user)
            
            ToolClass.dispatchAfter(after: 1, handler: {
               
                let vc = PPBodyMainVC()
                let nav = HBDNavigationController(rootViewController: vc)
                nav.pphero.isEnabled = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            })
            
        }
    }
    

}
