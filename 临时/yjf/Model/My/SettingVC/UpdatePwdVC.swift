//
//  UpdatePwdVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class UpdatePwdVC: BaseVC {

    @IBOutlet weak var oldpwdTF: UITextField!
    
    @IBOutlet weak var newpwdTF: UITextField!
    
    @IBOutlet weak var secondNewPwdTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改密码"
    }
    
    @IBAction func fotgetAction(_ sender: UIButton) {
        let vc = ForgetPwdVC()
        dzy_push(vc)
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        view.endEditing(true)
        guard let oldtemp = oldpwdTF.text, let oldPwd = PublicFunc.encryptPwd(oldtemp) else {
            showMessage(PublicConfig.Msg_Pwd + "的旧密码")
            return
        }
        guard let temp = newpwdTF.text, temp.count > 0, let pwd = PublicFunc.encryptPwd(temp) else {
            showMessage(PublicConfig.Msg_Pwd + "的新密码")
            return
        }
        guard let spwd = secondNewPwdTF.text, spwd == temp else {
            showMessage("两次输入密码不相同")
            return
        }
        PublicFunc.userOperFooter(.updatePwd)
        checkPwdApi(oldPwd) { (result) in
            if result {
                let dic: [String : Any] = ["password" : pwd]
                self.editUserApi(dic) { (result) in
                    if result {
                        self.dzy_pop()
                    }
                }
            }
        }
    }
    
    //    MARK: - api
    /// 修改密码
    private func editUserApi(_ dic: [String : Any], handler: @escaping (Bool)->()) {
        let request = BaseRequest()
        request.url = BaseURL.editUser
        request.dic = dic
        request.isId = true
        request.dzy_start { (data, _) in
            handler(data != nil)
        }
    }
    
    /// 验证旧密码
    private func checkPwdApi(_ pwd: String, handler: @escaping (Bool)->()) {
        let request = BaseRequest()
        request.url = BaseURL.checkPwd
        request.dic = [
            "mobile" : DataManager.getUserPhone(),
            "password" : pwd
        ]
        request.dzy_start { (data, _) in
            handler(data != nil)
        }
    }
}
