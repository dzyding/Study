//
//  AccountMobileView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AccountMobileView: UIView {
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    
    class func instanceFromNib() -> AccountMobileView {
        return UINib(nibName: "LoginMobileInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AccountMobileView
    }
    
    override func awakeFromNib() {
       super.awakeFromNib()
        
        self.mobileTF.attributedPlaceholder = NSAttributedString(string: self.mobileTF.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : Text1Color])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string: self.passwordTF.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : Text1Color])
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.mobileTF.becomeFirstResponder()

    }
    
    @IBAction func passwordOpenAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected
        {
            self.passwordTF.isSecureTextEntry = false
        }else{
            self.passwordTF.isSecureTextEntry = true
        }
    }
    //获取相应账户信息
    func getAccountData() -> [String:String]?
    {
        if !(self.mobileTF.text?.isEmpty)!
        {
            if (self.mobileTF.text?.contains("pp"))!
            {
                
            }else{
                if !ToolClass.checkPhone(self.mobileTF.text!)
                {
                    ToolClass.showToast("手机号不正确", .Failure)
                    return nil
                }
            }
        }
    
        
        if (self.passwordTF.text?.count)! < 6
        {
            ToolClass.showToast("密码长度不对，必须大于等于6位", .Failure)
            return nil
        }
                
        return ["mobile":self.mobileTF.text!,"password":ToolClass.md5(self.passwordTF.text! + "PPBody")]
    }
    
    //设置密码 获取密码信息
    func getAccountPswd() -> [String: String]? {
        if !ToolClass.checkPswd(self.mobileTF.text!)
        {
            ToolClass.showToast("密码长度不对，请设置6-16位密码", .Failure)
            return nil
        }
        
        if self.mobileTF.text != self.passwordTF.text {
            ToolClass.showToast("两次设置的密码不一致", .Failure)
            return nil
        }
        return ["password":self.passwordTF.text!]
    }
    
    func registerResponder()
    {
        self.mobileTF.resignFirstResponder()
        self.passwordTF.resignFirstResponder()
    }

}
