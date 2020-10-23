//
//  UpdatePhoneVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class UpdatePhoneVC: BaseVC {

    @IBOutlet weak var mobileTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var memoLB: UILabel!
    
    @IBOutlet weak var codeBtn: DzyCodeBtn!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改手机号码"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeBtn.checkTimer(.ups)
    }

    @IBAction func codeAction(_ sender: DzyCodeBtn) {
        guard let mobile = mobileTF.text, mobile.count == 11 else {
            showMessage("请输入手机号")
            return
        }
        sendVerCodeApi(mobile)
        sender.beginTimer(.ups)
    }
    
    @IBAction func sureAction(_ sender: Any) {
        view.endEditing(true)
        guard let mobile = mobileTF.text, mobile.count == 11 else {
            showMessage("请输入手机号")
            return
        }
        guard let code = codeTF.text, code.count > 0 else {
            showMessage("请输入验证码")
            return
        }
        PublicFunc.userOperFooter(.updatePhone)
        let dic = ["mobile" : mobile]
        editUserApi(dic) {
            self.dzy_popRoot()
        }
    }
    
    //    MARK: - api
    // 发送验证码
    private func sendVerCodeApi(_ mobile: String) {
        PublicFunc.sendVerCodeApi(mobile, type: 10) { (_, error) in
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
        }
    }
    
    func editUserApi(_ dic: [String : Any], success: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.editUser
        request.dic = dic
        request.isId = true
        request.start { (_, error) in
            guard error == nil else {
                self.memoLB.text = error
                self.memoLB.isHidden = false
                return
            }
            success()
        }
    }
}
