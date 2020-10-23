//
//  CoachSetClassVC.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

private enum CurrentType {
    case none
    case date
    case time
}

class CoachSetClassVC: BaseVC {
    /// 约课设置
    private let config: [String : Any]
    
    @IBOutlet weak var stuLB: UILabel!
    
    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var startTimeLB: UILabel!
    /// 当前选择的弹出框
    private var currentType = CurrentType.none
    /// 可选日期
    private var dates = [String]()
    /// 所有可用开始时间(还未剔除已经选择的)
    private var allCanUseTimes = [Int]()
    /// 当前日期可用时间
    private var canUseTimes = [Int]()
    /// 选择的学员
    private var stu: [String : Any] = [:]
    
    init(_ config: [String : Any]) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "教练排课"
        initDates()
        initAllCanUseTimes()
    }
    
    //    MARK: - 确定
    @IBAction func saveAction(_ sender: UIButton) {
        let temp = "待选择"
        guard stu.count > 0 else {
            ToolClass.showToast("请选择学员", .Failure)
            return
        }
        guard let date = dateLB.text, date != temp else {
            ToolClass.showToast("请选择日期", .Failure)
            return
        }
        guard let startTime = startTimeLB.text, startTime != temp else {
            ToolClass.showToast("请选择开始时间", .Failure)
            return
        }
        let memberId = stu.stringValue("mid") ?? ""
        let dic = [
            "reverseTime" : date,
            "start" : "\(ToolClass.getIntTime(startTime + ":00"))",
            "fromPt" : "1"
        ]
        reserveApi(dic, mId: memberId)
    }
    
    //    MARK: - 初始化可用日期
    private func initDates() {
        let now = Date()
        let calendar = Calendar.current
        var todayWeek = calendar.component(.weekday, from: now)
        todayWeek = todayWeek == 1 ? 7 : todayWeek - 1
        let max = 14 - (todayWeek - 1)
        // 只能排本周和下周的 
        (0..<max).forEach { (x) in
            var components = DateComponents()
            components.day = x
            let date = calendar.date(byAdding: components, to: now) ?? now
            let year  = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day   = calendar.component(.day, from: date)
            var week  = calendar.component(.weekday, from: date)
            week = week == 1 ? 7 : week - 1
            let timeStr = String(format: "%ld-%02ld-%02ld %@", year, month, day, getWeekTitle(week))
            dates.append(timeStr)
        }
    }
    
    private func getWeekTitle(_ week: Int) -> String {
        switch week {
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        default:
            return "周日"
        }
    }
    
    //    MARK: - 初始化可用开始时间
    private func initAllCanUseTimes() {
        allCanUseTimes = []
        let classTime = config.intValue("duration") ?? 0
        let timeStr  = config.stringValue("timeline") ?? ""
        let tempArr: [String] = ToolClass.getJsonDataFromString(timeStr)
        tempArr.forEach { (stime) in
            let arr = stime.components(separatedBy: "-")
            if arr.count == 2 {
                // 开始时间
                var startTime = Int(arr[0]) ?? 0
                // 结束时间
                let endTime = Int(arr[1]) ?? 0
                while startTime <= endTime && (startTime + classTime <= endTime) {
                    allCanUseTimes.append(startTime)
                    startTime += 10
                }
            }
        }
    }
    
    //    MARK: - 初始化当前日期可用的所有起始时间
    private func initCanUseTimes(_ data: [String : Any], date: String) {
        canUseTimes = allCanUseTimes
        let todayArr = dzy_date8().description.components(separatedBy: " ")
        if let today = todayArr.first,
            today == date
        {
            //如果是今天，要剔除已经过的时间
            let time = ToolClass.getIntTime(todayArr[1])
            canUseTimes.removeAll(where: {$0 <= time})
        }
        
        let classTime = config.intValue("duration") ?? 0
        let list = data.arrValue("list") ?? []
        list.forEach { (data) in
            var startTime = data.intValue("start") ?? 0
            let endTime   = data.intValue("end") ?? 0
            while startTime < endTime {
                // 根据已预约时间，计算后面不能使用的时间
                if let index = canUseTimes.firstIndex(where: {$0 == startTime}) {
                    canUseTimes.remove(at: index)
                }
                // 根据已预约时间，计算前面不能使用的时间
                let tempTime = startTime - classTime + 10
                if let index = canUseTimes.firstIndex(where: {$0 == tempTime}) {
                    canUseTimes.remove(at: index)
                }
                startTime += 10
            }
        }
    }

    // MARK: - 选择学生
    @IBAction func stuAction(_ sender: UIButton) {
        let vc = CoachMemberListVC()
        vc.setClassVC = self
        dzy_push(vc)
    }
    
    func updateStu(_ stu: [String : Any]) {
        self.stu = stu
        stuLB.textColor = .white
        stuLB.text = stu.stringValue("realname")
    }
    
    // MARK: - 选择日期
    @IBAction func dateAction(_ sender: UIButton) {
        currentType = .date
        picker.setTitle("选择日期")
        picker.updateUI(dates)
        popView.updateSourceView(picker)
        popView.show()
    }
    
    // MARK: - 选择时间
    @IBAction func timeAction(_ sender: UIButton) {
        if dateLB.text != "待选择" {
            let times = canUseTimes.map({ToolClass.getTimeStr($0)})
            if !times.isEmpty {
                currentType = .time
                picker.setTitle("选择起始时间")
                picker.updateUI(times)
                popView.updateSourceView(picker)
                popView.show()
            }else {
                ToolClass.showToast("无可用时间", .Failure)
            }
        }else {
            ToolClass.showToast("请先选择日期", .Failure)
        }
    }
    
    //    MARK: - api
    // 今日预约详情
    private func reserveListApi(_ date: String) {
        let request = BaseRequest()
        request.url = BaseURL.ReserveList_Pt
        request.dic = ["reserveTime" : date]
        request.isSaasPt = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.initCanUseTimes(data ?? [:], date: date)
        }
    }
    
    // 排课
    private func reserveApi(_ dic: [String : String], mId: String) {
        let request = BaseRequest()
        request.url = BaseURL.PtReserve
        request.dic = dic
        request.isSaasPt = true
        request.setMemberId(mId)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dzy_pop()
        }
    }
    
    //    MARK: - 懒加载
    private lazy var popView: DzyPopView = DzyPopView(.POP_bottom)
    
    private lazy var picker: GymNormalPicker = {
        let picker = GymNormalPicker.initFromNib(GymNormalPicker.self)
        picker.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 205)
        picker.delegate = self
        return picker
    }()
}

extension CoachSetClassVC: GymNormalPickerDelegate {
    func normalPicker(_ picker: GymNormalPicker, didSelectString str: String) {
        switch currentType {
        case .date:
            if let date = str.components(separatedBy: " ").first {
                dateLB.textColor = .white
                dateLB.text = date
                startTimeLB.text = "待选择"
                startTimeLB.textColor = dzy_HexColor(0x999999)
                reserveListApi(date)
            }
        case .time:
            startTimeLB.textColor = .white
            startTimeLB.text = str
        case .none:
            break
        }
    }
}
