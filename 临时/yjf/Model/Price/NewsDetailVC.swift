//
//  NewsDetailVC.swift
//  YJF
//
//  Created by dingzhiyuan on 2020/9/8.
//  Copyright © 2020 灰s. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

class NewsDetailVC: UIViewController {
    
    private let pid: Int
    
    private let vcTitle: String

    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    init(_ pid: Int, vcTitle: String) {
        self.pid = pid
        self.vcTitle = vcTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        MagicWebViewWebPManager.share()?.unregisterMagicURLProtocolWebView(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MagicWebViewWebPManager.share()?.registerMagicURLProtocolWebView(webView)
        navigationItem.title = vcTitle
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
        }
        detailApi(pid)
    }
    
    func updateUI(_ data: [String : Any]?) {
        let title = data?.stringValue("title") ?? ""
        titleLB.text = title
        if let url = data?.stringValue("url"),
            let reUrl = URL(string: url)
        {
            let request = URLRequest(url: reUrl)
            webView.load(request)
        }else if let content = data?.stringValue("content") {
            
            webView.loadHTMLString(content, baseURL: nil)
        }
        
        let num = data?.intValue("num") ?? 0
        numLB.text = "\(num)次阅读"
        numLB.isHidden = num == 0
        if let time = data?.stringValue("createTime")?
            .components(separatedBy: " ").first
        {
            let index = time.index(time.startIndex, offsetBy: 5)
            timeLB.text = String(time[index...])
        }else {
            timeLB.text = nil
        }
    }
    
//    MARK: - Api
    private func detailApi(_ id: Int) {
        let request = BaseRequest()
        request.url = BaseURL.newsDetail
        request.dic = ["quotationId" : id]
        request.dzy_start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.updateUI(data?.dicValue("quotation"))
        }
    }
    
    //    MARK: - 懒加载
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        let js = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(script)
        config.userContentController = controller
        let wbView = WKWebView(frame: view.bounds, configuration: config)
        wbView.navigationDelegate = self
        return wbView
    }()
}

extension NewsDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ZKProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ZKProgressHUD.dismiss()
    }
}
