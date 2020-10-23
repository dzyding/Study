//
//  UIViewController+PPHero.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import UIKit

internal class PPHeroViewControllerConfig: NSObject {
    var storedSnapshot: UIView?
    weak var previousNavigationDelegate: UINavigationControllerDelegate?
    weak var previousTabBarDelegate: UITabBarControllerDelegate?
}

extension UIViewController: PPHeroCompatible { }

public extension PPHeroExtension where Base: UIViewController {
    
    internal var config: PPHeroViewControllerConfig {
        get {
            if let config = objc_getAssociatedObject(base, &type(of: base).PPAssociatedKeys.ppheroConfig) as? PPHeroViewControllerConfig {
                return config
            }
            let config = PPHeroViewControllerConfig()
            self.config = config
            return config
        }
        set { objc_setAssociatedObject(base, &type(of: base).PPAssociatedKeys.ppheroConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// used for .overFullScreen presentation
    internal var storedSnapshot: UIView? {
        get { return config.storedSnapshot }
        set { config.storedSnapshot = newValue }
    }
    
    // TODO: can be moved to internal later (will still be accessible via IB)
    var isEnabled: Bool {
        get {
            return base.transitioningDelegate is PPHeroTransition
        }
        set {
            guard newValue != isEnabled else { return }
            if newValue {
                // 主要是更换当前 VC 的 transitioningDelegate，以及存储之前 UINavi 或者 UITabBar 的 delegate
                base.transitioningDelegate = PPHero.shared
                if let navi = base as? UINavigationController {
                    base.pp_previousNavigationDelegate = navi.delegate
                    navi.delegate = PPHero.shared
                }
                if let tab = base as? UITabBarController {
                    base.pp_previousTabBarDelegate = tab.delegate
                    tab.delegate = PPHero.shared
                }
            } else {
                base.transitioningDelegate = nil
                if let navi = base as? UINavigationController, navi.delegate is PPHeroTransition {
                    navi.delegate = base.pp_previousNavigationDelegate
                }
                if let tab = base as? UITabBarController, tab.delegate is PPHeroTransition {
                    tab.delegate = base.pp_previousTabBarDelegate
                }
            }
        }
    }
}

public extension UIViewController {
    fileprivate struct PPAssociatedKeys {
        static var ppheroConfig = "ppheroConfig"
    }
    
    internal var pp_previousNavigationDelegate: UINavigationControllerDelegate? {
        get { return pphero.config.previousNavigationDelegate }
        set { pphero.config.previousNavigationDelegate = newValue }
    }
    
    internal var pp_previousTabBarDelegate: UITabBarControllerDelegate? {
        get { return pphero.config.previousTabBarDelegate }
        set { pphero.config.previousTabBarDelegate = newValue }
    }
    
    @IBInspectable var isppHeroEnabled: Bool {
        get { return pphero.isEnabled }
        set { pphero.isEnabled = newValue }
    }
}

public extension PPHeroExtension where Base: UIViewController {
    
    /**
     Dismiss the current view controller with animation. Will perform a navigationController.popViewController
     if the current view controller is contained inside a navigationController
     */
    func dismissViewController(completion: (() -> Void)? = nil) {
        if let navigationController = base.navigationController, navigationController.viewControllers.first != base {
            navigationController.popViewController(animated: true)
        } else {
            base.dismiss(animated: true, completion: completion)
        }
    }
}
