//
//  SingleInputVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum SingleInputType {
    case nickName
    case loginPwd
}

class SingleInputVC: BaseVC {
    
    private let type: SingleInputType

    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet private weak var inputTF: UITextField!
    
    @IBOutlet private weak var sureBtn: UIButton!
    
    init(_ type: SingleInputType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        switch type {
        case .nickName:
            titleLB.text = "昵称"
            navigationItem.title = "个人资料"
            inputTF.placeholder = "请输入昵称"
            sureBtn.setTitle("保存", for: .normal)
        case .loginPwd:
            titleLB.text = "验证登录密码"
            navigationItem.title = "实名信息"
            inputTF.placeholder = "请输入登录密码"
            inputTF.keyboardType = .asciiCapable
            inputTF.isSecureTextEntry = true
            sureBtn.setTitle("下一步", for: .normal)
        }
    }

    @IBAction func sureAction(_ sender: UIButton) {
        view.endEditing(true)
        switch type {
        case .nickName:
            guard let input = inputTF.text, input.count > 0 else {
                showMessage("请输入更改内容")
                return
            }
            let dic: [String : Any] = ["nickname" : input]
            editUserApi(dic) { (result) in
                if result {
                    self.updateNickNameSuccess(input)
                }
            }
        case .loginPwd:
            guard let temp = inputTF.text, let pwd = PublicFunc.encryptPwd(temp) else {
                showMessage(PublicConfig.Msg_Pwd)
                return
            }
            checkPwdApi(pwd) { [weak self] in
                let vc = EditMyInfoVC(.normal)
                self?.dzy_push(vc)
            }
        }
    }
    
    private func updateNickNameSuccess(_ input: String) {
        var user = DataManager.user()
        user?.updateValue(input, forKey: "nickname")
        DataManager.saveUser(user)
        dzy_pop()
    }
    
    //    MARK: - api
    func editUserApi(_ dic: [String : Any], handler: @escaping (Bool)->()) {
        let request = BaseRequest()
        request.url = BaseURL.editUser
        request.dic = dic
        request.isId = true
        request.dzy_start { (data, _) in
            handler(data != nil)
        }
    }
    
    /// 验证旧密码
    private func checkPwdApi(_ pwd: String, handler: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.checkPwd
        request.dic = [
            "mobile" : DataManager.getUserPhone(),
            "password" : pwd
        ]
        request.dzy_start { (data, _) in
            if data != nil {
                handler()
            }
        }
    }
}
