//
//  UpdatePhoneFirstVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class UpdatePhoneFirstVC: BaseVC {

    @IBOutlet weak var idCardTF: UITextField!
    
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
        codeBtn.checkTimer(.upf)
    }
    
    @IBAction func codeAction(_ sender: DzyCodeBtn) {
        guard let mobile = mobileTF.text,
            mobile.count > 0,
            mobile == DataManager.getUserPhone()
        else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        memoLB.isHidden = true
        sendVerCodeApi(mobile)
        sender.beginTimer(.upf)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        guard let idCard = idCardTF.text, idCard.count > 0 else {
            memoLB.isHidden = false
            memoLB.text = "请输入身份证号"
            return
        }
        guard let mobile = mobileTF.text,
            mobile.count > 0,
            mobile == DataManager.getUserPhone()
        else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        guard let code = codeTF.text, code.count > 0 else {
            memoLB.isHidden = false
            memoLB.text = "请输入验证码"
            return
        }
        memoLB.isHidden = true
        let checkDic: [String : Any] = [
            "verCode" : code,
            "mobile"  : mobile,
            "idCard"  : idCard,
            "type"    : 10
        ]
        checkVerCodeApi(checkDic) {
            let vc = UpdatePhoneVC()
            self.dzy_push(vc)
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
    
    // 检查验证码
    private func checkVerCodeApi(_ dic: [String : Any], success: @escaping () -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.checkMobileCode
        request.dic = dic
        request.start { (_, error) in
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
            self.memoLB.isHidden = true
            success()
        }
    }
}
