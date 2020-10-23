//
//  TrainingVC_old.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TrainingVC_old: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var monthLB: UILabel!
    @IBOutlet weak var yearLB: UILabel!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipBtn: UIButton!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    var startTime:Date!
    var endTime:Date = Date()
    // 选中日期
    var selectDate = Date()
    // 选中日期的字符串格式
    var selectDateStr = Date().description
        .components(separatedBy: " ").first ?? ""
    
    var isReload = false
    var isOther = false
    
    var datesWithMultipleEvents = [String]()
    
    lazy var planView = PlanView.instanceFromNib()
    lazy var recordView = RecordView.instanceFromNib()
    lazy var statusView = StatusView.instanceFromNib()
    private lazy var statisticView: StatisticItemView = {
        let view = StatisticItemView.initFromNib()
        view.handler = { [weak self] in
            let vc = StatisticsVC()
            self?.dzy_push(vc)
        }
        return view
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(scopeGesture)
        scrollview.panGestureRecognizer.require(toFail: scopeGesture)

        calendar.select(Date())
        calendar.scope = .week
        calendar.register(NaCalendarCell.self, forCellReuseIdentifier: "NaCalendarCell")
        
        headIV.setHeadImageUrl(DataManager.getHead())

        if DataManager.isCoach() {
            headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        }
        
        stackview.addArrangedSubview(planView)
        stackview.addArrangedSubview(recordView)
        stackview.addArrangedSubview(statusView)
        stackview.addArrangedSubview(statisticView)

        monthLB.text = "\(calendar.currentPage.month)月"
        yearLB.text = "\(calendar.currentPage.year)"
        
        startTime = getHalfYear()
        
        getCalendarAPI()
        getClubsApi()
        getTrainingDaiy()
        
        registObservers([
            Config.Notify_BodyDataChange,
            Config.Notify_PublicTopic
        ]) { [weak self] _ in
            self?.refreshData()
        }
        
        registObservers([
            Config.Notify_AddTrainingData,
            Config.Notify_ChangeStatisticsData
        ]) { [weak self] (noti) in
            if let info = noti.userInfo as? [String : String],
                self?.selectDateStr == info.stringValue("time")
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.resetOther()
                }
            }
        }
        
        registObservers([
            Config.Notify_ChangeMember
        ], queue: .main) { [weak self] _ in
            let user = DataManager.memberInfo()
            if user != nil {
                self?.isOther = true
                self?.headIV.setHeadImageUrl(DataManager.getMemberHead()!)
            }else{
                self?.isOther = false
                self?.headIV.setHeadImageUrl(DataManager.getHead())
            }
            self?.resetOther()
        }
        
        registObservers([
            Config.Notify_ChangeHead
        ], queue: .main) { [weak self] nofity in
            //修改头像
            let memberHead = DataManager.getMemberHead()
            if memberHead == nil {
                let userinfo = nofity.userInfo
                self?.headIV.image = userinfo!["head"] as? UIImage
            }
        }
        
        registObservers([
            Config.Notify_CoachReviewSuccess
        ], queue: .main) { [weak self] (_) in
            //是否显示教练指引
            if DataManager.isCoach() {
                self?.tipView.isHidden = false
                self?.tipBtn.layer.borderColor = UIColor.white.cgColor
                self?.tipBtn.layer.borderWidth = 1
                self?.tipBtn.layer.cornerRadius = 4
            }
        }
    }
    
    @IBAction func tipKnowAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tipView.alpha = 0
        }) { (finish) in
            self.tipView.removeFromSuperview()
        }
    }
    
    @objc func addressBookAction() {
        if let vc = parent as? PPBodyMainVC {
            vc.addressBookAction()
        }
    }
    
    @IBAction func changeMonthAction(_ sender: UIButton) {
        // sender.tag == 11  上一月  12 下一月
        let actionMonth = Calendar.current.date(byAdding: .month, value: sender.tag == 11 ? -1 : 1, to: calendar.currentPage)
        calendar.setCurrentPage(actionMonth!, animated: true)
    }
    
    //发布训练成功以后接收通知
    @objc func refreshData() {
        if !isOther {
            getTrainingDaiy()
        }
    }
    
    func getHalfYear() -> Date {
        let moth = endTime.month
        var start:Date!
        if moth > 6 {
            start =  endTime.set(year: nil, month: moth-6, day: 1, hour: nil, minute: nil, second: nil, tz: nil)
        }else{
            start = endTime.set(year: endTime.year-1, month: 6 + moth, day: 1, hour: nil, minute: nil, second: nil, tz: nil)
        }
        return start
    }
    
    //重置所有的数据 查看其它的学员
    func resetOther() {
        datesWithMultipleEvents.removeAll()
        dataArr.removeAll()
        calendar.setCurrentPage(Date(), animated: false)
        monthLB.text = "\(calendar.currentPage.month)月"
        yearLB.text = "\(calendar.currentPage.year)"
        endTime = Date()
        startTime = getHalfYear()
        getCalendarAPI()
        getTrainingDaiy()
    }
    
    //更新选择日期的训练情况
    func updateDay(_ select: Date) {
        if Calendar.current.isDate(select, inSameDayAs: self.selectDate) {
            return
        }
        self.selectDate = select
        getTrainingDaiy()
    }
    
    //获取日历训练情况
    func getCalendarAPI() {
        if isReload {
            return
        }
        isReload = true
        let request = BaseRequest()
        request.dic = [
            "begin": dateFormatter.string(from: startTime) ,
            "end":dateFormatter.string(from: endTime)
        ]
        if isOther{
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.Calendar
        request.start { (data, error) in
            self.isReload = false
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data!["list"] as! [[String:Any]]
            
            self.endTime = Calendar.current.date(byAdding: .day, value:  -1 , to: self.startTime)!
            self.startTime = self.getHalfYear()
            
            self.dataArr.append(contentsOf: list)
            let addTimes = list.compactMap({$0.stringValue("addTime")})
            self.datesWithMultipleEvents.append(contentsOf: addTimes)
            self.calendar.reloadData()
        }
    }
    
    //获取当天的数据情况
    func getTrainingDaiy()
    {
        let request = BaseRequest()
        request.dic = [
            "day": dateFormatter.string(from: self.selectDate)
        ]
        if isOther {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.DailyData
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let course = data!["course"] as! [[String:Any]]
            
            let motion = data!["motion"] as! [[String:Any]]
            
            let status = data!["status"] as! [String:Any]
            
            if course.count == 0 || self.isOther {
                if self.stackview.arrangedSubviews.contains(self.planView) {
                    self.stackview.removeArrangedSubview(self.planView)
                }
            }else{
                if !self.stackview.arrangedSubviews.contains(self.planView) {
                    self.stackview.insertArrangedSubview(self.planView, at: 0)
                }
                self.planView.setData(course)
            }
            self.recordView.setData(motion)
            let motionDetail = data!["motionDetail"] as! [[String:Any]]
            self.recordView.motionDetailList = motionDetail
            self.statusView.setData(status)
        }
    }
    
    //    MARK: - 获取用户俱乐部
    func getClubsApi() {
        let type = DataManager.userInfo()?.intValue("type") ?? 10
        let request = BaseRequest()
        request.url = BaseURL.Clubs
        request.dic = ["type" : "\(type)"]
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let list = data?.arrValue("list"),
                list.count > 0
            {
                let vc = BindGymVC(list)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
}

extension TrainingVC_old:UIGestureRecognizerDelegate, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance
{
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = scrollview.contentOffset.y <= -scrollview.contentInset.top
        if shouldBegin {
            let velocity = scopeGesture.velocity(in: view)
            switch calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                break
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if gregorian.isDateInToday(date) {
            return "今"
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//        if self.gregorian.isDateInToday(date) {
//            return ToolClass.YellowMainColor
//        }
        let dateStr = dateFormatter.string(from: date)
        if datesWithMultipleEvents.contains(dateStr),
            date.month == calendar.currentPage.month {
            let index = datesWithMultipleEvents.firstIndex(of: dateStr)
            if index != nil && index! < self.dataArr.count {
                let dic = self.dataArr[index!]
                let trainingNum = dic["trainingNum"] as! Int
                if trainingNum < 80
                {
                    return nil
                }
            }
            return BackgroundColor
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "NaCalendarCell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        configureVisibleCells()
        selectDateStr = dateFormatter.string(from: date)
        dzy_log("选中日期 - \(selectDateStr)")
        //刷新数据
        updateDay(date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let calendarSw = Calendar.current
        let month = calendarSw.component(.month, from: calendar.currentPage)

        self.monthLB.text = "\(month)月"
        self.yearLB.text = "\(calendar.currentPage.year)"

        let offset = calendar.currentPage.timeIntervalSince1970 - self.endTime.timeIntervalSince1970
        
        if offset < 60 * 60 * 24 * 30 && offset > 0 {
            getCalendarAPI()
        }
        
        print(dateFormatter.string(from: calendar.currentPage))
        
    }
    
    // MARK: - Private functions
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! NaCalendarCell)
        diyCell.circleImageView.alpha = 1
        if position == .current {
            let dateStr = dateFormatter.string(from: date)
            if let index = datesWithMultipleEvents
                .firstIndex(of: dateStr),
                index < dataArr.count
            {
                diyCell.selectionType = .full
                let dic = dataArr[index]
                let trainingNum = dic.intValue("trainingNum") ?? 0
                diyCell.circleImageView.alpha = CGFloat(trainingNum)/100.0
            }else {
                diyCell.selectionType = .none
            }
        } else {
            diyCell.selectionType = .none
        }
    }
}
