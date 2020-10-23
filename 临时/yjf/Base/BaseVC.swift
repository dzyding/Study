//
//  BaseVC.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/21.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit
import ZKProgressHUD

class BaseVC: UIViewController {
    
    public var isHideBar = false //是否隐藏导航栏
    
    private var barstyle = UIBarStyle.default
    
    private var titleAttributeColor = UIColor.white

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?
            .navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.clipsToBounds = true
        setTitleAtttributes(color: .black)
        setBackItem(image: UIImage(named: "back")!)
        modalPresentationStyle = .fullScreen
    }
    
    //设置导航栏标题
    private func setTitleAtttributes(color:UIColor) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
    }

    // 设置返回按钮
    private func setBackItem(image:UIImage) {
        let btn = UIButton(type: .custom)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(
            top: 0, left: -20, bottom: 0, right: 0
        )
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.addTarget(
            self, action: #selector(backAction), for: .touchUpInside
        )
        let back = UIBarButtonItem(customView: btn)
        navigationItem.backBarButtonItem = back
        
        navigationController?
            .navigationBar
            .backIndicatorImage = image.withRenderingMode(.alwaysOriginal)
        navigationController?
            .navigationBar
            .backIndicatorTransitionMaskImage = image.withRenderingMode(.alwaysOriginal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Toaster.sharedInstance.defaultViewController = self
        super.viewWillAppear(animated)
    }
    
    //返回按钮
    @objc func backAction() {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if self.navigationController?.children.count == 1 {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 显示提示信息
    func showMessage(_ str: String) {
        ZKProgressHUD.showMessage(str)
    }
    
    deinit {
        dzy_log(NSStringFromClass(type(of: self)) + " 销毁")
    }
}
