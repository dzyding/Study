//
//  LockManager.swift
//  YJF
//
//  Created by edz on 2019/6/27.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol LockManagerDelegate: class {
    /// 开锁成功
    func lockManager(_ lockManager: LockManager, didOpenLock lock: String)
    /// 连接成功
    func connectSuccess(_ lockManager: LockManager)
    /// 更新状态
    func lockManager(_ lockManager: LockManager, updateMsg msg: String)
    /// 开锁失败
    func lockManager(_ lockManager: LockManager, openFailed msg: String)
}

class LockManager {
    // 就是个快捷方式
    static var delegate: LockManagerDelegate? {
        set {
            LockManager.default.delegate = newValue
        }
        get {
            return LockManager.default.delegate
        }
    }
    // 真正的代理属性
    private weak var delegate: LockManagerDelegate?
    // 锁的 key
    private var lock: String = ""
    // 实际的单例
    static var `default` = LockManager()
    // 快捷方式
    private static var BaseManager: JCWLBluetoothSDKManager {
        return LockManager.default.base
    }
    
    //    MARK: - 连接
    static func connect(_ lock: String) {
        LockManager.default.lock = lock
        BaseManager.scanAndConectDeviceWothIdentifer(lock)
    }
    
    //    MARK: - 断开连接
    static func disConnect() {
        BaseManager.disconneted()
    }
    
    //    MARK: - 开锁
    static func unlock() {
        BaseManager.unlockingDevice()
    }
    
//    MARK: - 更新 key
    static func update(_ secretKey: String) {
        UserDefaults.standard
            .setValue(secretKey, forKey: "KJCWLAESSAVEKEY")
    }
    
    //    MARK: - 核心 manager
    private lazy var base: JCWLBluetoothSDKManager = {
        let manager = JCWLBluetoothSDKManager.shareInstance()
        manager.callBack = { [unowned self] (state: callBackState) in
            switch state {
            case .finding:
                self.delegate?.lockManager(self, updateMsg: "蓝牙正在搜索设备")
            case .systemReadly:
                self.delegate?.lockManager(self, updateMsg: "蓝牙已开启")
            case .deviceFounded:
                self.delegate?.lockManager(self, updateMsg: "设备已被发现")
            case .openTring:
                self.delegate?.lockManager(self, updateMsg: "蓝牙正在开启")
            case .deviceBeginConnet:
                self.delegate?.lockManager(self, updateMsg: "开始连接设备")
            case .deviceConnected: //"设备连接成功"
                self.delegate?.lockManager(self, updateMsg: "设备连接成功")
            case .disconected:
                self.delegate?.lockManager(self, updateMsg: "蓝牙断开")
            case .unlocking:
                self.delegate?.lockManager(self, updateMsg: "开锁中")
            case .unlockingSuccess: // 开锁成功
                self.delegate?.lockManager(self, didOpenLock: self.lock)
            case .notConnect:
                self.delegate?.lockManager(self, updateMsg: "设备未连接")
            case .confirmDivice:
                self.delegate?.lockManager(self, updateMsg: "认证设备")
            case .confirmDiviceFinished: // 认证成功
                self.delegate?.connectSuccess(self)
            case .connectFailure:
                self.delegate?.lockManager(self, openFailed: "连接失败")
            case .unlockingFailure:
                self.delegate?.lockManager(self, openFailed: "开锁失败")
            case .timeOut:
                self.delegate?.lockManager(self, openFailed: "搜索超时")
            case .bleUnEnable: //其实不如果没开启，不会执行开锁方法
                self.delegate?.lockManager(self, openFailed: "蓝牙未开启")
//            case .updateAESSuccess:
//                print("密钥成功")
//            case .updateFailure:
//                print("密钥失败")
                //            case .resetDevice:
                //                self.delegate?.lockManager(self, updateMsg: "开始恢复出厂设置")
                //            case .resetDeviceSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "恢复出厂设置成功")
                //            case .resetDeviceFailure:
                //                self.delegate?.lockManager(self, updateMsg: "恢复出厂设置失败")
                //            case .pwdKeyboardInspectionSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "密码键盘自检成功")
                //            case .pwdKeyboardInspectionFailure:
                //                self.delegate?.lockManager(self, updateMsg: "密码键盘自检失败")
                //            case .nbInspectionSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "NB自检成功")
                //            case .nbInspectionFailure:
                //                self.delegate?.lockManager(self, updateMsg: "NB自检失败")
                //            case .batteryInspectionSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "电池盖自检成功")
                //            case .batteryInspectionFailure:
                //                self.delegate?.lockManager(self, updateMsg: "电池盖自检失败")
                //            case .tamperInspectionSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "防拆自检成功")
                //            case .tamperInspectionFailure:
                //                self.delegate?.lockManager(self, updateMsg: "防拆自检失败")
                //            case .lockStatusInspectionSuccess:
                //                self.delegate?.lockManager(self, updateMsg: "锁体状态自检成功")
                //            case .lockStatusInspectionFailure:
                //                self.delegate?.lockManager(self, updateMsg: "锁体状态自检失败")
                //            case .deviceInspectionOn:
                //                self.delegate?.lockManager(self, updateMsg: "自检准备就绪")
                //            case .deviceInspectionOff:
            //                self.delegate?.lockManager(self, updateMsg: "自检准备未就绪")
            default:
                self.delegate?.lockManager(self, openFailed: "未知状态")
            }
        }
        return manager
    }()
}
