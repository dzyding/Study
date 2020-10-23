//
//  UIView+Extension.swift
//  PPBody
//
//  Created by dzy_PC on 2018/11/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

extension UIView {
    var parentVC: UIViewController? {
        return ToolClass.controller2(view: self)
    }
}
