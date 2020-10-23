//
//  MessageWebView.swift
//  PPBody
//
//  Created by edz on 2018/12/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

enum WebType {
    case gym(url: String)    //健身房详情
    case amb    //推广大使
}

class MessageWebView: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    weak var webView: WKWebView?
    
    fileprivate var type: WebType
    
    var popView: DzyPopView?
    
    lazy var shareView: UIView = {
        return getShareView() ?? UIView()
    }()
    
    init(_ type: WebType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        
        switch type {
        case .gym(let url):
            if let finalUrl = URL(string: url) {
                let urlRequset = URLRequest(url: finalUrl)
                webView?.load(urlRequset)
            }
        case .amb:
            navigationItem.title = "推广大使"
            ifRepresentApi()
            view.insertSubview(shareView, at: 0)
            
            registObservers([
                Config.Notify_PaySuccess
            ], queue: .main) { [weak self] (_) in
                self?.ifRepresentApi() // 根据返回值刷新界面
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch type {
        case .gym:
            webView?.configuration.userContentController.add(self, name: "getCoachId") // 获取教练 uid
            webView?.configuration.userContentController.add(self, name: "getMap")  // 获取健身房定位信息
        case .amb:
            webView?.configuration.userContentController.add(self, name: "getMoney") // 获取支付方式
            webView?.configuration.userContentController.add(self, name: "getPic") // 保存图片
            webView?.configuration.userContentController.add(self, name: "getCancel") // 取消推广大使
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        switch type {
        case .gym:
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getCoachId")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getMap")
        case .amb:
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getMoney")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getPic")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getCancel")
        }
    }
    
    func setWebView() {
        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
        configuration.userContentController = userController
        let web = WKWebView(frame: ScreenBounds, configuration: configuration)
        web.navigationDelegate = self
        view.addSubview(web)
        self.webView = web
        
        web.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalTo(view)
        }
    }
    
    // MARK: - 是否为推广大使
    func checkRepresent(_ re: Int) {
        var url: String = ""
        if re == 0 { // 不是推广大使
            url = Config.Represent_Become + "?AUTH=\(DataManager.userAuth())"
        }else { // 已经是推广大使
            url = Config.Represent_Detail + "?AUTH=\(DataManager.userAuth())"
        }
        if let finalUrl = URL(string: url) {
            let urlRequset = URLRequest(url: finalUrl)
            webView?.load(urlRequset)
        }
    }
    
    //    MARK: - 判断是否为推广大使
    func ifRepresentApi() {
        ZKProgressHUD.show()
        let request = BaseRequest()
        request.url = BaseURL.IfRepresent
        request.isUser = true
        request.start { [weak self] (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let represent = data?.intValue("represent") {
                self?.checkRepresent(represent)
            }
        }
    }
    
    //    MARK: - 保存图片
    func saveAction(_ code: String) {
        if let popView = popView {
            popView.show()
        }else {
            if let v = self.view.subviews.first,
                let codeLB = v.viewWithTag(9) as? UILabel
            {
                codeLB.text = code
                guard let img = viewCopy(v) else {return}
                
                let source = ImagePopView.initFromNib(ImagePopView.self)
                source.imgView.image = img
                source.frame = CGRect(x: 0, y: 0, width: 270, height: 500)
                
                popView = DzyPopView(.POP_center, viewBlock: source)
                popView?.show()
            }
        }
    }
    
    //    MARK: - 付款
    func ambPayApi(_ type: Int, _ money: Int) {
        if type == 1 {
            // 支付宝
            getAliPayPre(money)
        }else if type == 2 {
            // 微信
            getWechatPre(money)
        }
    }
    
    //MARK: - 微信支付下单
    func getWechatPre(_ money: Int) {
        /*
        let request = BaseRequest()
        let dic = [
            "price" : "\(money)",
            "type" : "90"
        ]
        request.dic = dic
        request.url = BaseURL.WechatPayPreOrder
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            guard let pay = data?["payInfoWechat"] as? [String : Any] else {
                ToolClass.showToast("订单信息出错", .Failure)
                return
            }
            let req = PayReq()
            req.openID = pay["appid"] as? String
            req.partnerId = pay["partnerid"] as? String
            req.prepayId = pay["prepayid"] as? String
            req.nonceStr = pay["noncestr"] as? String
            req.timeStamp = UInt32(pay["timestamp"] as! String)!
            req.package = pay["package"] as? String
            req.sign = pay["sign"] as? String
            WXApi.send(req)
        }
         */
    }
    
    //    MARK: - 支付宝支付下单
    func getAliPayPre(_ money: Int) {
        /*
        let request = BaseRequest()
        let dic = [
            "price" : "\(money)",
            "type" : "90"
        ]
        request.dic = dic
        request.url = BaseURL.AliPayPreOrder
        request.isUser = true
        
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            guard let orderStr = data?["payInfoAlipay"] as? String else {
                ToolClass.showToast("订单信息出错", .Failure)
                return
            }
            AlipaySDK.defaultService().payOrder(orderStr, fromScheme: "ppbody", callback: { (resultDic) in
                dzy_log(resultDic)
            })
        }
         */
    }
    
    //    MARK: - 获取分享图片
    func getShareView() -> UIView? {
        guard let user = DataManager.userInfo() else {return nil}
        let color = RGB(r: 51.0, g: 51.0, b: 51.0)
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        
        let imgView = UIImageView(image: UIImage(named: "amb_shareBg"))
        imgView.contentMode = .scaleAspectFit
        bgView.addSubview(imgView)
        
        let headIV = UIImageView()
        headIV.setHeadImageUrl(user.stringValue("head") ?? "")
        headIV.layer.cornerRadius = 25
        headIV.layer.masksToBounds = true
        headIV.layer.borderColor = color.cgColor
        headIV.layer.borderWidth = 1
        bgView.addSubview(headIV)
        
        let code = UILabel()
        code.tag = 9
        code.font = UIFont.boldSystemFont(ofSize: 35)
        bgView.addSubview(code)
        
        imgView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        headIV.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.centerX.equalTo(bgView)
            make.top.equalTo(310 - 30) // 310 为那条横线的y
        }
        
        code.snp.makeConstraints { (make) in
            make.top.equalTo(headIV.snp.bottom).offset(35)
            make.centerX.equalTo(headIV)
        }
        
        if let nickName = user.stringValue("nickname") {
            let msgStr = nickName + "的邀请码"
            let msg = UILabel()
            let attStr = NSMutableAttributedString(string: msgStr, attributes: [
                NSAttributedString.Key.font : ToolClass.CustomFont(14),
                NSAttributedString.Key.foregroundColor : color
                ])
            attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: RGB(r: 108.0, g: 106.0, b: 204.0),
                                range: NSRange(location: 0, length: nickName.count))
            msg.attributedText = attStr
            bgView.addSubview(msg)
            
            msg.snp.makeConstraints { (make) in
                make.top.equalTo(headIV.snp.bottom).offset(10)
                make.centerX.equalTo(headIV)
            }
        }
        
        return bgView
    }
}

extension MessageWebView: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let msg = message.body as? [String : Any] {
            switch type {
            case .gym: // 健身房
                if message.name == "getCoachId" {
                    if let uid = msg.stringValue("uid") {
                        let vc = PersonalPageVC()
                        vc.uid = uid
                        dzy_push(vc)
                    }
                }else if message.name == "getMap" {
                    if let lat = msg.doubleValue("lat"),
                        let lng = msg.doubleValue("lng"),
                        let name = navigationItem.title
                    {
                        let vc = MapVC(name, lat, lon: lng)
                        dzy_push(vc)
                    }
                }
            case .amb: // 推广大使
                if message.name == "getMoney" { // 付款
                    if let type = msg.intValue("type"),
                        let money = msg.intValue("money")
                    {
                        ambPayApi(type, money)
                    }
                }else if message.name == "getPic" { // 保存图片
                    if let code = msg.stringValue("num") { //验证码
                        saveAction("\(code)")
                    }
                }else if message.name == "getCancel" { //取消推广大使
                    if let money = msg.doubleValue("deposit") {
                        let vc = TakeSweatVC(.cancelRepresent(money))
                        dzy_push(vc)
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ToolClass.showToast("获取信息失败", .Failure)
    }
}
