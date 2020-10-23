//
//  WkWebVC.swift
//  YJF
//
//  Created by edz on 2019/8/15.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

enum CWebType {
    case consult(cId: Int, title: String)
    case question(qaId: Int)
    case banner(url: String)
}

class WkWebVC: BaseVC {
    
    private let type: CWebType
    
    init(_ type: CWebType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        MagicWebViewWebPManager.share()?.unregisterMagicURLProtocolWebView(webView)
    }
    
    override func viewDidLoad() {
        MagicWebViewWebPManager.share()?.registerMagicURLProtocolWebView(webView)
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(view.dzyLayout.snp.top)
            make.left.right.equalTo(0)
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
        }
        super.viewDidLoad()
        switch type {
        case .consult(let cId, let title):
            navigationItem.title = title
            consultDetailApi(cId)
        case .question(let qaId):
            questionDetailApi(qaId)
        case .banner(let url):
            newsUpdateUI(url, title: "易间房")
        }
    }
    
    private func questionUpdateUI(_ data: [String : Any]?) {
        guard let content = data?.stringValue("content") else {return}
        navigationItem.title = data?.stringValue("question")
        webView.loadHTMLString(content, baseURL: nil)
    }
    
    private func consultUpdateUI(_ data: [String : Any]?) {
        guard let content = data?.dicValue("consultationInfo")?
            .stringValue("content")
        else {return}
        webView.loadHTMLString(content, baseURL: nil)
    }
    
    private func newsUpdateUI(_ url: String, title: String) {
        navigationItem.title = title
        guard let reUrl = URL(string: url) else {return}
        let request = URLRequest(url: reUrl)
        webView.load(request)
    }
    
    //    MARK: - api
    /// 问题详情
    private func questionDetailApi(_ qaId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.questionDetail
        request.dic = ["qaId" : qaId]
        request.dzy_start { (data, _) in
            self.questionUpdateUI(data)
        }
    }
    
    /// 咨询详情
    private func consultDetailApi(_ cId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.consultDetail
        request.dic = ["consultationId" : cId]
        request.dzy_start { (data, _) in
            self.consultUpdateUI(data)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        //swiftlint:disable:next line_length
        let js = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(script)
        config.userContentController = controller
        let wbView = WKWebView(frame: view.bounds, configuration: config)
        wbView.navigationDelegate = self
        return wbView
    }()
}

extension WkWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ZKProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ZKProgressHUD.dismiss()
    }
}
