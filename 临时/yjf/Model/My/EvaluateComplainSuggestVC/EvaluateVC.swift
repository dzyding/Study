//
//  EvaluateVC.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum EvaluateVCType: Int {
    case evaluate = 10
    case complain = 20
}

//swiftlint:disable:next type_body_length
class EvaluateVC: EvaluateAndFBClassVC {
    
    private let vcType: EvaluateVCType
    
    private var task: [String : Any]? {
        get {
            return (parent as? EvaluateAndFBBaseVC)?.task
        }
        set {
            (parent as? EvaluateAndFBBaseVC)?.task = newValue
        }
    }
    
    init(_ vcType: EvaluateVCType) {
        self.vcType = vcType
        super.init(nibName: "EvaluateAndFBClassVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch vcType {
        case .evaluate:
            sureBtn.setTitle("提交评价", for: .normal)
            stackView.addArrangedSubview(typeView)
            stackView.addArrangedSubview(houseView)
            stackView.addArrangedSubview(serviceView)
            stackView.addArrangedSubview(starView)
            stackView.addArrangedSubview(commentView)
        case .complain:
            sureBtn.setTitle("提交投诉", for: .normal)
            serviceView.changeToComplainType()
            commentView.changeToComplainType()
            stackView.addArrangedSubview(typeView)
            stackView.addArrangedSubview(houseView)
            stackView.addArrangedSubview(serviceView)
            stackView.addArrangedSubview(commentView)
        }
        changeTypeFunc()
    }
    
    //    MARK: - 提交
    override func sureAction(_ sender: UIButton) {
        let task = type == .order ? currentTask : currentOtherTask
        guard let taskId = task.intValue("id"),
            let number = task.stringValue("number"),
            let taskName = task.stringValue("name")
        else {
            showMessage("无有效任务")
            return
        }
        guard let content = commentView.textView.text,
            content.count > 0
        else {
            switch vcType {
            case .evaluate:
                showMessage("请输入评价内容")
            case .complain:
                showMessage("请输入投诉内容")
            }
            return
        }
        if vcType == .evaluate {
            guard rank > 0 else {
                showMessage("请选择服务星级")
                return
            }
        }
        var userType = 10
        switch type {
        case .order:
            userType = currentHouse.boolValue("isOwner") == true ? 20 : 10
        case .other:
            userType = task.intValue("userType") ?? 10
        }
        var dic: [String : Any] = [
            "taskId" : taskId,
            "taskName" : taskName,
            "type"   : type.rawValue,
            "number" : number,
            "evaluateType" : vcType.rawValue,
            "userType" : userType,
            "content" : content,
            "statusType" : 10
        ]
        if type == .order,
            let houseId = currentHouse.intValue("houseId") {
            dic["houseId"] = houseId
        }
        if vcType == .evaluate {
            dic["evaluate"] = rank
        }
        evaluateApi(dic)
    }
    
    //    MARK: - 更新界面
    private func updateUI(_ data: [String : Any]?) {
        let dic = data?.dicValue("taskEvaluate")
        var rank = dic?.intValue("evaluate") ?? 0
        let content = dic?.stringValue("content")
        rank = max(0, rank)
        starView.updateUI(rank)
        commentView.textView.text = content
        commentView.placeHolderLB.isHidden = (content?.count ?? 0) > 0
    }
    
    //    MARK: - 选中第一个房源，或者第一个任务
    private func selectFirstHouse() {
        func baseFunc(_ house: [String : Any]?) {
            currentHouse = house ?? [:]
            houseView.updateUI(house?.stringValue("houseTitle"))
            taskForHouseApi()
        }
        if let houseId = task?.intValue("houseId"),
            let house = houseList.first(where: {
                $0.intValue("houseId") == houseId}
            )
        {
            baseFunc(house)
        }else if let house = houseList.first {
            baseFunc(house)
        }else {
            baseFunc(nil)
        }
    }
    
    private func selectFirstOtherTask() {
        if let task = otherTaskList.first {
            currentOtherTask = task
            let title = task.stringValue("name") ?? ""
            let time = task.stringValue("createTime") ?? ""
            serviceView.updateUI(title, time: time)
            evaluateDetailApi()
        }else {
            currentOtherTask = [:]
            serviceView.updateUI(nil, time: nil)
        }
    }
    
    private func selectFirstHouseTask() {
        func baseFun(_ task: [String : Any]) {
            self.task = nil
            currentTask = task
            let title = task.stringValue("name") ?? ""
            let time = task.stringValue("createTime") ?? ""
            serviceView.updateUI(title, time: time)
            evaluateDetailApi()
        }
        if let taskId = task?.intValue("taskId"),
            let number = task?.stringValue("number"),
            let task = taskList.first(where: {
                ($0.stringValue("number") == number) &&
                    ($0.intValue("id") == taskId)}
            )
        {
            baseFun(task)
        }else if let task = taskList.first {
            baseFun(task)
        }else {
            currentTask = [:]
            serviceView.updateUI(nil, time: nil)
        }
    }
    
    //    MARK: - 处理房源任务列表
    private func operateHouseTask(_ data: [String : Any]) {
        taskList = EvaluateHelper.houseTaskList(data)
        selectFirstHouseTask()
    }
    
    //    MARK: - 切换评价类型
    override func changeTypeFunc() {
        var handler: ([[String : Any]]) -> ()
        switch type {
        case .order:
            if houseList.count > 0 {
                selectFirstHouse()
                return
            }
            handler = { [weak self] list in
                guard let sSelf = self else {return}
                sSelf.houseList = []
                for var house in list {
                    EvaluateHelper.houseName(&house)
                    sSelf.houseList.append(house)
                }
                sSelf.selectFirstHouse()
            }
        case .other:
            if otherTaskList.count > 0 {
                selectFirstOtherTask()
                return
            }
            handler = { [weak self] list in
                guard let sSelf = self else {return}
                sSelf.otherTaskList = []
                for var task in list {
                    EvaluateHelper.taskName(&task)
                    sSelf.otherTaskList.append(task)
                }
                sSelf.selectFirstOtherTask()
            }
        }
        taskHouseListApi(handler)
    }

    //    MARK: - api
    func taskHouseListApi(_ handler: @escaping ([[String : Any]]) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.taskHouseList
        request.dic = [
            "type" : type.rawValue,
            "evaluateType" : vcType == .evaluate ? 10 : 20
        ]
        request.isUser = true
        request.dzy_start { (data, _) in
            let list = data?.arrValue("list") ?? []
            handler(list)
        }
    }
    
    // 针对房源的 task 列表
    override func taskForHouseApi() {
        guard let houseId = currentHouse.intValue("houseId") else {return}
        let request = BaseRequest()
        request.url = BaseURL.taskList
        request.dic = [
            "type" : 10,
            "houseId" : houseId
        ]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.operateHouseTask(data ?? [:])
        }
    }
    
    // 评价/投诉 详情
    override func evaluateDetailApi() {
        let task = type == .order ? currentTask : currentOtherTask
        guard let taskId = task.intValue("id"),
            let number = task.stringValue("number")
        else {
            showMessage("无有效任务")
            return
        }
        var userType = 10
        switch type {
        case .order:
            userType = currentHouse.boolValue("isOwner") == true ? 20 : 10
        case .other:
            userType = task.intValue("userType") ?? 10
        }
        var dic: [String : Any] = [
            "taskId" : taskId,
            "type"   : type.rawValue,
            "number" : number,
            "evaluateType" : vcType.rawValue,
            "userType" : userType
        ]
        if type == .order,
            let houseId = currentHouse.intValue("houseId") {
            dic["houseId"] = houseId
        }
        let request = BaseRequest()
        request.url = BaseURL.evaluateDetail
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            self.updateUI(data)
        }
    }
    
    func evaluateApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.evaluate
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                switch self.vcType {
                case .evaluate:
                    self.showMessage("评价成功")
                case .complain:
                    self.showMessage("投诉成功")
                }
                self.dzy_pop()
            }
        }
    }
}
