//
//  PPHeroTransition+UINavigationControllerDelegate.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import UIKit

extension PPHeroTransition: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let previousNavigationDelegate = navigationController.pp_previousNavigationDelegate {
            previousNavigationDelegate.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let previousNavigationDelegate = navigationController.pp_previousNavigationDelegate {
            previousNavigationDelegate.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .notified
        self.isPresenting = operation == .push
        self.fromViewController = fromViewController ?? fromVC
        self.toViewController = toViewController ?? toVC
        self.inNavigationController = true
        return self
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}
