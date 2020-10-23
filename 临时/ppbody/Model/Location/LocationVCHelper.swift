//
//  LocationVCHelper.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

/// 订单操作类型
enum LOrderActionType: Int {
    /// 无
    case none = 0
    /// 使用
    case use
    /// 退款
    case refund
    /// 评价
    case evaluate
    /// 支付
    case pay
    /// 取消
    case cancel
    /// 退款进度
    case rProgress
}

/// 订单类型
enum LOrderType {
    case all
    case pay
    case use
    case evaluate
    case end
    
    /// vc 的 title
    func title() -> String {
        switch self {
        case .all:
            return "全部"
        case .pay:
            return "待付款"
        case .use:
            return "待使用"
        case .evaluate:
            return "待评价"
        case .end:
            return "退款/售后"
        }
    }
    
    /// 10 待付款 20 待使用 30 待评价 40 完成 60 退款和售后
    func apiType() -> Int {
        switch self {
        case .pay:
            return 10
        case .use:
            return 20
        case .evaluate:
            return 30
        case .end:
            return 60
        default:
            return -1
        }
    }
    
    /// cell 上面使用
    // 10 待付款 20 待使用 30 待评价 40 完成 50 已取消 60 退款和售后
    static func type(_ x: Int) -> String {
        switch x {
        case 10:
            return "待付款"
        case 20:
            return "待使用"
        case 30:
            return "待评价"
        case 40:
            return "完成"
        case 50:
            return "已取消"
        default:
            return "退款和售后"
        }
    }
}

struct LocationVCHelper {
    
    static let gbColor = dzy_HexColor(0xFF6172)
    
    static let expColor = dzy_HexColor(0x4184FB)
    
    static func shearchAttPlcaeHolder() -> NSAttributedString {
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        let attach = NSTextAttachment()
        attach.image = UIImage(named: "loc_search")
        attach.bounds = CGRect(x: 10, y: -3, width: 12, height: 12)
        let imgSrt = NSAttributedString(attachment: attach)
        let attStr = NSMutableAttributedString(
            string: " 搜索你想要的找到健身房、地点",
            attributes: [
            NSAttributedString.Key.foregroundColor : color,
            NSAttributedString.Key.font : ToolClass.CustomFont(11)
            ])
        attStr.insert(imgSrt, at: 0)
        attStr.addAttributes([NSAttributedString.Key.kern : 15], range: NSRange(location: 0, length: 2))
        return attStr
    }
    
    static func getWeekDay(_ week: Int, ifToday: Bool) -> String {
        if ifToday {return "今日"}
        switch week {
        case 1:
            return "周日"
        case 2:
            return "周一"
        case 3:
            return "周二"
        case 4:
            return "周三"
        case 5:
            return "周四"
        case 6:
            return "周五"
        default:
            return "周六"
        }
    }
    
    /// 获取接下来 N 天的日期、星期几、是否为当天
    static func getNextNumDates(_ num: Int) -> [(String, String, Bool)] {
        var dates: [(String, String, Bool)] = []
        let calendar = Calendar.current
        let today = Date()
        (0...num).forEach { (x) in
            guard let date = calendar.date(byAdding: .day,
                                           value: x,
                                           to: today) else {return}
            let com = calendar.dateComponents(
                [.month, .day, .weekday],
                from: date)
            let week = LocationVCHelper
                .getWeekDay(com.weekday ?? 1, ifToday: x == 0)
            let month = com.month ?? 0
            let day = com.day ?? 0
            dates.append((week, "\(month)-\(day)", x == 0))
        }
        return dates
    }
    
    static func getNextNumDates(_ num: Int, range: [Int])
        -> [(String, String, Bool)]
    {
        var dates: [(String, String, Bool)] = []
        let calendar = Calendar.current
        let today = Date()
        /// 偏移量
        var index = 0
        while dates.count < num {
            guard let date = calendar.date(byAdding: .day,
                                           value: index,
                                           to: today) else {break}
            let com = calendar.dateComponents(
                [.month, .day, .weekday],
                from: date)
            let weekStr = LocationVCHelper
                .getWeekDay(com.weekday ?? 1, ifToday: index == 0)
            var weekDay = com.weekday ?? 1
            weekDay = weekDay == 1 ? 7 : weekDay - 1
            let month = com.month ?? 0
            let day = com.day ?? 0
            if range.contains(weekDay) {
                let monthDay = String(format: "%02ld-%02ld", month, day)
                dates.append((weekStr, monthDay, dates.count == 0))
            }
            index += 1
        }
        return dates
    }
    
    /// 获取健身房的类型
    static func gymStrType(_ type: Int) -> String? {
        switch type {
        case 10:
            return "健身房"
        case 11:
            return "工作室"
        case 20:
            return "瑜伽馆"
        case 30:
            return "拳击馆"
        default:
            return  nil
        }
    }
    
    /// 团购的 label
    static func groupBuyLB(_ label: inout UILabel) {
        label.backgroundColor = LocationVCHelper.gbColor
        label.text = "团"
    }
    
    /// 体验课的 label
    static func ptExpLB(_ label: inout UILabel) {
        label.backgroundColor = LocationVCHelper.expColor
        label.text = "体"
    }
}
