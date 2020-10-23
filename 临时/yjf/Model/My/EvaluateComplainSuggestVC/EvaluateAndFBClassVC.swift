//
//  EvaluateVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum TaskType: Int {
    /// 交易服务
    case order = 10
    /// 其他服务
    case other = 20
}

// 当前选中 picker 的类型
enum PickerType {
    case house
    case task
}

/// 基类
class EvaluateAndFBClassVC: BaseVC {
    
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    /// 评级
    var rank: Int = 0
    
    /// 房源列表
    var houseList: [[String : Any]] = []
    /// 房源相关任务列表
    var taskList: [[String : Any]] = []
    /// 当前房源
    var currentHouse: [String : Any] = [:]
    /// 当前房源任务
    var currentTask: [String : Any] = [:]
    
    /// 其他任务列表
    var otherTaskList: [[String : Any]] = []
    /// 当前其他任务
    var currentOtherTask: [String : Any] = [:]
    
    var pickerType: PickerType = .house

    var type: TaskType = .order {
        didSet {
            changeTypeFunc()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //    MARK: - 供 popPicker 使用
    private func getPoint(_ sender: UIButton) -> CGPoint {
        let rect = sender.superview?.convert(sender.frame, to: KEY_WINDOW) ?? .zero
        let point = CGPoint(x: rect.midX, y: rect.maxY)
        return point
    }
    
    //    MARK: - 更改类型
    func changeTypeFunc() {}
    
    //    MARK: - 评价详情
    func evaluateDetailApi() {}
    
    //    MARK: - 房源相关任务列表
    func taskForHouseApi() {}
    
    //    MARK: - 提交
    @IBAction func sureAction(_ sender: UIButton) {}
    
    //    MARK: - 懒加载
    /// 弹出框
    lazy var picker: YJFPickerView = {
        let pickerView = YJFPickerView()
        pickerView.delegate = self
        return pickerView
    }()
    
    /// 类型选择
    lazy var typeView: EvaluateTypeView = {
        let tview = EvaluateTypeView.initFromNib(EvaluateTypeView.self)
        tview.delegate = self
        return tview
    }()
    
    /// 房源选择
    lazy var houseView: EvaluateHouseView = {
        let hview = EvaluateHouseView.initFromNib(EvaluateHouseView.self)
        hview.delegate = self
        return hview
    }()
    
    /// 服务选择
    lazy var serviceView: EvaluateServiceView = {
        let sview = EvaluateServiceView
            .initFromNib(EvaluateServiceView.self)
        sview.delegate = self
        return sview
    }()
    
    /// 评价等级 
    lazy var starView: EvaluateStarView = {
       let sview = EvaluateStarView.initFromNib(EvaluateStarView.self)
        sview.delegate = self
        return sview
    }()
    
    /// 评价
    lazy var commentView: EvaluateCommentView = {
        let cview = EvaluateCommentView
            .initFromNib(EvaluateCommentView.self)
        return cview
    }()
}

//MARK: - 弹出框的点击事件，及消失事件
extension EvaluateAndFBClassVC: YJFPickerViewDelegate {
    func pickerView(_ pickerView: YJFPickerView, didSelect data: [String : Any], index: Int) {
        switch pickerType {
        case .house:
            currentHouse = data
            houseView.updateUI(data.stringValue("houseTitle") ?? "")
            taskForHouseApi()
        case .task:
            switch type {
            case .order:
                currentTask = data
            case .other:
                currentOtherTask = data
            }
            serviceView.updateUI(
                data.stringValue("name") ?? "",
                time: data.stringValue("createTime") ?? ""
            )
            evaluateDetailApi()
        }
        closePicker()
    }
    
    func didDismiss(_ pickerView: YJFPickerView) {
        closePicker()
    }
    
    private func closePicker() {
        houseView.closeAction()
        serviceView.closeAction()
    }
}

//MARK: - 选择评价类型
extension EvaluateAndFBClassVC: EvaluateTypeViewDelegate {
    func typeView(_ typeView: EvaluateTypeView, didType type: Int) {
        if type == 0 {
            stackView.insertArrangedSubview(houseView, at: 1)
        }else {
            houseView.removeFromSuperview()
        }
        self.type = type == 0 ? .order : .other
    }
}

//MAKR: - 选择星级
extension EvaluateAndFBClassVC: EvaluateStarViewDelegate {
    func starView(_ starView: EvaluateStarView, didSelectRank rank: Int) {
        self.rank = rank
    }
}

//MARK: - 选择房源
extension EvaluateAndFBClassVC: EvaluateHouseViewDelegate {
    func houseView(_ houseView: EvaluateHouseView, didSelectShowBtn btn: UIButton) {
        picker.updateUI(houseList, point: getPoint(btn), type: .house)
        if picker.isEmpty {
            showMessage("暂无数据")
        }else {
            pickerType = .house
            picker.show()
        }
    }
}

//MARK: - 选择服务
extension EvaluateAndFBClassVC: EvaluateServiceViewDelegate {
    func serviceView(_ serviceView: EvaluateServiceView, didSelectShowBtn btn: UIButton) {
        switch type {
        case .order:
            picker.updateUI(taskList, point: getPoint(btn), type: .task)
        case .other:
            picker.updateUI(otherTaskList, point: getPoint(btn), type: .task)
        }
        if picker.isEmpty {
            showMessage("暂无数据")
        }else {
            pickerType = .task
            picker.show()
        }
    }
}
