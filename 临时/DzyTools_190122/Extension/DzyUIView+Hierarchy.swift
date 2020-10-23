//
//  DzyUIView+Hierarchy.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import UIKit

public extension UIView {
    /**
     获取当前View所属控制器
     */
    public func viewController() -> UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
    
    /**
     获取最底层的控制器
     */
    public func topMostController() -> UIViewController? {
        
        var controllersHierarchy = [UIViewController]()
        
        if var topController = window?.rootViewController {
            controllersHierarchy.append(topController)
            
            //模态的视图
            while topController.presentedViewController != nil {
                
                topController = topController.presentedViewController!
                
                controllersHierarchy.append(topController)
            }
            
            var matchController :UIResponder? = viewController()
            
            while matchController != nil && controllersHierarchy.contains(matchController as! UIViewController) == false {
                
                repeat {
                    matchController = matchController?.next
                    
                } while matchController != nil && matchController is UIViewController == false
            }
            
            return matchController as? UIViewController
            
        } else {
            return viewController()
        }
    }
    
    /**
     Returns the superView of provided class type.
     */
    public func superviewOfClassType(_ classType:UIView.Type)->UIView? {
        
        var superView = superview
        
        while let unwrappedSuperView = superView {
            
            if unwrappedSuperView.isKind(of: classType) {
                
                //If it's UIScrollView, then validating for special cases
                if unwrappedSuperView.isKind(of: UIScrollView.self) {
                    
                    let classNameString = NSStringFromClass(type(of:unwrappedSuperView.self))
                    
                    //  If it's not UITableViewWrapperView class, this is internal class which is actually manage in UITableview. The speciality of this class is that it's superview is UITableView.
                    //  If it's not UITableViewCellScrollView class, this is internal class which is actually manage in UITableviewCell. The speciality of this class is that it's superview is UITableViewCell.
                    //If it's not _UIQueuingScrollView class, actually we validate for _ prefix which usually used by Apple internal classes
                    if unwrappedSuperView.superview?.isKind(of: UITableView.self) == false &&
                        unwrappedSuperView.superview?.isKind(of: UITableViewCell.self) == false &&
                        classNameString.hasPrefix("_") == false {
                        return superView
                    }
                }
                else {
                    return superView
                }
            }
            
            superView = unwrappedSuperView.superview
        }
        
        return nil
    }
    
    fileprivate func DzycanBecomeFirstResponder() -> Bool {
        
        var DzycanBecomeFirstResponder = false
        
        //  Setting toolbar to keyboard.
        if let textField = self as? UITextField {
            DzycanBecomeFirstResponder = textField.isEnabled
        } else if let textView = self as? UITextView {
            DzycanBecomeFirstResponder = textView.isEditable
        }
        
        if DzycanBecomeFirstResponder == true {
            DzycanBecomeFirstResponder = (isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 && isAlertViewTextField() == false && isSearchBarTextField() == false) as Bool
        }
        
        return DzycanBecomeFirstResponder
    }
    
    /**
     判断是否属于SearchBar
     */
    public func isSearchBarTextField()-> Bool {
        
        var searchBar : UIResponder? = self.next
        
        var isSearchBarTextField = false
        
        while searchBar != nil && isSearchBarTextField == false {
            
            if searchBar!.isKind(of: UISearchBar.self) {
                isSearchBarTextField = true
                break
            } else if searchBar is UIViewController {
                break
            }
            
            searchBar = searchBar?.next
        }
        
        return isSearchBarTextField
    }
    
    /**
     判断是否属于UIAlertController
     */
    public func isAlertViewTextField()->Bool {
        
        var alertViewController : UIResponder? = self.viewController()
        
        var isAlertViewTextField = false
        
        while alertViewController != nil && isAlertViewTextField == false {
            
            if alertViewController!.isKind(of: UIAlertController.self) {
                isAlertViewTextField = true
                break
            }
            
            alertViewController = alertViewController?.next
        }
        
        return isAlertViewTextField
    }
    
    /**
     Returns current view transform with respect to the 'toView'.
     */
    public func convertTransformToView(_ toView:UIView?)->CGAffineTransform {
        
        var newView = toView
        
        if newView == nil {
            newView = window
        }
        
        //My Transform
        var myTransform = CGAffineTransform.identity
        
        if let superView = superview {
            myTransform = transform.concatenating(superView.convertTransformToView(nil))
        } else {
            myTransform = transform
        }
        
        var viewTransform = CGAffineTransform.identity
        
        //view Transform
        if let unwrappedToView = newView {
            
            if let unwrappedSuperView = unwrappedToView.superview {
                viewTransform = unwrappedToView.transform.concatenating(unwrappedSuperView.convertTransformToView(nil))
            }
            else {
                viewTransform = unwrappedToView.transform
            }
        }
        
        //Concating MyTransform and ViewTransform
        return myTransform.concatenating(viewTransform.inverted())
    }
}
