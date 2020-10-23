//
//  LoginVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import HBDNavigationBar

class LoginVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var mobileBtn: UIButton!
    
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var qqBtn: UIButton!
    @IBOutlet weak var aliBtn: UIButton!
    @IBOutlet weak var sinaBtn: UIButton!
    
    @IBAction func registerAction(_ sender: UIButton) {
        let registerVC = RegisterVC()
        self.navigationController?.pushViewController(registerVC, animated: true)
        
    }
    @IBAction func mobileAction(_ sender: UIButton) {
        let mobileVC = LoginMobileVC()
        mobileVC.hbd_barAlpha = 0
        self.navigationController?.pushViewController(mobileVC, animated: true)
    }
    
    @IBAction func wechatAction(_ sender: UIButton) {

        ShareSDK.authorize(SSDKPlatformType.typeWechat, settings: nil, onStateChanged: { (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in

            switch state{

            case SSDKResponseState.success:
                let dataInfo = user?.rawData as! [String:Any]
                self.dataDic["unionId"] = dataInfo["unionid"]
                self.dataDic["openId"] = dataInfo["openid"]
                self.dataDic["head"] = dataInfo["headimgurl"]
                self.dataDic["nickname"] = dataInfo["nickname"]
                self.dataDic["type"] = "10"
                self.loginOtherAPI()

            case SSDKResponseState.fail:
                error.flatMap({
                    print("授权失败,错误描述: \($0)")
                })
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        })
    }
    @IBAction func AlipayLoginAction(_ sender: UIButton) {

        AlipaySDK.defaultService().auth_V2(withInfo: Config.Alipay_login_authInfo, fromScheme: "ppbody") { (resultDic) in

            guard let responseDictionary = resultDic as? [String: AnyObject] else {
                return
            }

            let result = responseDictionary["result"] as? String
            if result != nil && (result?.count)! > 0
            {
                let strArr = result?.components(separatedBy: "&")

                for str in strArr!
                {
                    if str.hasPrefix("user_id=")
                    {
                        let userId = str.replacingOccurrences(of: "user_id=", with: "")
                        self.dataDic["alipayId"] = userId

                    }else if str.hasPrefix("auth_code")
                    {
                        let authCode = str.replacingOccurrences(of: "auth_code=", with: "")
                        self.dataDic["alipayCode"] = authCode
                    }
                }

                self.dataDic["type"] = "20"
                self.loginOtherAPI()
            }
        }
    }
    
    @IBAction func qqAction(_ sender: UIButton) {
    }
    
    @IBAction func sinaAction(_ sender: UIButton) {
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registObservers([
            Config.Notify_AlipayLogin
        ], queue: .main) { [weak self] (nofity) in
            self?.dataDic = nofity.userInfo as! [String : Any]
            self?.dataDic["type"] = "20"
            self?.loginOtherAPI()
        }
        
        if WXApi.isWXAppInstalled(){
            self.wechatBtn.isHidden = false
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "alipay:")!) {
            self.aliBtn.isHidden = false
        }
    }
    
    func loginOtherAPI()
    {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String:String]
        request.url = BaseURL.LoginOtherAPP
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            
            let band = data!["band"] as? Int
            if band != nil && band == 0
            {
                //没绑定用户 跳转
                let registerVC = BandMobileVC()
                registerVC.dataDic = self.dataDic
                self.navigationController?.pushViewController(registerVC, animated: true)
                return
            }
            
            ToolClass.showToast("登录成功", .Success)

            
            let user = data!["user"] as! [String:Any]
            
            DataManager.saveUserInfo(user)
            
            ToolClass.dispatchAfter(after: 1, handler: {
                let vc = PPBodyMainVC()
                let nav = HBDNavigationController(rootViewController: vc)
                nav.pphero.isEnabled = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            })
            
        }
    }
}
