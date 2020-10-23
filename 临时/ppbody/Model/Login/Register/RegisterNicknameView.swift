//
//  RegisterNicknameView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterNicknameView: UIView {
    
    @IBOutlet weak var nicknameTF: UITextField!
    
    
    class func instanceFromNib() -> RegisterNicknameView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[3] as! RegisterNicknameView
    }
    
    override func awakeFromNib() {
        nicknameTF.setPlaceholderColor(Text1Color)
    }
    
    func beginInput()
    {
        self.nicknameTF.becomeFirstResponder()
    }
    
    func endInput()
    {
        self.nicknameTF.resignFirstResponder()
    }
    
    func getNickname()->String?
    {
        if (self.nicknameTF.text?.isEmpty)!
        {
            ToolClass.showToast("请输入昵称", .Failure)
            return nil
        }
        
        if (self.nicknameTF.text?.count)! < 2 || (self.nicknameTF.text?.count)! > 15
        {
            ToolClass.showToast("昵称长度不对", .Failure)
            return nil
        }
        return self.nicknameTF.text!
    }
}
