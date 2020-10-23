//
//  NaUIView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

extension UIView{
    
    public var na_width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    
    public var na_height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
    public var na_top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    public var na_right: CGFloat {
        get { return self.frame.origin.x + self.na_width }
        set { self.frame.origin.x = newValue - self.na_width }
    }
    public var na_bottom: CGFloat {
        get { return self.frame.origin.y + self.na_height }
        set { self.frame.origin.y = newValue - self.na_height }
    }
    public var na_left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    
    public var na_centerX: CGFloat{
        get { return self.center.x }
        set { self.center = CGPoint(x: newValue,y: self.na_centerY) }
    }
    public var na_centerY: CGFloat {
        get { return self.center.y }
        set { self.center = CGPoint(x: self.na_centerX,y: newValue) }
    }
    
    public var na_origin: CGPoint {
        set { self.frame.origin = newValue }
        get { return self.frame.origin }
    }
    public var na_size: CGSize {
        set { self.frame.size = newValue }
        get { return self.frame.size }
    }
}
