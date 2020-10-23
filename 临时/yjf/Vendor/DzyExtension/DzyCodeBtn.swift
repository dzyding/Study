//
//  DzyCodeBtn.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/8/11.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

public let Timer_long: UInt = 59

enum PhoneCodeType {
    /// 登陆
    case login
    /// 注册
    case regist
    /// 忘记密码
    case fPwd
    /// 认证
    case cer
    /// 更新密码第一个界面
    case upf
    /// 更新密码第二个界面
    case ups
}

/// 管理所有验证码类型的时长
fileprivate struct PhoneCodeManager {
    
    static var `default` = PhoneCodeManager()
    
    // 登陆
    var login: UInt = Timer_long
    
    var loginTimer: Timer? {
        willSet {
            loginTimer?.invalidate()
        }
    }
    
    // 注册
    var regist: UInt = Timer_long
    
    var registTimer: Timer? {
        willSet {
            registTimer?.invalidate()
        }
    }
    
    // 忘记密码
    var fPwd: UInt = Timer_long
    
    var fPwdTimer: Timer? {
        willSet {
            fPwdTimer?.invalidate()
        }
    }
    
    // 认证
    var cer: UInt = Timer_long
    
    var cerTimer: Timer? {
        willSet {
            cerTimer?.invalidate()
        }
    }
    
    // 更改手机号的第一步
    var upf: UInt = Timer_long
    
    var upfTimer: Timer? {
        willSet {
            upfTimer?.invalidate()
        }
    }
    
    // 更改手机号的第二步
    var ups: UInt = Timer_long
    
    var upsTimer: Timer? {
        willSet {
            upsTimer?.invalidate()
        }
    }
}

class DzyCodeBtn: UIButton {
    
    private var type: PhoneCodeType = .login
    
    fileprivate var time: UInt {
        get {
            switch type {
            case .login:
                return PhoneCodeManager.default.login
            case .regist:
                return PhoneCodeManager.default.regist
            case .fPwd:
                return PhoneCodeManager.default.fPwd
            case .cer:
                return PhoneCodeManager.default.cer
            case .upf:
                return PhoneCodeManager.default.upf
            case .ups:
                return PhoneCodeManager.default.ups
            }
        }
        set {
            switch type {
            case .login:
                PhoneCodeManager.default.login = newValue
            case .regist:
                PhoneCodeManager.default.regist = newValue
            case .fPwd:
                PhoneCodeManager.default.fPwd = newValue
            case .cer:
                PhoneCodeManager.default.cer = newValue
            case .upf:
                PhoneCodeManager.default.upf = newValue
            case .ups:
                PhoneCodeManager.default.ups = newValue
            }
        }
    }
    fileprivate var timer: Timer? {
        get {
            switch type {
            case .login:
                return PhoneCodeManager.default.loginTimer
            case .regist:
                return PhoneCodeManager.default.registTimer
            case .fPwd:
                return PhoneCodeManager.default.fPwdTimer
            case .cer:
                return PhoneCodeManager.default.cerTimer
            case .upf:
                return PhoneCodeManager.default.upfTimer
            case .ups:
                return PhoneCodeManager.default.upsTimer
            }
        }
        set {
            switch type {
            case .login:
                PhoneCodeManager.default.loginTimer = newValue
            case .regist:
                PhoneCodeManager.default.registTimer = newValue
            case .fPwd:
                PhoneCodeManager.default.fPwdTimer = newValue
            case .cer:
                PhoneCodeManager.default.cerTimer = newValue
            case .upf:
                PhoneCodeManager.default.upfTimer = newValue
            case .ups:
                PhoneCodeManager.default.upsTimer = newValue
            }
        }
    }
    /// 默认状态
    private var normal = "获取验证码"
    /// 结束状态
    private var stop = "重新发送"
    /// 发送时
    private var sending = "后获取"
    /// 发送时是否添加文字前缀
    @IBInspectable var sendingIfHasText: Bool = false
    
    func checkTimer(_ type: PhoneCodeType) {
        self.type = type
        if time != Timer_long {
            beginTimer(type)
        }
    }
    
    func beginTimer(_ type: PhoneCodeType) {
        self.type = type
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timeChange), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        isUserInteractionEnabled = false
    }
    
    @objc private func timeChange() {
        if time <= 0 {
            stopTimer()
        }else{
            let text = sendingIfHasText ? ("\(time)秒" + sending) : "\(time)s"
            setTitle(text, for: .normal)
            time -= 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        time = Timer_long
        isUserInteractionEnabled = true
        setTitle(stop, for: .normal)
    }
    
    func originTimer() { 
        time = Timer_long
        isUserInteractionEnabled = true
        setTitle(normal, for: .normal)
    }
    
    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
}
