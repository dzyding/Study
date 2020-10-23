//
//  SetPwdVC.swift
//  YJF
//
//  Created by edz on 2019/6/15.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SetPwdVC: BaseVC {
    
    private let mobile: String
    
    init(_ mobile: String) {
        self.mobile = mobile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var pwdTF: UITextField!
    
    @IBOutlet weak var secondPwdTF: UITextField!
    
    @IBOutlet weak var memoLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置密码"
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        view.endEditing(true)
        guard let temp = pwdTF.text, let pwd = PublicFunc.encryptPwd(temp) else {
            memoLB.isHidden = false
            memoLB.text = "请输入至少6位，含数字/字母/符号中至少两种"
            return
        }
        guard let sPwd = secondPwdTF.text, sPwd == temp else {
            memoLB.isHidden = false
            memoLB.text = "两次输入不一样"
            return
        }
        memoLB.isHidden = true
        let dic = [
            "password" : pwd,
            "mobile" : mobile
        ]
        PublicFunc.userOperFooter(.setPwd)
        setPwdApi(dic) {
            self.dzy_popRoot()
        }
    }
    
    //    MARK: - api
    func setPwdApi(_ dic: [String : Any], success: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.setPwd
        request.dic = dic
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
