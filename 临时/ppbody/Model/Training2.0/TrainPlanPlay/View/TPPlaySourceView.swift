//
//  TPPlaySourceView.swift
//  PPBody
//
//  Created by edz on 2020/1/8.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

// MARK: - 协议
protocol TPPlaySourceViewDelegate: class {
    /// 点击 next 输入框
    func sView(_ sView: TPPlaySourceView,
               didSelectNext tf: TPTextField,
               action: TPKeyboardActionType)
    /// 开始训练
    func sView(_ sView: TPPlaySourceView,
               didClickStart btn: UIButton)
    /// 结束训练
    func didRunEnd(_ sView: TPPlaySourceView)
    /// 移除 (编辑计划)
    func sView(_ sView: TPPlaySourceView,
               didRemove btn: UIButton,
               targetId: Int?,
               umId: Int?)
    /// 计时运动，设置时长
    func sView(_ sView: TPPlaySourceView,
               didClickSetTime btn: UIButton,
               tf: UITextField?)
}

class TPPlaySourceView: UIView, InitFromNibEnable {
    
    weak var delegate: TPPlaySourceViewDelegate?
    /// 设置时间
    @IBOutlet weak var timeBtn: UIButton!
    /// 均次
    @IBOutlet weak var numOrTimeTF: TPTextField!
    /// 均负重 或者 距离
    @IBOutlet weak var weightOrDistanceTF: TPTextField!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var timerLB: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var lvLB: UILabel!
    /// 编辑计划时使用
    private var targetId: Int?
    /// 编辑记录时使用
    private var hisData: [String : Any]?
    /// umId userMotionId
    private var umId: Int?
    /// 新增的训练记录
    private var isNew = false
    
    private var viewType: TPPlayViewType = .normal
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = dzy_FontBlod(14)
        numOrTimeTF.font = font
        weightOrDistanceTF.font = font
        timeLB.font = font
        lvLB.font = font
        timerLB.font = dzy_FontBlod(15)
        
        numOrTimeTF.tpDelegate = self
        weightOrDistanceTF.tpDelegate = self
    }
    
    func startTrain() {
        selectBtn.isHidden = true
        timerLB.isHidden = false
    }
    
    func endTrain(_ useValue: CFTimeInterval?) {
        delegate?.didRunEnd(self)
        numOrTimeTF.isUserInteractionEnabled = false
        weightOrDistanceTF.isUserInteractionEnabled = false
        selectBtn.isHidden = false
        timerLB.isHidden = true
        //有值代表是“跳过”的，为 nil 表示是正常倒计时完成停止的
        useValue.flatMap({
            timeLB.text = "\(Int($0))s"
        })
    }
    
    // 获取时间间隔
    func getRestStr() -> Int {
        var timeText = timeLB.text ?? "0s"
        timeText = timeText.replacingOccurrences(of: "s", with: "")
        return Int(timeText) ?? 0
    }
    
    // 获取时常
    private func getTimeValue() -> Int? {
        guard let numText = numOrTimeTF.text,
            numText.count > 0,
            numText != "00:00"
        else {
            ToolClass.showToast("请选择正确的时间", .Failure)
            return nil
        }
        let timeArr = numText.components(separatedBy: ":")
        guard timeArr.count == 2 else {
            ToolClass.showToast("错误的时间", .Failure)
            return nil
        }
        let min = Int(timeArr[0]) ?? 0
        let second = Int(timeArr[1]) ?? 0
        return min * 60 + second
    }
    
    // 获取时常或默认值
    private func getTimeOrDefaultValue() -> Int {
        let numText = numOrTimeTF.text ?? "00:00"
        let timeArr = numText.components(separatedBy: ":")
        guard timeArr.count == 2 else {
            return 0
        }
        let min = Int(timeArr[0]) ?? 0
        let second = Int(timeArr[1]) ?? 0
        return min * 60 + second
    }
    
//    MARK: - 获取值
    func values(_ type: TPPValueType = .normal) -> [String : Any]? {
        if type == .selected && !selectBtn.isSelected {return nil}
        var dic: [String : Any] = [:]
        switch viewType {
        case .normal:
            guard let numText = numOrTimeTF.text,
                numText.count > 0,
                let num = Int(numText)
            else {
                ToolClass.showToast("请输入正确的均次", .Failure)
                return nil
            }
            let weight = Double(weightOrDistanceTF.text ?? "0") ?? 0
            let rest = getRestStr()
            dic = [
                "freNum" : num,
                "weight" : weight,
                "rest" : rest
            ]
        case .cardio:
            guard let time = getTimeValue() else {
                return nil
            }
            let rest = getRestStr()
            dic = [
                "time" : time,
                "rest" : rest
            ]
        case .run:
            guard let time = getTimeValue() else {
                return nil
            }
            let distance = Double(weightOrDistanceTF.text ?? "0") ?? 0
            let rest = getRestStr()
            dic = [
                "time" : time,
                "distance" : distance,
                "rest" : rest
            ]
        }
        if type == .edit {
            if let targetId = targetId { // 编辑计划
                dic["targetId"] = targetId
            }else if let umId = umId { // 编辑训练记录
                dic["userMotionId"] = umId
            }else if isNew { // 新增训练记录
                dic["motionId"] = hisData?.intValue("motionId") ?? 0
                dic["motionPlanId"] = hisData?.intValue("motionPlanId") ?? 0
            }
        }
        return dic
    }
    
    func valuesOrDefault() -> [String : Any] {
        switch viewType {
        case .normal:
            let numText = numOrTimeTF.text ?? "0"
            let num = Int(numText) ?? 0
            let weightText = weightOrDistanceTF.text ?? "0"
            let weight = Double(weightText) ?? 0
            let rest = getRestStr()
            return ["freNum" : num, "weight" : weight, "rest" : rest]
        case .cardio:
            let time = getTimeOrDefaultValue()
            let rest = getRestStr()
            return ["time" : time, "rest" : rest]
        case .run:
            let time = getTimeOrDefaultValue()
            let distanceStr = weightOrDistanceTF.text ?? "0"
            let distance = Double(distanceStr) ?? 0
            let rest = getRestStr()
            return [
                "time" : time,
                "distance" : distance,
                "rest" : rest
            ]
        }
    }
    
//    MARK: - 更新界面
    /**
            listData 是当前view 显示的
            fatherData 是用来获取各种 ID 的
     
            isNew 表示是新增的
            此时 listData 中没有 id 即 userMotionId
     */
    func hisUpdateUI(_ listData: [String : Any],
                     fatherData: [String : Any],
                     index: Int,
                     type: TPPlayViewType,
                     isNew: Bool = false
    ) {
        viewType = type
        hisData = fatherData
        if isNew {
            self.isNew = isNew
        }else {
            umId = listData.intValue("id")
        }
        
        selectBtn.setImage(UIImage(named: "train_play_delete"), for: .normal)
        baseUpdateUI(listData, index: index)
    }
    
    func showOrEditUpdateUI(_ data: [String : Any],
                            index: Int,
                            type: TPPlayViewType
    ) {
        viewType = type
        targetId = data.intValue("targetId")
        selectBtn.setImage(UIImage(named: "train_play_delete"), for: .normal)
        baseUpdateUI(data, index: index)
    }
    
    func playUpdateUI(_ data: [String : Any],
                      index: Int,
                      type: TPPlayViewType)
    {
        viewType = type
        baseUpdateUI(data, index: index)
    }
    
    private func baseUpdateUI(_ data: [String : Any],
                              index: Int)
    {
        lvLB.text = "\(index)"
        let rest = data.intValue("rest") ?? 0
        timeLB.text = "\(rest)s"
        switch viewType {
        case .normal:
            let weight = data.doubleValue("weight") ?? 0
            weightOrDistanceTF.text = weight.decimalStr
            let num = data.intValue("freNum") ?? 0
            numOrTimeTF.text = "\(num)"
            timeBtn.isHidden = true
        case .cardio:
            weightOrDistanceTF.isHidden = true
            timeBtn.isHidden = false
            let time = data.intValue("time") ?? 0
            numOrTimeTF.text = String(format: "%02ld:%02ld", time / 60, time % 60)
        case .run:
            weightOrDistanceTF.isHidden = false
            timeBtn.isHidden = false
            let time = data.intValue("time") ?? 0
            numOrTimeTF.text = String(format: "%02ld:%02ld", time / 60, time % 60)
            let distance = data.doubleValue("distance") ?? 0
            weightOrDistanceTF.text = distance.decimalStr
        }
    }
    
//    MARK: - 选中
    @IBAction func selectAction(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(named: "train_play_delete") {
            delegate?.sView(self,
                            didRemove: sender,
                            targetId: targetId,
                            umId: umId)
            return
        }
        switch viewType {
        case .normal:
            guard let num = Int(numOrTimeTF.text ?? "0"),
                num > 0
            else {
                ToolClass.showToast("请输入正确的均次", .Failure)
                return
            }
        case .cardio, .run:
            let time = numOrTimeTF.text ?? "00:00"
            let timeArr = time.components(separatedBy: ":")
            guard timeArr.count == 2 else {return}
            let min = Int(timeArr[0]) ?? 0
            let second = Int(timeArr[1]) ?? 0
            guard min + second > 0 else {
                ToolClass.showToast("请选择正确的训练时间", .Failure)
                return
            }
        }
        guard !sender.isSelected else {return} 
        sender.isSelected = true
        delegate?.sView(self, didClickStart: sender)
    }
    
//    MARK: - 设置时间
    @IBAction func setTimeAction(_ sender: UIButton) {
        delegate?.sView(self, didClickSetTime: sender, tf: numOrTimeTF)
    }
}

extension TPPlaySourceView: TPTextFieldDelegate {
    func tf(_ tf: TPTextField,
            didSelectAction action: TPKeyboardActionType) {
        delegate?.sView(self, didSelectNext: tf, action: action)
    }
}
