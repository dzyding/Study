//
//  PPHeroTransition.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import UIKit

public class PPHero: NSObject {
    /// Shared singleton object for controlling the transition
    public static var shared = PPHeroTransition()
}

open class PPHeroTransition: NSObject {
    
    public internal(set) var state: PPHeroTransitionState = .possible
    
    public var isTransitioning: Bool { return state != .possible }
    public internal(set) var isPresenting: Bool = true
    
    /// this is the container supplied by UIKit
    internal var transitionContainer: UIView?
    
    /// destination view controller
    public internal(set) var toViewController: UIViewController?
    /// source view controller
    public internal(set) var fromViewController: UIViewController?
    
    internal var fullScreenSnapshot: UIView?
    
    // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
    // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with
    // UINavigationController.setViewControllers not able to handle interactive transition
    internal var forceNotInteractive = false
    
    internal var inNavigationController = false
    internal var inTabBarController = false
    internal var inContainerController: Bool {
        return inNavigationController || inTabBarController
    }
    
    internal var toView: UIView? { return toViewController?.view }
    internal var fromView: UIView? { return fromViewController?.view }
    
    public override init() { super.init() }

}
