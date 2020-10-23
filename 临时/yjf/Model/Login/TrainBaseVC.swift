//
//  TrainBaseVC.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

enum TrainStepFrom {
    /// 登陆界面使用
    case login
    /// 切换身份时使用
    case changeType
    /// 直接 push 使用
    case push
}

class TrainBaseVC: BaseVC {

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.addObserver(self,
                         forKeyPath: "estimatedProgress",
                         options: .new,
                         context: nil)
        return view
    }()
    
    var scrollBottomH: CGFloat = 0
    
    let type: TrainStepFrom
    
    init(_ type: TrainStepFrom) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        view.addSubview(progressView)
        
        webView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            if type == .login {
                make.top.equalTo(view.dzyLayout.snp.top)
            }else {
                make.top.equalTo(0)
            }
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
                .offset(-scrollBottomH)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(2)
            make.top.equalTo(webView)
        }
    }
    
    func updateWebViewLayout() {
        webView.snp.updateConstraints { (make) in
            make.bottom
                .equalTo(view.dzyLayout.snp.bottom)
                .offset(-scrollBottomH)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let temp = object as? WKWebView,
            temp == webView,
            keyPath == "estimatedProgress"
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let newProgress = change?[.newKey] as? Float {
            if progressView.isHidden {
                progressView.isHidden = false
            }
            progressView.setProgress(newProgress, animated: true)
            if newProgress == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.progressView.isHidden = true
                }
            }
        }
    }
    
    private lazy var progressView: UIProgressView = {
       let view = UIProgressView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 2))
        view.progressViewStyle = .bar
        view.tintColor = MainColor
        view.trackTintColor = .clear
        return view
    }()
}

extension TrainBaseVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.15, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}
