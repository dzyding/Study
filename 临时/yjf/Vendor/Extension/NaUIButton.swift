//
//  NaUIButton.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

extension UIButton
{
    public struct AssociatedKeys{
        
        static var defaultInterval : TimeInterval = 1 //间隔时间
        
        static var A_customInterval = "customInterval"
        
        static var A_ignoreInterval = "ignoreInterval"
        
    }
    
    var customInterval: TimeInterval{
        get{
            let A_customInterval = objc_getAssociatedObject(self, &AssociatedKeys.A_customInterval)
            if let time = A_customInterval{
                // swiftlint:disable:next force_cast
                return time as! TimeInterval
                
            }else{
                return AssociatedKeys.defaultInterval
            }
        }
        set{
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.A_customInterval,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var enableInterval: Bool{
        get {
            return (
                objc_getAssociatedObject(
                    self,
                    &AssociatedKeys.A_ignoreInterval
                    ) != nil
            )
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.A_ignoreInterval,
                newValue,
                .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }
    
    //由于在swift4中 initialize（）这个方法已经被废弃了  所以需要自己写一个方法，并在Appdelegate 中调用此方法
    public class func initializeMethod(){
        if self == UIButton.self{
            let systemSel = #selector(UIButton.sendAction(_:to:for:))
            let sSel = #selector(UIButton.mySendAction(_: to: for:))
            let systemMethod = class_getInstanceMethod(self, systemSel)
            let sMethod = class_getInstanceMethod(self, sSel)
            let isTrue = class_addMethod(
                self,
                systemSel,
                method_getImplementation(sMethod!),
                method_getTypeEncoding(sMethod!)
            )
            if isTrue{
                class_replaceMethod(
                    self,
                    sSel,
                    method_getImplementation(systemMethod!),
                    method_getTypeEncoding(systemMethod!)
                )
            }else{
                method_exchangeImplementations(systemMethod!, sMethod!)
            }
        }
        
    }
    
    @objc private dynamic func mySendAction(_ action: Selector, to target: Any?, for event: UIEvent?){
        if enableInterval{
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + customInterval,
                execute:
            {
                self.isUserInteractionEnabled = true
            })
        }
        mySendAction(action, to: target, for: event)
        
    }
}
