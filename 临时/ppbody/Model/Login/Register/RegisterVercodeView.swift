//
//  RegisterVercodeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterVercodeView: UIView {
    
    @IBOutlet weak var tipLB: UILabel!
    @IBOutlet weak var codeTF: PinCodeTextField!
    
    var editComplete:((String)->())?
    
    class func instanceFromNib() -> RegisterVercodeView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! RegisterVercodeView
    }
    
    override func awakeFromNib() {
        codeTF.delegate = self
        codeTF.keyboardType = .numberPad
    }
    
    func setMobile(_ mobile:String)
    {
        codeTF.becomeFirstResponder()
        let str = "我们已经给手机号码"+mobile+"发送了一个6位数的验证码"
        let mutableString = NSMutableAttributedString(string: str)
    
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: YellowMainColor , range: NSRange(location: 9,length: mobile.count))
        
           self.tipLB.attributedText = mutableString
    }
    
    func getCodeStr()->String?
    {
        if codeTF.text!.count < 6
        {
            ToolClass.showToast("验证码不全", .Failure)
            return nil
        }
        return codeTF.text!
    }
}

extension RegisterVercodeView: PinCodeTextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        if textField.text != nil && !(textField.text?.isEmpty)!
        {
            self.editComplete!(textField.text!)
        }
    }
}
