//
//  LoginVC.swift
//  YJF
//
//  Created by edz on 2019/4/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

enum LoginType {
    case pwd
    case phone
}

class LoginVC: BaseVC {
    
    private var type: LoginType = .phone

    // 验证码登录
    @IBOutlet weak var phoneLoginView: UIView!

    @IBOutlet weak var phone_phoneTF: UITextField!
    
    @IBOutlet weak var phone_codeTF: UITextField!
    
    @IBOutlet weak var phone_codeBtn: DzyCodeBtn!
    
    // 密码登录
    @IBOutlet weak var pwdLoginView: UIView!
    
    @IBOutlet weak var pwd_phoneTF: UITextField!
    
    @IBOutlet weak var pwd_pwdTF: UITextField!
    
    @IBOutlet weak var pwdLoginBtn: UIButton!
    
    // 错误提示
    @IBOutlet weak var memoLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdLoginView.isHidden = false
        if DataManager.isPwd() {
            pwdLoginBtn.sendActions(for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phone_codeBtn.checkTimer(.login)
    }

    @IBAction func pwdLoginAction(_ sender: Any) {
        pwdLoginView.isHidden = false
        phoneLoginView.isHidden = true
        pwd_phoneTF.text = phone_phoneTF.text
        type = .pwd
    }
    
    @IBAction func phoneLoginAction(_ sender: Any) {
        pwdLoginView.isHidden = true
        phoneLoginView.isHidden = false
        phone_phoneTF.text = pwd_phoneTF.text
        type = .phone
    }
    
    @IBAction func forgetPwdAction(_ sender: UIButton) {
        let vc = ForgetPwdVC()
        parent?.dzy_push(vc)
    }
    
    //    MARK: - 更换地址
    @IBAction func changeUrlAction(_ sender: UIButton) {
        let vc = ChangeUrlVC()
        present(vc, animated: true, completion: nil)
    }
    
    //    MARK: - 获取验证码
    @IBAction func codeAction(_ sender: DzyCodeBtn) {
        view.endEditing(true)
        guard let mobile = phone_phoneTF.text, mobile.count == 11 else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        sender.beginTimer(.login)
        sendVerCodeApi(mobile)
    }
    
    //    MARK: - 登录
    @IBAction func loginAction(_ sender: Any) {
        view.endEditing(true)
        switch type {
        case .phone:
            phoneLoginAction()
        case .pwd:
            pwdLoginAction()
        }
    }
    
    // 账号密码登录
    private func pwdLoginAction() {
        guard let mobile = pwd_phoneTF.text, mobile.count == 11 else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        guard let tempPwd = pwd_pwdTF.text, let pwd = PublicFunc.encryptPwd(tempPwd) else {
            memoLB.isHidden = false
            memoLB.text = PublicConfig.Msg_Pwd
            return
        }
        memoLB.isHidden = true
        let dic: [String : Any] = [
            "password" : pwd,
            "mobile"  : mobile
        ]
        pwdLoginApi(dic) { [weak self] data in
            DataManager.saveUser(data.dicValue("user"))
            self?.loginSuccessAction(data)
        }
    }
    
    // 验证码登录
    private func phoneLoginAction() {
        guard let mobile = phone_phoneTF.text, mobile.count == 11 else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        guard let code = phone_codeTF.text, code.count == 6 else {
            memoLB.isHidden = false
            memoLB.text = "请输入验证码"
            return
        }
        memoLB.isHidden = true
        let cDic: [String : Any] = [
            "verCode" : code,
            "mobile"  : mobile,
            "type"    : 20
        ]
        
        let dic: [String : Any] = [
            "verCode" : code,
            "mobile"  : mobile
        ]
        checkVerCodeApi(cDic) { [weak self] in
            self?.checkVerCodeSuccessAction(dic)
        }
    }
    
    private func checkVerCodeSuccessAction(_ dic: [String : Any]) {
        codeLoginApi(dic) { [weak self] data in
            DataManager.saveUser(data.dicValue("user"))
            self?.loginSuccessAction(data)
        }
    }
    
    //    MARK: - 登录成功
    private func loginSuccessAction(_ data: [String : Any]) {
        showMessage("登录成功")
        switch type {
        case .phone:
            phone_phoneTF.text = nil
            phone_codeTF.text = nil
        case .pwd:
            pwd_phoneTF.text = nil
            pwd_pwdTF.text = nil
        }
        DataManager.saveLoginDate(Date().description)
        let user = data.dicValue("user") ?? [:]
        if user.intValue("type") == 0 {
            let vc = SelfTypeVC(.login)
            parent?.dzy_push(vc)
        }else {
            let vc = BaseNavVC(rootViewController: BaseTabbarVC())
            present(vc, animated: true, completion: nil)
        }
    }
    
    //    MARK: - api
    // 发送验证码
    private func sendVerCodeApi(_ mobile: String) {
        PublicFunc.sendVerCodeApi(mobile, type: 20) { (_, error) in
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
        }
    }
    
    // 检查验证码
    private func checkVerCodeApi(_ dic: [String : Any], success: @escaping () -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.checkMobileCode
        request.dic = dic
        ZKProgressHUD.show()
        request.start { (_, error) in
            ZKProgressHUD.dismiss()
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
            success()
        }
    }
    
    // 验证码登录
    private func codeLoginApi(_ dic: [String : Any], success: @escaping ([String : Any]) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.mobileLogin
        request.dic = dic
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
            if let data = data {
                success(data)
            }
        }
    }
    
    // 密码登录
    private func pwdLoginApi(_ dic: [String : Any], success: @escaping ([String : Any]) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.pwdLogin
        request.dic = dic
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
            if let data = data {
                success(data)
            }
        }
    }
}
