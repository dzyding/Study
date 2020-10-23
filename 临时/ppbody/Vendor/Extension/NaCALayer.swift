//
//  NaCALayer.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2016/12/5.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

extension CALayer
{
    //边框颜色
    @IBInspectable open var borderUIColor : UIColor {
        get{
            return UIColor.init(cgColor: self.borderColor!)
        }
        set{
            self.borderColor = newValue.cgColor
        }
    }
    
    //阴影颜色
    @IBInspectable open var shadowUIColor : UIColor
        {
        get{
            return UIColor.init(cgColor: self.shadowColor!)
        }
        set{
            self.shadowColor = newValue.cgColor
        }
    }
}
