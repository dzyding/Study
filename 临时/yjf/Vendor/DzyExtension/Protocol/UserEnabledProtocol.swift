//
//  UserEnabledProtocol.swift
//  YJF
//
//  Created by edz on 2019/6/28.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol UserEnabledProtocol where Self: UIView {
    var enabledTime: Int {get set}
    /// 检查是否需要禁用一会
    func updateEnabledStatus()
}

extension UserEnabledProtocol {
    func updateEnabledStatus() {
        if enabledTime > 0 {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(enabledTime)
            ) {
                self.isUserInteractionEnabled = true
            }
        }
    }
}

class DzySafeBtn: UIButton, UserEnabledProtocol {
    
    @IBInspectable var enabledTime: Int = 0
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        updateEnabledStatus()
    }
}
