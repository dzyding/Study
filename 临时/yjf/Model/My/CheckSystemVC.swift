//
//  CheckSystemVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CheckSystemVC: BaseVC {
    
    @IBOutlet weak var currentLB: UILabel!
    
    @IBOutlet weak var onlineLB: UILabel!
    /// 75 or 18
    @IBOutlet weak var onlineLBRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    private var showHandler: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "检查新版本"
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        appVersionApi()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        showHandler?()
    }
    
    func appRefreshAction(_ webUrl: String, version: String) {
        func showAlert() {
            let versionStr = "好消息！现在可以免费下载新版本了。"
            updateBtn.isHidden = false
            showHandler = { [weak self] in
                let alert = dzy_normalAlert(
                    "获取更新!",
                    msg: versionStr,
                    sureClick:
                { (_) in
                    if  let str = webUrl
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let url = URL(string: str)
                    {
                        UIApplication.shared.open(url)
                    }
                }, cancelClick: nil)
                self?.present(alert,
                             animated: true,
                             completion: nil)
            }
        }
        guard let local = Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String
            else {return}
        currentLB.text = local
        onlineLB.text = version
        let webArr = version.components(separatedBy: ".")
        
        let localArr = local.components(separatedBy: ".")
        guard webArr.count == 3 && localArr.count == 3 else {return}
        var result: [ComparisonResult] = []
        for index in (0..<3) {
            let web = NSDecimalNumber(string: webArr[index])
            let local = NSDecimalNumber(string: localArr[index])
            result.append(web.compare(local))
        }
        guard result.count == 3 else {return}
        if result[0] == .orderedDescending {
            showAlert()
        }else if result[0] == .orderedSame &&
            result[1] == .orderedDescending
        {
            showAlert()
        }else if result[0] == .orderedSame &&
            result[1] == .orderedSame &&
            result[2] == .orderedDescending
        {
            showAlert()
        }
    }
    
    private func appVersionApi() {
        let request = BaseRequest()
        request.url = BaseURL.appVersion
        request.dic = ["type" : 1]
        request.dzy_start { (data, _) in
            guard let url = data?.stringValue("url"),
                let version = data?.stringValue("version")
            else {return}
            self.appRefreshAction(url, version: version)
        }
    }
}
