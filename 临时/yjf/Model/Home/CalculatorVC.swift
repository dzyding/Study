//
//  CalculatorVC.swift
//  YJF
//
//  Created by edz on 2019/8/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import WebKit
import ZKProgressHUD

class CalculatorVC: BaseVC {
    
    private let type: FunType
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()
    
    init(_ type: FunType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        
        var url: String?
        var title: String?
        switch type {
        case .loans:
            title = "贷款计算器"
            url = "https://www2.ejfun.com/yjf_H5/#/calculator"
        case .buyCompute:
            title = "买房税费计算器"
            url = "https://www2.ejfun.com/yjf_H5/#/buyhouse"
        case .sellCompute:
            title = "卖房税费计算器"
            url = "https://www2.ejfun.com/yjf_H5/#/sellhouse"
        default:
            break
        }
        _ = title.flatMap({navigationItem.title = $0})
        _ = url.flatMap(URL.init)
            .flatMap({URLRequest(url: $0)})
            .map(webView.load)
        
        webView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(view.dzyLayout.snp.top)
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
        }
    }
}

extension CalculatorVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ZKProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ZKProgressHUD.dismiss()
    }
}

