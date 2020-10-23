//
//  DzyCodeBtn.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/8/11.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

class DzyCodeBtn: UIButton {
    
    fileprivate var time: UInt = 0
    fileprivate var timer: Timer?
    /// 默认状态
    var normal: String = "点击发送"
    /// 结束状态
    var stop: String = "重新发送"
    /// 发送时
    var sending: String = "重新发送"
    /// 发送时是否添加文字前缀
    var sendingIfHasText: Bool = false
    
    func beginTimer() {
        time = 59
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timeChange), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        isUserInteractionEnabled = false
    }
    
    @objc func timeChange() {
        if (time == 0) {
            stopTimer()
        }else{
            let text = sendingIfHasText ? (sending + "(\(time)s)") : "\(time)s"
            setTitle(text, for: .normal)
        }
        time -= 1
    }
    
    func stopTimer() {
        time = 59
        timer?.invalidate()
        isUserInteractionEnabled = true
        setTitle(stop, for: .normal)
    }
    
    func originTimer() { 
        time = 59
        isUserInteractionEnabled = true
        setTitle(normal, for: .normal)
    }
    
    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
}
