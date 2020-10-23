//
//  LoginRegistBaseVC.swift
//  YJF
//
//  Created by edz on 2019/4/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class LoginRegistBaseVC: ScrollBtnVC, CustomBackProtocol {
    
    override var normalFont: UIFont {
        return dzy_Font(14)
    }
    
    override var selectedFont: UIFont {
        return dzy_Font(17)
    }
    
    override var titles: [String] {
        return ["登录", "注册"]
    }
    
    override var btnsViewTopHeight: CGFloat {
        return 100.0
    }
    /// 推广码
    var code: String?
    
    /// 是否登陆过期
    var isTimeOut: Bool = false
    
    // 扫一扫
    lazy var sysBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "login_saoyisao"), for: .normal)
        btn.addTarget(self, action: #selector(sysAction), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dzy_removeChildVCs([AppGuideVC.self])
        updateVCs()
        view.addSubview(sysBtn)
        sysBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(45)
            make.top.equalTo(view.dzyLayout.snp.top)
            make.right.equalTo(-10)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isTimeOut {
            isTimeOut = false
            showMessage("登陆过期，请重新登录！")
        }
    }
    
    @objc func sysAction() {
        let handler: ((String)->()) = { str in
            if let tempArr = str.components(separatedBy: "?").last?
                .components(separatedBy: "&").first?
                .components(separatedBy: "="),
                tempArr.count == 2,
                tempArr.first == "code",
                let code = tempArr.last
            {
                DispatchQueue.main.async { [weak self] in
                    self?.showMessage("获取推广码成功")
                    self?.code = code
                    self?.updateSelectedBtn(1)
                }
            }
        }
        let vc = QRCodeVC(handler)
        dzy_push(vc)
    }
    
    override func getVCs() -> [UIViewController] {
        return [LoginVC(), RegistVC()]
    }
}
