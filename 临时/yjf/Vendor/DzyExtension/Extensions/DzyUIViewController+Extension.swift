//
//  DzyUIViewController+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation
import UIKit

private let BackImage = "back"

extension UIViewController {
    
    //MARK: - navi跳转相关
    func dzy_push(_ vc:UIViewController, hide:Bool = false, animated:Bool = true) {
        if hide {
            vc.hidesBottomBarWhenPushed = hide
        }
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func dzy_delayPop(_ delay: TimeInterval, animated: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.dzy_pop(animated)
        }
    }
    
    func dzy_delayCustomPopOrPop<T: UIViewController>(_ delay: TimeInterval, cls: T.Type, animated: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.dzy_customPopOrPop(cls, animated: animated)
        }
    }
    
    func dzy_customPopOrPop<T: UIViewController>(_ cls: T.Type, animated: Bool = true) {
        if !dzy_customPop(T.self, animated: animated) {
            dzy_pop(animated)
        }
    }
    
    func dzy_customPopOrRootPop<T: UIViewController>(_ cls: T.Type, animated: Bool = true) {
        if !dzy_customPop(T.self, animated: animated) {
            dzy_popRoot(animated)
        }
    }
    
    fileprivate func dzy_customPop<T: UIViewController>(_ cls: T.Type, animated: Bool = true) -> Bool {
        let vcs = navigationController?.viewControllers ?? []
        for vc in vcs where vc is T {
            navigationController?.popToViewController(vc, animated: animated)
            return true
        }
        return false
    }
    
    func dzy_pop(_ animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func dzy_popRoot(_ animated:Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    func dzy_title(_ str: String) {
        navigationItem.title = str
    }
    
    func dzy_adjustsScrollViewInsets(_ scrollView: UIScrollView? = nil) {
        if #available(iOS 11.0, *) {
            if let scrollView = scrollView {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    /* 我们项目里面用不到
    func dzy_push(_ vc:UIViewController, hide:Bool = false, animated:Bool = true) {
        if hide {
            vc.hidesBottomBarWhenPushed = hide
        }
        if #available(iOS 11.0, *) {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: BackImage), for: .normal)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            btn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            //隐藏返回按钮中的文字
            navigationItem.backBarButtonItem = UIBarButtonItem(customView: btn)
        }
        navigationController?.pushViewController(vc, animated: animated)
    }
     */
}
