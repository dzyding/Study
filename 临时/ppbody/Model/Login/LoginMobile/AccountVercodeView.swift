//
//  AccountVercodeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AccountVercodeView: UIView
{
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    
    //登录的验证码
    var time : Timer?
    var codeSeconds = 60
    
    @IBAction func codeAction(_ sender: UIButton) {
        
        if !ToolClass.checkPhone(self.mobileTF.text!)
        {
            ToolClass.showToast("手机号不正确", .Failure)
            return 
        }
        
        startTime()
        loadSendCodeApi(self.mobileTF.text!)
    }
    
    class func instanceFromNib() -> AccountVercodeView {
        return UINib(nibName: "LoginMobileInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! AccountVercodeView
    }
    
    override func awakeFromNib() {
        self.mobileTF.attributedPlaceholder = NSAttributedString(string: self.mobileTF.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : Text1Color])
        self.codeTF.attributedPlaceholder = NSAttributedString(string: self.codeTF.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : Text1Color])
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.mobileTF.becomeFirstResponder()
    }
    
    func registerResponder()
    {
        self.mobileTF.resignFirstResponder()
        self.codeTF.resignFirstResponder()
    }
    
    //获取相应账户信息
    func getMobileVercodeData() -> [String:String]?
    {
        if !ToolClass.checkPhone(self.mobileTF.text!)
        {
            ToolClass.showToast("手机号不正确", .Failure)
            return nil
        }
        
        if (self.codeTF.text?.count)! < 6
        {
            ToolClass.showToast("密码长度不对，必须大于等于6位", .Failure)
            return nil
        }
        
        return ["mobile":self.mobileTF.text!,"verCode":self.codeTF.text!]
    }
    
    private func startTime() {
        if self.time != nil {
            self.time?.invalidate()
            self.time = nil
            self.codeBtn.isUserInteractionEnabled = true
        }
        self.codeSeconds = 60
        self.time = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(codeTimer), userInfo: nil, repeats: true)
        self.time?.fire()
        self.codeBtn.isUserInteractionEnabled = false
        self.codeBtn.setTitleColor(UIColor.ColorHex("#ffffff"), for: .normal)
        self.codeBtn.backgroundColor = Text1Color
    }
    
    @objc func codeTimer() {
        self.codeSeconds = self.codeSeconds - 1
        if self.codeSeconds >= 0 {
            self.codeBtn.setTitle("重新发送(\(self.codeSeconds)s)", for: .normal)
        }
        else {
            self.time?.invalidate()
            self.time = nil
            self.codeBtn.setTitle("获取验证码", for: .normal)
            self.codeBtn.isUserInteractionEnabled = true
            self.codeBtn.setTitleColor(BackgroundColor, for: .normal)
            self.codeBtn.backgroundColor = YellowMainColor
        }
    }
    
    func loadSendCodeApi(_ mobile: String) {
        let request = BaseRequest()
        request.dic = ["mobile":mobile,"type":"20", "valid":"300"]
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
}
