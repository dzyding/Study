//
//  DzyViewExtension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/7/12.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var dzy_w:CGFloat {
        return bounds.size.width
    }
    
    var dzy_h:CGFloat {
        return bounds.size.height
    }
    
    var dzy_x:CGFloat {
        return frame.origin.x
    }
    
    var dzy_y:CGFloat {
        get {
            return frame.origin.y
        }set {
            var old = frame
            old.origin.y = newValue
            frame = old
        }
    }
}

extension UIScrollView {
    
    var dzy_ofx:CGFloat {
        get {
            return contentOffset.x
        }
        set {
            var offset = contentOffset
            offset.x = newValue
            contentOffset = offset
        }
    }
    
    var dzy_ofy:CGFloat {
        get {
            return contentOffset.y
        }
        set {
            var offset = contentOffset
            offset.y = newValue
            contentOffset = offset
        }
    }
    
    var dzy_inT:CGFloat {
        get {
            return contentInset.top
        }
        set {
            var inset = contentInset
            inset.top = newValue
            contentInset = inset
        }
    }
    
    var dzy_inB:CGFloat {
        get {
            return contentInset.bottom
        }
        set {
            var inset = contentInset
            inset.bottom = newValue
            contentInset = inset
        }
    }
    
    var dzy_inL:CGFloat {
        get {
            return contentInset.left
        }
        set {
            var inset = contentInset
            inset.left = newValue
            contentInset = inset
        }
    }
    
    var dzy_inR:CGFloat {
        get {
            return contentInset.right
        }
        set {
            var inset = contentInset
            inset.right = newValue
            contentInset = inset
        }
    }
    
    var dzy_cSizeW:CGFloat {
        get {
            return contentSize.width
        }
        set {
            var size = contentSize
            size.width = newValue
            contentSize = size
        }
    }
    
    var dzy_cSizeH:CGFloat {
        get {
            return contentSize.height
        }
        set {
            var size = contentSize
            size.height = newValue
            contentSize = size
        }
    }
}
