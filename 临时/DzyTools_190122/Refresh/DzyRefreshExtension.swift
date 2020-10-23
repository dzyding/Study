//
//  DzyRefreshExtension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/9/7.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

private var dzyHeaderKey: UInt8 = 99

private var dzyFooterKey: UInt8 = 77

enum ListRefreshType {
    case normal
    case header
    case footer
}

extension UIScrollView {
    var dzy_header: DzyRefreshHeaderView? {
        set {
            guard let newValue = newValue else {return}
            if self.dzy_header != newValue {
                dzy_header?.removeFromSuperview()
            }
            insertSubview(newValue, at: 0)
            willChangeValue(forKey: "dzy_header")
            objc_setAssociatedObject(self, &dzyHeaderKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: "dzy_header")
        }
        get {
            return objc_getAssociatedObject(self, &dzyHeaderKey) as? DzyRefreshHeaderView
        }
    }
    
    var dzy_footer: DzyRefreshFooterView? {
        set {
            guard let newValue = newValue else {return}
            if self.dzy_footer != newValue {
                dzy_footer?.removeFromSuperview()
            }
            insertSubview(newValue, at: 0)
            willChangeValue(forKey: "dzy_footer")
            objc_setAssociatedObject(self, &dzyFooterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            didChangeValue(forKey: "dzy_footer")
        }
        get {
            return objc_getAssociatedObject(self, &dzyFooterKey) as? DzyRefreshFooterView
        }
    }
    
    func dzy_headerEndRefresh() {
        dzy_header?.endRefreshing()
    }
    
    func dzy_footerEndRefresh() {
        dzy_footer?.endRefreshing()
    }
}
