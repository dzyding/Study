//
//  CertificationVC.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

//swiftlint:disable type_body_length
class CertificationVC: BaseVC, CustomBackProtocol {

    @IBOutlet weak var pwdTF: UITextField!
    
    @IBOutlet weak var mobileTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var memoLB: UILabel!
    
    @IBOutlet weak var codeBtn: DzyCodeBtn!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "认证"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeBtn.checkTimer(.cer)
    }
    
    deinit {
        DataManager.saveUndoMsg(nil)
        dzy_log("销毁")
    }
    
    @IBAction func codeAction(_ sender: DzyCodeBtn) {
        view.endEditing(true)
        guard let mobile = mobileTF.text, mobile.count == 11 else {
            memoLB.text = "请输入11位手机号"
            memoLB.isHidden = false
            return
        }
        sender.beginTimer(.cer)
        sendVerCodeApi(mobile)
    }
    
    @IBAction func sureAction(_ sender: DzySafeBtn) {
        view.endEditing(true)
        guard let temp = pwdTF.text, let pwd = PublicFunc.encryptPwd(temp) else {
            memoLB.isHidden = false
            memoLB.text = PublicConfig.Msg_Pwd
            return
        }
        guard let mobile = mobileTF.text, mobile == DataManager.user()?.stringValue("mobile") else {
            memoLB.text = "请输入您账号绑定的手机号"
            memoLB.isHidden = false
            return
        }
        guard let code = codeTF.text, code.count > 0 else {
            memoLB.text = "请输入验证码"
            memoLB.isHidden = false
            return
        }
        memoLB.isHidden = true
        let dic: [String : Any] = [
            "verCode" : code,
            "mobile"  : mobile,
            "type"    : 30
        ]
        checkPwdApi(pwd, handler: { [weak self] in
            self?.checkVerCodeApi(dic) { [weak self] in
                self?.finalAction()
            }
        })
    }
    //swiftlint:disable:next function_body_length cyclomatic_complexity
    func finalAction() {
        if let dealMsg = DataManager.dealMsg(),
            let houseId = dealMsg.intValue("houseId")
        {
            var footMsg = dealMsg
            footMsg["msg"] = "成交"
            PublicFunc.userOperFooter(
                .twoFactor, msg: footMsg, isUser: true
            )
            buySuccessApi(dealMsg) { (result) in
                if result {
                    self.showMessage("成交操作成功")
                    DataManager.saveDealMsg(nil)
                    let vc = HouseDetailVC(houseId)
                    vc.isDeal = true
                    self.dzy_push(vc)
                }else {
                    self.showMessage("成交操作失败")
                }
            }
            return
        }
        
        if let bidMsg = DataManager.bidMsg() {
            switch IDENTITY {
            case .buyer:
                var footMsg = bidMsg
                footMsg["msg"] = "买方竞买"
                PublicFunc.userOperFooter(
                    .twoFactor, msg: footMsg, isUser: true
                )
                buyerAddMoneyApi(bidMsg) { [weak self] (result) in
                    if result {
                        self?.showMessage("竞价成功")
                        PublicFunc.checkPayOrTrain(.buyDeposit) { [weak self] (result, _) in
                            if result {
                                self?.dzy_customPopOrRootPop(
                                    HouseDetailVC.self
                                )
                            }else {
                                let vc = PayBuyDepositVC(
                                    .jump(PublicConfig.Pay_Notice_Deposit)
                                )
                                self?.dzy_push(vc)
                            }
                        }
                    }else {
                        self?.showMessage("竞价失败")
                    }
                }
                
            case .seller:
                var footMsg = bidMsg
                footMsg["msg"] = "卖方报价"
                PublicFunc.userOperFooter(.twoFactor, msg: footMsg)
                sellerAddMoneyApi(bidMsg) { [weak self] (result) in
                    if result {
                        PublicFunc.checkPayOrTrain(.sellDeposit) { [weak self] (result, _) in
                            if result {
                                self?.dzy_customPopOrRootPop(
                                    HouseDetailVC.self
                                )
                            }else {
                                let vc = PaySellDepositVC(
                                    .jump(PublicConfig.Pay_Notice_Deposit)
                                )
                                self?.dzy_push(vc)
                            }
                        }
                    }else {
                        self?.showMessage("添加报价失败")
                    }
                }
            }
            return
        }
        
        if let undoDic = DataManager.undoMsg() {
            switch IDENTITY {
            case .buyer:
                var footMsg = undoDic
                footMsg["msg"] = "买方撤销竞价"
                PublicFunc.userOperFooter(.twoFactor, msg: footMsg)
                buyerDelPriceApi(undoDic) { [weak self] result in
                    if result {
                        self?.showMessage("撤销报价成功")
                        self?.dzy_customPopOrPop(
                            HouseDetailBaseVC.self
                        )
                    }else {
                        self?.showMessage("撤销报价失败")
                    }
                }
            case .seller:
                var footMsg = undoDic
                footMsg["msg"] = "卖方撤销报价"
                PublicFunc.userOperFooter(.twoFactor, msg: footMsg)
                sellerDelPriceApi(undoDic) { [weak self] result in
                    if result {
                        self?.showMessage("撤销报价成功")
                        self?.dzy_pop()
                    }else {
                        self?.showMessage("撤销报价失败")
                    }
                }
            }
        }
    }
    
    //    MARK: - api
    // 发送验证码
    private func sendVerCodeApi(_ mobile: String) {
        PublicFunc.sendVerCodeApi(mobile, type: 30) { (_, error) in
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
    
    /// 验证旧密码
    private func checkPwdApi(_ pwd: String, handler: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.checkPwd
        request.dic = [
            "mobile" : DataManager.getUserPhone(),
            "password" : pwd
        ]
        request.start({ (_, error) in
            guard error == nil else {
                self.memoLB.text = error
                self.memoLB.isHidden = false
                return
            }
            handler()
        })
    }
    
    /// 成交
    private func buySuccessApi(
        _ dic: [String : Any], handler: @escaping (Bool)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.buySuccess
        request.dic = dic
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                handler(true)
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_BuySuccess, object: nil
                )
            }else {
                handler(false)
            }
        }
    }
    
    /// 添加卖家报价
    private func sellerAddMoneyApi(
        _ dic: [String : Any], handler: @escaping (Bool)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.sellerAddMoney
        request.dic = dic
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                DataManager.saveBidMsg(nil)
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_AddPriceSuccess,
                    object: nil
                )
                handler(true)
            }else {
                handler(false)
            }
        }
    }
    
    /// 买家添加竞价
    private func buyerAddMoneyApi(
        _ dic: [String : Any], handler: @escaping (Bool)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.buyerAddMoney
        request.dic = dic
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                DataManager.saveBidMsg(nil)
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_AddPriceSuccess,
                    object: nil
                )
                handler(true)
            }else {
                handler(false)
            }
        }
    }
    
    // 买家撤销报价
    private func buyerDelPriceApi(
        _ dic: [String : Any], handler: @escaping (Bool)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.buyerDelMoney
        request.dic = dic
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_UndoPriceSuccess,
                    object: nil
                )
                DataManager.saveUndoMsg(nil)
                handler(true)
            }else {
                handler(false)
            }
        }
    }
    
    // 卖家撤销报价
    private func sellerDelPriceApi(
        _ dic: [String : Any], handler: @escaping (Bool)->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.sellerDelMoney
        request.dic = dic
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_UndoPriceSuccess,
                    object: nil
                )
                DataManager.saveUndoMsg(nil)
                handler(true)
            }else {
                handler(false)
            }
        }
    }
}
