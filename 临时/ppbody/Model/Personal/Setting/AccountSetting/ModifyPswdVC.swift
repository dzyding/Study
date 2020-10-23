//
//  ModifyPswdVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class ModifyPswdVC: BaseVC {

    @IBOutlet weak var ensureNewPswdTxt: UITextField!
    @IBOutlet weak var newPswdTxt: UITextField!
    @IBOutlet weak var oldPswdTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    //修改密码的验证码
    var time : Timer?
    var codeSeconds = 60
    
    var mobile:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改密码"
        ensureNewPswdTxt.setPlaceholderColor(Text1Color)
        newPswdTxt.setPlaceholderColor(Text1Color)
        oldPswdTxt.setPlaceholderColor(Text1Color)
        
        let user = DataManager.userInfo()
        let mobile = user!["mobile"] as! String
        self.mobile = mobile
        
        self.loadSendCodeApi(self.mobile!)
    
        self.saveBtn.enableInterval = true
    }
    
    private func startTime() {
        if self.time != nil {
            self.time?.invalidate()
            self.time = nil
        }
        self.codeSeconds = 60
        self.time = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(codeTimer), userInfo: nil, repeats: true)
        self.time?.fire()
    }
    
    @objc func codeTimer() {
        self.codeSeconds = self.codeSeconds - 1
        if self.codeSeconds >= 0 {
            self.oldPswdTxt.placeholder = "\(self.codeSeconds)秒"
        }
        else {
            self.time?.invalidate()
            self.time = nil
        }
    }

    @IBAction func showPswdClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            ensureNewPswdTxt.isSecureTextEntry = false
            newPswdTxt.isSecureTextEntry = false
        }
        else {
            ensureNewPswdTxt.isSecureTextEntry = true
            newPswdTxt.isSecureTextEntry = true
        }
    }
    
    @IBAction func commitBtnClick(_ sender: UIButton) {
        
        if (self.oldPswdTxt.text?.isEmpty)!
        {
            self.oldPswdTxt.becomeFirstResponder()
            ToolClass.showToast("请输入验证码", .Failure)
            return
        }
        
        if (self.newPswdTxt.text?.isEmpty)!
        {
            self.newPswdTxt.becomeFirstResponder()
            ToolClass.showToast("请输入新密码", .Failure)
            return
        }
        
        if (self.newPswdTxt.text?.count)! < 6
        {
            self.newPswdTxt.text = ""
            self.newPswdTxt.becomeFirstResponder()
            ToolClass.showToast("密码长度大于6", .Failure)
            return
        }
        
        if self.newPswdTxt.text != self.ensureNewPswdTxt.text{
            self.ensureNewPswdTxt.text = ""
            self.ensureNewPswdTxt.becomeFirstResponder()
            ToolClass.showToast("请再次确认密码", .Failure)
            return
        }
        
        self.saveBtn.isEnabled = false
        
        loadChangePasswordApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSendCodeApi(_ mobile: String) {
        let request = BaseRequest()
        request.dic = ["mobile":mobile,"type":"30", "valid":"300"]
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
    

    func loadChangePasswordApi() {
        let request = BaseRequest()
        request.dic = ["mobile":self.mobile!,"password":ToolClass.md5(self.ensureNewPswdTxt.text! + "PPBody"), "verCode":self.oldPswdTxt.text!]
        request.url = BaseURL.FindPwd
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                self.saveBtn.isEnabled = true
                return
            }

            ToolClass.showToast("修改密码成功", .Success)
            
            ToolClass.dispatchAfter(after: 1, handler: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
