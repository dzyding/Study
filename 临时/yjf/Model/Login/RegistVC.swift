//
//  RegistVC.swift
//  YJF
//
//  Created by edz on 2019/4/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class RegistVC: BaseVC {

    @IBOutlet private weak var codeBtn: DzyCodeBtn!
    
    @IBOutlet private weak var phoneTF: UITextField!
    
    @IBOutlet private weak var codeTF: UITextField!
    
    @IBOutlet private weak var memoLB: UILabel!
    
    @IBOutlet private weak var protocolBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeBtn.checkTimer(.regist)
    }

    // 用户协议
    @IBAction func protocolAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func goProtocolAction(_ sender: UIButton) {
        let vc = UserProtocolVC()
        dzy_push(vc)
    }
    
    // 提交
    @IBAction private func sureAction(_ sender: UIButton) {
        view.endEditing(true)
        guard protocolBtn.isSelected else {
            memoLB.isHidden = false
            memoLB.text = "您需要遵守用户协议"
            return
        }
        guard let mobile = phoneTF.text, mobile.count == 11 else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        guard let code = codeTF.text, code.count == 6 else {
            memoLB.isHidden = false
            memoLB.text = "请输入验证码"
            return
        }
        memoLB.isHidden = true
        let checkDic: [String : Any] = [
            "verCode" : code,
            "mobile"  : mobile,
            "type"    : 10
        ]
        checkVerCodeApi(checkDic) { [weak self] in
            self?.registAction(mobile)
        }
    }
    
    //MARK: -  注册
    private func registAction(_ mobile: String) {
        var dic: [String : Any] = [
            "mobile" : mobile,
            "type" : 20, // 暂时用 20，会切换到默认选择城市
            "registerType" : 20 //iOS 固定 20
        ]
        if let vc = (parent as? LoginRegistBaseVC),
            let code = vc.code
        {
            dic["code"] = code
        }
        registApi(dic) { [weak self] data in
            self?.registSuccessAction(data)
        }
    }
    
    private func registSuccessAction(_ data: [String : Any]) {
        let user = data.dicValue("user")
        DataManager.saveUser(user)
        showMessage("注册成功")
        memoLB.isHidden = true
        phoneTF.text = nil
        codeTF.text = nil
        
        guard let userId = user?.intValue("id") else {return}
        JPUSHService.setAlias("\(userId)yjf", completion: { (code, alias, _) in
            dzy_log("code - \(code) alias - \(alias ?? "")")
        }, seq: 1)
    
        cityListApi()
    }
    
    // 初始化城市信息
    private func cityListSuccess(_ data: [String : Any]?) {
        let cityList = data?.arrValue("regionList") ?? []
        if cityList.count > 1 {
            let vc = CityPickerVC(.regist)
            vc.registCityList = data
            dzy_push(vc)
        }else {
            let vc = SelfTypeVC(.login)
            dzy_push(vc)
        }
    }
    
    // 获取验证码
    @IBAction private func codeAction(_ sender: DzyCodeBtn) {
        view.endEditing(true)
        guard protocolBtn.isSelected else {
            memoLB.isHidden = false
            memoLB.text = "请阅读并同意用户服务协议"
            return
        }
        guard let mobile = phoneTF.text, mobile.count == 11 else {
            memoLB.isHidden = false
            memoLB.text = "请输入正确的手机号"
            return
        }
        sender.beginTimer(.regist)
        memoLB.isHidden = true
        sendVerCodeApi(mobile)
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
            success()
        }
    }
    
    // 注册
    private func registApi(_ dic: [String : Any], success: @escaping ([String : Any]) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.regist
        request.dic = dic
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            if let error = error {
                self.memoLB.isHidden = false
                self.memoLB.text = error
                return
            }
            if let data = data {
                success(data)
            }
        }
    }
    
    /// 所有城市
    private func cityListApi() {
        let request = BaseRequest()
        request.url = BaseURL.cityList
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            self.cityListSuccess(data)
        }
    }
}
