//
//  PPHeroTransition+UIViewControllerTransitioningDelegate.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import UIKit

extension PPHeroTransition: UIViewControllerTransitioningDelegate {
    var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
        return forceNotInteractive ? nil : self
    }
    
    // 返回一个管理 present 动画过度的对象
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .notified
        self.isPresenting = true
        return self
    }
    
    // 返回一个管理 dismiss 动画过度的对象
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .notified
        self.isPresenting = false
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    // present
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

extension PPHeroTransition: UIViewControllerAnimatedTransitioning {
    // 完成所有动画事物
    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        fromViewController = context.viewController(forKey: .from)
        toViewController = context.viewController(forKey: .to)
        transitionContainer = context.containerView

        guard state == .notified else { return }
        state = .starting
        
        if let toView = toView, let fromView = fromView {
            if let toViewController = toViewController {
                toView.frame = context.finalFrame(for: toViewController)
            } else {
                toView.frame = fromView.frame
            }
            toView.setNeedsLayout()
            toView.layoutIfNeeded()
        }
        
        fullScreenSnapshot = transitionContainer?.window?.snapshotView(afterScreenUpdates: false) ?? fromView?.snapshotView(afterScreenUpdates: false)
        if let fullScreenSnapshot = fullScreenSnapshot {
            transitionContainer?.addSubview(fullScreenSnapshot)
        }
        
        if let toView = toView, let fromView = fromView {
            state = .animating
            transitionContainer?.addSubview(toView) // to
            transitionContainer?.bringSubviewToFront(fromView)
            toView.layer.transform = CATransform3DScale(toView.layer.transform, 0.7, 0.7, 1)
            
            UIView.animate(withDuration: 0.3, animations: {
                fromView.layer.transform = CATransform3DScale(fromView.layer.transform, 1.3, 1.3, 1)
                fromView.layer.opacity = 0
                toView.layer.transform = CATransform3DIdentity
            }) { (_) in
                fromView.layer.transform = CATransform3DIdentity
                fromView.layer.opacity = 1
                // 这里必须设置 nil 不然就循环引用了
                self.fromViewController = nil
                self.toViewController = nil
                self.fullScreenSnapshot?.removeFromSuperview()
                context.completeTransition(true)
            }
        }
    }
    
    // 动画时间
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // doesn't matter, real duration will be calculated later
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        state = .possible
    }
}

extension PPHeroTransition: UIViewControllerInteractiveTransitioning {
    public var wantsInteractiveStart: Bool {
        return true
    }
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}
