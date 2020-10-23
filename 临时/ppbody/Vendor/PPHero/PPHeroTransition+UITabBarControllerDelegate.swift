//
//  PPHeroTransition+UITabBarControllerDelegate.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import UIKit

extension PPHeroTransition: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard tabBarController.selectedViewController !== viewController else {
            return false
        }
        if isTransitioning {
            // 需要做一些初始化的事情
//            cancel(animate: false)
        }
        return true
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .notified
        let fromVCIndex = tabBarController.children.firstIndex(of: fromVC)!
        let toVCIndex = tabBarController.children.firstIndex(of: toVC)!
        self.isPresenting = toVCIndex > fromVCIndex
        self.fromViewController = fromViewController ?? fromVC
        self.toViewController = toViewController ?? toVC
        self.inTabBarController = true
        return self
    }
}
