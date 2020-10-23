//
//  WalletVC.swift
//  PPBody
//
//  Created by edz on 2019/11/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class WalletVC: BaseVC {

    @IBOutlet weak var sweatLB: UILabel!
    
    @IBOutlet weak var moneyLB: UILabel!
    
    @IBOutlet weak var noAccountLB: UILabel!
    
    @IBOutlet weak var addSweatBtn: UIButton!
    
    @IBOutlet weak var takeMoneyBtn: UIButton!
    
    private var money: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的钱包"
        [addSweatBtn, takeMoneyBtn].forEach { (btn) in
            btn?.layer.cornerRadius = 12.5
            btn?.layer.masksToBounds = true
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserWalletApi()
    }

//    MARK: - 汗水
    @IBAction func sweatInfoAction(_ sender: Any) {
        let vc = SweatWalletVC()
        dzy_push(vc)
    }
    
    @IBAction func addSweatAction(_ sender: Any) {
        let vc = AddSweatVC()
        dzy_push(vc)
    }
    
//    MARK: - 余额
    @IBAction func moneyDetailAction(_ sender: Any) {
        let vc = WalletDetailVC(.money)
        dzy_push(vc)
    }
    
    @IBAction func takeMoneyAction(_ sender: Any) {
        isWechatApi()
    }
    
    private func goTakeMoneyVC() {
        let vc = TakeMoneyVC(money)
        dzy_push(vc)
    }
    
//    MARK: - 微信授权
    private func wxAlert() {
        //未绑定微信
        let alert =  UIAlertController(title: "温馨提示", message: "您还没有绑定微信，无法操作，是否去绑定微信？", preferredStyle: .alert)
        let actionY = UIAlertAction(title: "去绑定", style: .destructive) { (_) in
            ShareSDK.authorize(SSDKPlatformType.typeWechat, settings: nil, onStateChanged: { [weak self] (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in
                switch state{
                case SSDKResponseState.success:
                    let dataInfo = user?.rawData as! [String:Any]
                    var data = [String:String]()
                    data["unionid"] = dataInfo["unionid"] as? String
                    data["openId"] = dataInfo["openid"] as? String
                    self?.bandWechat(data)
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                case SSDKResponseState.cancel:
                    print("操作取消")
                default:
                    break
                }
            })
        }
        let actionN = UIAlertAction(title: "取消", style: .cancel) { (_) in
            
        }
        alert.addAction(actionY)
        alert.addAction(actionN)
        present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - 获取汗水值、余额
    func getUserWalletApi() {
        let request = BaseRequest()
        request.url = BaseURL.UserWallet
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let sweat = data?.intValue("sweat") {
                DataManager.changeSweat(sweat)
                self?.sweatLB.text = "\(sweat)"
            }
            if let money = data?.doubleValue("wallet") {
                self?.money = money
                self?.moneyLB.text = String(format: "%.2lf", money)
            }
            if let noa = data?.doubleValue("noaccount") {
                self?.noAccountLB.text = String(format: "未入账 ¥%@", noa.decimalStr)
            }
        }
    }
    
    // MARK: - 查看是否绑定微信
    private func isWechatApi() {
        let request = BaseRequest()
        request.url = BaseURL.IfWechat
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let wechat = data?.intValue("wechat") {
                if wechat == 0 {
                    self?.wxAlert()
                }else {
                    self?.goTakeMoneyVC()
                }
            }
        }
    }
    
    private func bandWechat(_ dic:[String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.BandWechat
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("绑定成功", .Success)
        }
    }
}
