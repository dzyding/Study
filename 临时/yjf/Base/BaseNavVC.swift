//
//  BaseNavVC.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/22.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit

class BaseNavVC: UINavigationController, ObserverVCProtocol {
    
    var observers: [[Any?]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        view.backgroundColor = .white
        modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        registObservers([PublicConfig.Notice_TokenTimeOut]) { [weak self] in
            self?.dissMissFunc()
        }
    }
    
    func dissMissFunc() {
        if DataManager.user() == nil {return}
        DataManager.logout()
        if let preVCs = presentedViewController {
            preVCs.dismiss(animated: true, completion: nil)
        }
        
        let loginVC = LoginRegistBaseVC(.topCustom)
        loginVC.isTimeOut = true
        let vc = BaseNavVC(rootViewController: loginVC)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    deinit {
        deinitObservers()
    }
}

extension BaseNavVC{
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
