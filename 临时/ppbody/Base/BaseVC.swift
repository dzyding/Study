//
//  BaseVC.swift
//  ZAJA
//
//  Created by Nathan_he on 16/9/26.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit


//处理导航栏上面所有的按钮
open class BaseVC : UIViewController
{
    public var isHideBar = false //是否隐藏导航栏
    
    //数据字典
    var dataDic = [String:Any]()
    //数据list
    var dataArr = [[String:Any]]()
    //分页数据
    var page : Dictionary<String,Any>? //分页
    //当前页数
    var currentPage : Int? {
        return self.page?["currentPage"] as? Int
    }
    //总页数
    var totalPage : Int? {
        return self.page?["totalPage"] as? Int
    }
    //总数
    var totalNum : Int? {
        return self.page?["totalNum"] as? Int
    }

    var toast: Toast?
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //关联VC 给 Toast
        Toaster.sharedInstance.defaultViewController = self
    }
    
    lazy var loader: UIView = {
        let loadingView = UIView(frame: ScreenBounds)
        loadingView.backgroundColor = UIColor.white
        let loader = Loader(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 30.0))
        loader.loaderColor = ToolClass.YellowMainColor
        loader.switchColor = UIColor.white
        loader.startAnimating()
        loadingView.addSubview(loader)
        loader.center = loadingView.center
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissLoading)))
        
        return loadingView
    }()
    
    
    func showLoading()
    {
//        loader.alpha = 1
//        UIApplication.shared.keyWindow?.addSubview(loader)
        toast = ToolClass.showToast(.Progress)
        
    }
    
    @objc func dismissLoading()
    {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.loader.alpha = 0
//        }) { (finish) in
//            self.loader.removeFromSuperview()
//        }
        toast?.dismiss()
    }
    

    
    // 设置白色返回按钮
    func setBackWhiteItem()
    {
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_n")
        
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_n")
        

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(NSStringFromClass(type(of: self))) : dealloc")
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        setBackWhiteItem()
        let attribute = [NSAttributedString.Key.font: ToolClass.CustomFont(14)]
        navigationItem.leftBarButtonItem?
            .setTitleTextAttributes(attribute, for: .normal)
        navigationItem.rightBarButtonItem?
            .setTitleTextAttributes(attribute, for: .normal)
    }
    
    //返回按钮
    func backAction()
    {
        if self.navigationController == nil
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        
        if self.navigationController?.children.count == 1
        {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }
}
