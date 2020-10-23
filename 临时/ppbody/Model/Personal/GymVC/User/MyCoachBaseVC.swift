//
//  MyCoachBaseVC.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyCoachBaseVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var durationLB: UILabel!
    
    @IBOutlet weak var limitLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var orderBtn: UIButton!
    
    private weak var picker: PtReservePickerView?
    
    private let itemInfo: IndicatorInfo
    // 教练信息
    private let ptId: Int
    
    private var list: [[String : Any]] = []
    // 可提前几小时取消
    private var cancelTime: Int = 0
    // 今天的日期
    private var today: String = ""
    
    init(_ ptId: Int, itemInfo: IndicatorInfo) {
        self.ptId = ptId
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100.0
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(MyCoachClassCell.self)
        registNotice()
        reservePtListApi()
    }
    
    deinit {
        deinitObservers()
    }
    
    //    MARK: - 预约
    @IBAction func reserveAction(_ sender: Any) {
        if (picker?.datas.count ?? 0) > 0 {
            bottomPopView.show()
        }else {
            ToolClass.showToast("无可用时段", .Failure)
        }
    }
    
    //    MARK: - 收取容云信息
    func registNotice() {
        registObservers([
            Config.Notify_MessageForIM
        ]) { [weak self] (nofity) in
            if let extra = nofity.userInfo?["extra"] as? String {
                let strArr = extra.components(separatedBy: ":")
                DispatchQueue.main.async { [weak self] in
                    if strArr.first == Config.ReduceCompleteKey,
                        strArr.last == self?.qrView.code
                    {
                        self?.reduceCourseSuccess()
                    }
                }
            }
        }
    }
    
    //    MARK: - 核销成功
    private func reduceCourseSuccess() {
        ToolClass.showToast("核销成功", .Success)
        if centerPopView.superview != nil {
            centerPopView.hide()
        }
        reservePtListApi()
    }
    
    //    MARK: - 更新UI 以及时间的转换
    func updateUIAndComputeTime(_ data: [String : Any]) {
        // 配置信息
        let config  = data.dicValue("config")
        // 已约课程
        list         = data.arrValue("list") ?? []
        // 提前取消时间
        cancelTime   = config?.intValue("cancelTime") ?? 0
        // 上课时长
        let duration = config?.intValue("duration") ?? 0
        // 可否预约
        let isOpen   = config?.intValue("isOpen") ?? 0
        // 限制数
        let limit    = config?.intValue("limit") ?? -1
        let timeStr  = config?.stringValue("timeline") ?? ""
        let tempArr: [String] = ToolClass.getJsonDataFromString(timeStr)
        // 预约总时段
        let timeLineArr = tempArr.reduce([], {$0 + $1.components(separatedBy: "-").compactMap({Int($0)})})
        // 更新UI ------------------------
        durationLB.text = "上课时长：\(duration)分钟"
        limitLB.text = limit == -1 ? "\(list.count)" : "\(list.count)/\(limit)"
        if isOpen == 1 {
            var current:Int = 0
            var str = "可预约时间段："
            while current < timeLineArr.count {
                if current + 1 < timeLineArr.count {
                    let start = ToolClass.getTimeStr(timeLineArr[current])
                    let end   = ToolClass.getTimeStr(timeLineArr[current + 1])
                    str += "\(start)-\(end) "
                }
                current += 2
            }
            msgLB.textColor = .white
            msgLB.text = str
            orderBtn.setImage(UIImage(named: "gym_coach_order"), for: .normal)
            orderBtn.isUserInteractionEnabled = true
        }else {
            msgLB.text = "提示：当前教练已关闭预约"
            msgLB.textColor = dzy_HexColor(0xF81D1D)
            orderBtn.setImage(UIImage(named: "gym_coach_order_no"), for: .normal)
            orderBtn.isUserInteractionEnabled = false
        }
        // 设置完背景图再显示
        orderBtn.isHidden = false
        if list.count > 0 {
            tableView.tableFooterView = tableFooterView
        }else {
            tableView.tableFooterView = nil
        }
        tableView.reloadData()
        
        // 计算所有时间 ------------------------
        // 所有可预约时间
        let allTimesArr = getArrTimesFromTimeLine(timeLineArr)
        // 如果是今天，过滤掉已经过去的时间
        let resultAllTimesArr = getTodayHasRunOver(allTimesArr)
        // 已经预约的时间
        let reservedTimesArr = getReservedTimes()
        // 获取所有可预约时间
        let freeTimesArr = getFreeTimesArr(resultAllTimesArr, reserved: reservedTimesArr, duration: duration)
        // 获取所有可预约时间的小时分钟表达式
        let times = getHourAndMinute(freeTimesArr)
        
        if self.picker == nil {
            let pickerView = PtReservePickerView.initFromNib(PtReservePickerView.self)
            pickerView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 255.0)
            pickerView.setUI(times)
            pickerView.delegate = self
            bottomPopView.updateSourceView(pickerView)
            self.picker = pickerView
        }else {
            picker?.setUI(times)
        }
    }
    
    //    MARK: - 预约
    func reserveApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.PtReserve
        request.dic = dic
        request.isSaasUser = true
        request.setPtId(ptId)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.reservePtListApi()
            }
        }
    }
    
    //    MARK: - 取消预约
    func cancelReserveApi(_ reserveId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.CancelPtReserve
        request.dic = ["reserveId" : "\(reserveId)"]
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.reservePtListApi()
            }
        }
    }
    
    //    MARK: - 预约列表
    func reservePtListApi() {
        if today == "" {
            today = getApiTime()
        }
        let request = BaseRequest()
        request.url = BaseURL.ReservePtList
        request.dic = ["reverseTime" : today]
        request.isSaasUser = true
        request.setPtId(ptId)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.updateUIAndComputeTime(data)
            }
        }
    }
    
    // 获取 api 需要的 time
    func getApiTime() -> String {
        let calendar = Calendar.current
        func getTimeString(_ date: Date) -> String {
            let year  = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day   = calendar.component(.day, from: date)
            return String(format: "%ld-%02ld-%02ld", year, month, day)
        }
        let title = itemInfo.title ?? ""
        var time = ""
        let now = Date()
        time = getTimeString(now)
        switch title {
        case "明":
            var component = DateComponents()
            component.day = 1
            if let tomorrow = calendar.date(byAdding: component, to: now) {
                time = getTimeString(tomorrow)
            }
        case "后":
            var component = DateComponents()
            component.day = 2
            if let next = calendar.date(byAdding: component, to: now) {
                time = getTimeString(next)
            }
        default:
            break
        }
        return time
    }
    
    //    MARK: - 所有的时间计算方法
    // 计算已经预约的时间
    func getReservedTimes() -> [Int] {
        var result = [Int]()
        list.forEach { (dic) in
            let start = dic.intValue("start") ?? 0
            let end   = dic.intValue("end") ?? 0
            var time = getTimesArr(start, end: end)
            // 移除开始和结束的时间，它们分别可以作为别人的结束和开始
            if time.count > 2 {
                time.removeFirst()
                time.removeLast()
            }
            result += time
        }
        return result
    }
    
    // 从可预约时间段计算出所有可预约时间
    func getArrTimesFromTimeLine(_ timeLineArr: [Int]) -> [Int] {
        var result: [Int] = []
        var current:Int = 0
        while current < timeLineArr.count {
            if current + 1 < timeLineArr.count {
                result += getTimesArr(timeLineArr[current], end: timeLineArr[current + 1])
            }
            current += 2
        }
        return result
    }
    
    // 从今天过滤掉所有已经过去的时间
    func getTodayHasRunOver(_ allTimes: [Int]) -> [Int] {
        if itemInfo.title == "今" {
            let now = dzy_date8().description.components(separatedBy: " ")
            guard now.count == 3 else {return []}
            let nowTime = ToolClass.getIntTime(now[1])
            return allTimes.filter({$0>nowTime})
        }else {
            return allTimes
        }
    }
    
    // 给定起始和结束时间，获取所有时间
    func getTimesArr(_ start: Int, end: Int) -> [Int] {
        var times: [Int] = []
        var temp = start
        while temp <= end {
            times.append(temp)
            temp += 10
        }
        return times
    }
    
    // 计算所有可预约时间
    func getFreeTimesArr(_ all: [Int], reserved: [Int], duration: Int) -> [Int] {
        var temp = all
        temp.removeAll(where:{
            // 已经预约的时间中包含开始时间，或者包含结束时间 （犹豫之前删除了开始和结束时间，所以必须加个额外的条件）
            (reserved.contains($0) || reserved.contains($0 + duration) || reserved.contains($0 + 10))
            // 所有可用时间中不包含结束时间
            || !all.contains($0 + duration)
        })
        return temp
    }
    
    // 将所有可预约时间换算成小时和分钟的对应
    func getHourAndMinute(_ times: [Int]) -> [String : [String]] {
        var result: [String : [String]] = [:]
        times.forEach { (time) in
            let hour = "\(time / 60)"
            let min = "\(time % 60)"
            if result.keys.contains(hour) {
                var arr = result[hour] ?? []
                arr.append(min)
                result[hour] = arr
            }else {
                result[hour] = [min]
            }
        }
        return result
    }
    
    //    MARK: - 懒加载
    private lazy var tableFooterView: UIView = {
        let footer = Bundle.main.loadNibNamed("MyCoachFooterView", owner: self, options: nil)?.first as! UIView
        footer.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50.0)
        return footer
    }()
    
    private lazy var bottomPopView: DzyPopView = DzyPopView(.POP_bottom)
    
    private lazy var centerPopView: DzyPopView = {
        let view = DzyPopView(.POP_center_above)
        view.updateSourceView(qrView)
        return view
    }()
    
    private lazy var qrView: PublicClassQrCodeView = {
        let view = PublicClassQrCodeView
            .initFromNib(PublicClassQrCodeView.self)
        let width = ScreenWidth - 50.0
        view.frame = CGRect(
            x: 0, y: 0, width: width, height: width + 30.0
        )
        return view
    }()
}

extension MyCoachBaseVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MyCoachClassCell.self)
        cell?.topLine.isHidden = indexPath.row == 0
        cell?.userUpdateUI(
            list[indexPath.row],
            cancelTime: cancelTime,
            ifToday: itemInfo.title == "今"
        )
        cell?.delegate = self
        return cell!
    }
}

extension MyCoachBaseVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension MyCoachBaseVC: PtReservePickerViewDelegate, MyCoachClassCellDelegate {
    func picker(_ picker: PtReservePickerView, didSelectSureBtn btn: UIButton) {
        if let hour = Int(picker.hour),
            let min = Int(picker.min)
        {
            let start = hour * 60 + min
            let dic: [String : String] = [
                "reverseTime" : today,
                "start" : "\(start)"
            ]
            reserveApi(dic)
        }
    }
    
    func classCell(_ classCell: MyCoachClassCell, didSelectDelBtn btn: UIButton, reserveId: Int, mid: String) {
        let alert = dzy_normalAlert("提示", msg: "是否取消此次预约", sureClick: { [weak self] (_) in
            self?.cancelReserveApi(reserveId)
            }, cancelClick: nil)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func classCell(_ classCell: MyCoachClassCell, didSelectQrCodeBtn btn: UIButton, code: String) {
        qrView.updateUI(code)
        centerPopView.show()
    }
}
