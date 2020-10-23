//
//  MyGymVC.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum CoachType {
    // 交叉预约
    case cross
    // 正常状态
    case normal(info: [String : Any])
}

class MyGymVC: BaseVC {

    @IBOutlet weak var stackView: UIStackView!
    
    weak var personVC: PersonalVC?
    
    private lazy var headerView = MyGymHeaderView.initFromNib(MyGymHeaderView.self)
    
    private lazy var cardView = MyGymCardView.initFromNib(MyGymCardView.self)
    
    private lazy var coachView: MyGymCoachView = {
        let view = MyGymCoachView.initFromNib(MyGymCoachView.self)
        view.delegate = self
        return view
    }()
    
    private lazy var classView: MyGymClassView = {
        let view = MyGymClassView.initFromNib(MyGymClassView.self)
        view.delegate = self
        return view
    }()
    /// 我的健身房弹出 pop
    private lazy var coachPopView: DzyPopView = DzyPopView(.POP_bottom)
    /// 我的健身房弹出 picker
    private weak var pickerView: GymPickerView?
    
    private let clubid: Int
    /// 约课类型
    private var coachType: CoachType?
    
    init(_ clubid: Int) {
        self.clubid = clubid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.isHidden = true
        stackView.addArrangedSubview(headerView)
        infoApi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    //    MARK: - 解除绑定
    @IBAction func cancelBindAction(_ sender: UIButton) {
        let alert = dzy_normalAlert("提示", msg: "你确定要进行解绑操作吗？解绑以后无法再次绑定，如需恢复请联系 皮皮小助手", sureClick: { [weak self] (_) in
            self?.cancelBindNextAction()
            }, cancelClick: nil)
        DispatchQueue.main.async {
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func cancelBindNextAction() {
        let user = DataManager.userInfo()
        guard let type = user?.intValue("type") else {return}
        let dic = [
            "type"      : "\(type)",
            "clubId"    : "\(clubid)",
            "action"    : "\(20)",
            "smId"      : "\(DataManager.smid())",
            "head"      : user?.stringValue("head") ?? "",
            "nickname"  : user?.stringValue("nickname") ?? ""
        ]
        cancelBindApi(dic)
    }
    
    //    MARK: - 刷新界面
    func updateViews(_ data: [String : Any]?) {
        
        if let card = data?.dicValue("card") {
            cardView.setUI(card)
            stackView.addArrangedSubview(cardView)
        }

        
        let club = data?.dicValue("club") ?? [:]
        headerView.userSetUI(club,
                             num: data?.intValue("num") ?? 0)
        { [weak self] in
            let vc = MyGymFooterVC()
            self?.dzy_push(vc)
        }
        
        // 判断有无私教练
        if let pt = data?.dicValue("pt") {
            coachView.setUI(pt)
            stackView.addArrangedSubview(coachView)
            
            // 判断是否可交叉预约
            if pt.intValue("multi") == 1 {
                coachType = CoachType.cross
                ptListApi()
            }else {
                coachType = CoachType.normal(info: pt)
            }
        }
        stackView.isHidden = false
    }
    
    //    MARK: - 设置今日课程
    func setTodayClass(_ data: [String : Any]?) {
        var list = data?.arrValue("list") ?? []
        list.sort(by: {($0.intValue("start") ?? 0) < ($1.intValue("start") ?? 0)})
        let row = (list.count - 1) / 2
        let height = (ScreenWidth - 30.0 - 42.0) / 2.0 - 5.0
        classView.heightLC.constant = 105.0 + height + CGFloat(row) * (height + 10.0)
        classView.updateViews(list)
        stackView.addArrangedSubview(classView)
    }
    
    //    MARK: - 设置弹出视图
    func setCoachPopView(_ data: [String : Any]?) {
        let coachs = data?.arrValue("list") ?? []
        guard coachs.count > 0 else {return}
        if let picker = GymPickerView.initFromNib(coachs, type: .coach) {
            coachPopView.updateSourceView(picker)
            picker.delegate = self
            self.pickerView = picker
        }
    }
    
    //    MARK: - 健身房详情api
    func infoApi() {
        let request = BaseRequest()
        request.url = BaseURL.MyClubInfo
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.updateViews(data)
            self.classListApi()
        }
    }
    
    //    MARK: - 解除绑定
    func cancelBindApi(_ dic :[String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClubAction
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.personVC?.getMyclubApi()
                self.dzy_popRoot()
            }
        }
    }
    
    //    MARK: - 教练列表
    func ptListApi() {
        let request = BaseRequest()
        request.url = BaseURL.PtList
        request.dic = ["clubId" : "\(clubid)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.setCoachPopView(data)
        }
    }
    
    //    MARK: - 团课信息
    func classListApi() {
        var weekNum = dzy_weekNum(Date())
        weekNum = weekNum == 1 ? 7 : (weekNum - 1)
        let request = BaseRequest()
        request.url = BaseURL.GroupClassList
        request.dic = ["week" : "\(weekNum)"]
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.setTodayClass(data)
        }
    }
    
    //    MARK: - 团课预约
    func classReserveApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClassReserve
        request.dic = dic
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                let type = dic.stringValue("type") ?? "10"
                ToolClass.showToast(type == "10" ? "预约成功" : "取消预约成功", .Success)
                self.classListApi()
            }
        }
    }
}

extension MyGymVC: MyGymClassViewDelegate {
    // 今日课程预约
    func gymClass(_ gymClassView: MyGymClassView, didSelectedClass data: [String : Any]) {
        let type = data.intValue("isReserve") ?? 0
        let start = data.intValue("start") ?? 0
        let timeArr = dzy_date8().description.components(separatedBy: " ")
        guard timeArr.count >= 2 else {return}
        let current = ToolClass.getIntTime(timeArr[1])
        
        if type == 0, // 只有预约才需要判断这个
            let limit = data.intValue("limit"), limit != -1,
            let num = data.intValue("reserveNum"),
            num >= limit
        {
            ToolClass.showToast("剩余名额不足", .Failure)
        }else if current > start {
            ToolClass.showToast("当前预约课程已经失效", .Failure)
        }else {
            let groupId = data.intValue("id") ?? 0
            let date = timeArr[0]
            let dic: [String : String] = [
                "groupId" : "\(groupId)",
                "reserveTime" : date,
                "type" : "\(type == 0 ? 10 : 20)"
            ]
            classReserveApi(dic)
        }
    }
    
    func gymClass(_ gymClassView: MyGymClassView, didSelectedMoreBtn btn: UIButton) {
        let vc = TimeTableVC()
        dzy_push(vc)
    }
}

extension MyGymVC: MyGymCoachViewDelegate {
    //私教预约
    func coachView(_ coachView: MyGymCoachView, didClickReserveBtn btn: UIButton) {
        guard let type = coachType else {return}
        switch type {
        case .normal(let info):
            let vc = MyCoachVC(info)
            dzy_push(vc)
        case .cross:
            pickerView?.tableView.reloadData()
            coachPopView.show()
        }
    }
    
    func coachView(_ coachView: MyGymCoachView, didClickClassesBtn btn: UIButton) {
        let vc = MyGymClassesVC()
        dzy_push(vc)
    }
}

extension MyGymVC: GymPickerViewDelegate {
    
    func gympicker(_ picker: GymPickerView, didSelected data: [String : Any]) {
        coachPopView.hide()
        let vc = MyCoachVC(data)
        dzy_push(vc)
    }
    
}
