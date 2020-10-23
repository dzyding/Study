//
//  BaseTabbarVC.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/22.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit
import ZKProgressHUD
import CoreBluetooth

class BaseTabbarVC: UITabBarController, CustomBackProtocol {
    
    //swiftlint:disable:next large_tuple
    private let datas: [(UIViewController, String, String, String)] = [
        (HomeVC(), "易间房", "tab_home", "tab_home_sel"),
        (ConsultVC(), "咨询", "tab_zx", "tab_zx_sel"),
        (MessageVC(), "消息", "tab_message", "tab_message_sel"),
        (PriceVC(.topTop), "市场行情", "tab_price", "tab_price_sel"),
        (MyVC(), "我的", "tab_my", "tab_my_sel")
    ]
    
    private lazy var locManager: CLLocationManager = CLLocationManager()
    
    private lazy var btManager: CBCentralManager = {
        let manager = CBCentralManager(delegate: self, queue: .main, options: [
            CBCentralManagerOptionShowPowerAlertKey : false
        ])
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatTabBar()
        tabBar.tintColor = MainColor
        modalPresentationStyle = .fullScreen
        setBackWhiteItem(image: UIImage(named: "back")!)
        dzy_removeChildVCs([AppGuideVC.self])
        
        locManager.requestWhenInUseAuthorization()
        dzy_log(btManager.state)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        updateUnreadMsg()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    func creatTabBar(){
        viewControllers = datas.map({ (vc, title, image, selImage) -> UIViewController in
            vc.tabBarItem.title = title
            vc.tabBarItem.image = UIImage(named: image)
            vc.tabBarItem.selectedImage = UIImage(named: selImage)
            return vc
        })
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "易间房" {
            let vc = CompanyInfoVC()
            present(vc, animated: true, completion: nil)
        }else if item.title == "首页" {
            item.title = "易间房"
        }else if item.title != "易间房" {
            viewControllers?.first?.tabBarItem.title = "首页"
        }
        updateUnreadMsg()
    }
    
    // 更新未读消息数量
    private func updateUnreadMsg() {
        PublicFunc.unreadMsgNumApi { [weak self] (num) in
            if let item = self?.tabBar.items?.first(where: {
                $0.title == "消息"
            }) {
                item.badgeValue = num > 0 ? "\(num)" : nil
            }
        }
    }
    
    // 设置返回按钮
    func setBackWhiteItem(image:UIImage) {
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = item
        
        navigationController?.navigationBar.backIndicatorImage = image.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = image.withRenderingMode(.alwaysOriginal)
    }
}

extension BaseTabbarVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}
