//
//  WatchHouseTimeView.swift
//  YJF
//
//  Created by edz on 2019/5/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol WatchHouseTimeViewDelegate {
    /// 提示
    func timeView(_ timeView: WatchHouseTimeView, promptWithTime time: String, height: CGFloat)
    /// 警告
    func timeView(_ timeView: WatchHouseTimeView, warningWithTime time: String, height: CGFloat)
    /// 最大值
    func timeView(_ timeView: WatchHouseTimeView, maxWithTime time: String, height: CGFloat)
    /// 定位
    func timeView(_ timeView: WatchHouseTimeView, uploadLocationWithTime time: String)
    /// 卖家电话确认是否继续看房
    func timeView(_ timeView: WatchHouseTimeView, sellerCheckIsInWithTime time: String)
    /// 重新开锁
    func timeView(_ timeView: WatchHouseTimeView, reopenWithBtn btn: UIButton)
}

class WatchHouseTimeView: UIView {
    
    @IBOutlet private weak var openBtn: UIButton!
    
    @IBOutlet private weak var timeLB: UILabel!
    
    private var beginDate: Date?
    
    private var identity: Identity = .buyer
    
    /// 提示 ---
    @IBOutlet weak var warnView: UIView!
    /// 已经看房15分钟，请尽快查看了解，及时结束看房。
    @IBOutlet weak var warnLB: UILabel!
    
    private var isWarn = false
    
    private var warnTime: Int = 15
    
    /// 警告 ---
    @IBOutlet weak var earlyView: UIView!
    /// 已经看房XX分钟，还有5分钟将超时。超时费率1元/分钟。
    @IBOutlet weak var earlyLB: UILabel!
    
    private var isEarly = false
    
    private var earlyTime: Int = 25
    /// 上传定位
    private var isLocation = false
    
    /// 最大看房时间 ---
    @IBOutlet weak var maxView: UIView!
    
    private var isMax = false
    /// 已经看房30分钟。超时费率1元/分钟。请尽快退出关门，并确认结束看房。
    @IBOutlet weak var maxLB: UILabel!
    
    private var maxTime: Int = 30
    
    // ---
    /// 用来停止发送检查卖家是否在里面的请求
    var sellerIsIn: Bool = true
    /// 卖家超过 33 分钟以后用来计时的数据
    private var sellerCheckTime: Int = 0
    
    weak var delegate: WatchHouseTimeViewDelegate?
    
    deinit {
        stopTimer()
        dzy_log("销毁")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        openBtn.layer.cornerRadius = 3
        openBtn.layer.masksToBounds = true
        openBtn.layer.borderWidth = 1
        openBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
    }
    
    func initConfig(_ data: [String : Any], identity: Identity) {
        self.identity = identity
        let price = data.doubleValue("exceedPrice") ?? 1
        warnTime = data.intValue("warnTime") ?? 15
        earlyTime = data.intValue("earlyTime") ?? 25
        maxTime = (data.dicValue("lockOpenLog") ?? data.dicValue("lockOpen"))?.intValue("L") ?? 30
//        print("warnTime - \(warnTime), earlyTime - \(earlyTime), maxTime - \(maxTime)")
        warnLB.text = "已经看房\(warnTime)分钟，请尽快查看了解，及时结束看房。"
        earlyLB.text = "已经看房\(earlyTime)分钟，还有\(maxTime - earlyTime)分钟将超时。超时费率\(price.decimalStr)元/分钟。"
        maxLB.text = "已经看房\(maxTime)分钟。超时费率\(price.decimalStr)元/分钟。请尽快退出关门，并确认结束看房。"
    }
    
    func resetMsg(_ str: String) {
        setBeginDate(str)
        isLocation = false
        isWarn = false
        isEarly = false
        isMax = false
        warnView.isHidden = true
        earlyView.isHidden = true
        maxView.isHidden = true
    }

    func beginTimer(_ str: String) {
        setBeginDate(str)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func stopTimer() {
        timer.fire()
        timer.invalidate()
    }
    
    private func setBeginDate(_ str: String) {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = format.date(from: str) {
            beginDate = date
        }else {
            beginDate = Date()
        }
    }

    private func timerAction() {
        guard let beginDate = beginDate else {return}
        let now = Date()
        let x = Int(now.timeIntervalSince(beginDate))
        let hour = x / 3600
        let min  = x % 3600 / 60
        let sec  = x % 60
        let time = String(format: "%02ld:%02ld:%02ld", hour, min, sec)
        timeLB.text = time
        
        //高度 128 188 208
        // 15分钟提醒
        if !isWarn && min >= warnTime {
            isWarn = true
            warnView.isHidden = false
            delegate?.timeView(self, promptWithTime: time, height: 188)
        }
        
        // 25分钟警告
        if !isEarly && min >= earlyTime {
            isEarly = true
            warnView.isHidden = true
            earlyView.isHidden = false
            delegate?.timeView(self, warningWithTime: time, height: 208)
        }
        
        // 28 分钟传定位信息
        if !isLocation && min >= (maxTime - 2) {
            isLocation = true
            delegate?.timeView(self, uploadLocationWithTime: time)
        }
        
        // 30 分钟警告
        if !isMax && min >= maxTime {
            isMax = true
            warnView.isHidden = true
            earlyView.isHidden = true
            maxView.isHidden = false
            delegate?.timeView(self, maxWithTime: time, height: 208)
        }
        
        let overTime = PublicConfig.sysConfigIntValue(.lookHouse_sellerOverTime) ?? 3
        // 过三分钟以后确认电话结果
        guard identity == .seller, sellerIsIn, min >= (maxTime + overTime) else {return}
        // 单位分钟
        if sellerCheckTime == 0 {
            sellerCheckTime = min
            delegate?.timeView(self, sellerCheckIsInWithTime: time)
        // 4分钟内，每1分钟确认一次
        }else if (min - sellerCheckTime >= 1) &&
            min <= maxTime + overTime + 4
        {
            sellerCheckTime = min
            delegate?.timeView(self, sellerCheckIsInWithTime: time)
        }
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        delegate?.timeView(self, reopenWithBtn: sender)
    }
    //    MARK: - 懒加载
    private lazy var timer: Timer = {
        let timer = Timer(timeInterval: 0.01, repeats: true, block: { [weak self] (_) in
            self?.timerAction()
        })
        return timer
    }()
}
