//
//  WKWebVC.swift
//  PPBody
//
//  Created by dzy_PC on 2018/11/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

/// 跳转意见反馈
fileprivate let feedBack = "jumpFeedback"

class WKWebVC: BaseVC {

    private weak var webView: WKWebView?
    
    private var url: String
    
    private var ifShare: Bool
    
    init(_ url: String, _ ifShare: Bool = true) {
        self.url = url
        self.ifShare = ifShare
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ZKProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        
        if ifShare {
            addNavigationBar()
        }
        
        if let finalUrl = URL(string: url) {
            let urlRequset = URLRequest(url: finalUrl)
            webView?.load(urlRequset)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView?.configuration
            .userContentController.add(self, name: feedBack)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView?.configuration
            .userContentController.removeScriptMessageHandler(forName: feedBack)
    }
    
    private func setWebView() {
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
    
    private func addNavigationBar() {
        let shareBtn = UIButton(type: .custom)
        shareBtn.setImage(UIImage(named: "webview_share"), for: .normal)
        shareBtn.sizeToFit()
        shareBtn.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        
        let rightBar = UIBarButtonItem(customView: shareBtn)
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    @objc private func shareAction(_ sender: UIButton) {
        let sharePlatformView = SharePlatformView.instanceFromNib()
        sharePlatformView.frame = ScreenBounds
        sharePlatformView.dataDic = self.dataDic
        sharePlatformView.initUI(.banner)
        UIApplication.shared.keyWindow?.addSubview(sharePlatformView)
    }
}

extension WKWebVC: WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == feedBack {
            let vc = AboutSettingFeedbackVC()
            dzy_push(vc)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ZKProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ZKProgressHUD.dismiss()
    }
}
