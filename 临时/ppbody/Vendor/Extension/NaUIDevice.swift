//
//  NaUIDevice.swift
//  WashCar
//
//  Created by Nathan_he on 2018/3/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
}
