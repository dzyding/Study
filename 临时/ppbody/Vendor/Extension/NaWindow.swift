//
//  NaWindow.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    func topMostWindowController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostWindowController.    */
    func currentViewController()->UIViewController? {
        
        var currentViewController = topMostWindowController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}
