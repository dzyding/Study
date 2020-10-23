//
//  RegisterPasswordView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterPasswordView: UIView {
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var surePasswordTF: UITextField!
    
    
    
    class func instanceFromNib() -> RegisterPasswordView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! RegisterPasswordView
    }
    
    override func awakeFromNib() {
        passwordTF.setPlaceholderColor(Text1Color)
        surePasswordTF.setPlaceholderColor(Text1Color)
    }
    
    func beginInput()
    {
        self.passwordTF.becomeFirstResponder()
    }
    
    func getPassword()->String?
    {
        if (self.passwordTF.text?.count)! < 6 || (self.passwordTF.text?.count)! > 16
        {
            ToolClass.showToast("密码长度不对", .Failure)
            return nil
        }
        
        if self.passwordTF.text != self.surePasswordTF.text
        {
            ToolClass.showToast("两次密码输入不正确", .Failure)
            return nil
        }
        return ToolClass.md5(self.passwordTF.text! + "PPBody")
    }
}
