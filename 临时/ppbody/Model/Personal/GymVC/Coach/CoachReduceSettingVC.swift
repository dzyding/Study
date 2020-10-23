//
//  CoachReduceSettingVC.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceSettingVC: BaseVC {
    
    private let config: [String : Any]
    
    private var times: [(Int, Int)] = []

    @IBOutlet private weak var reduceSwitch: UISwitch!
    
    @IBOutlet private weak var timeTF: UITextField!
    
    @IBOutlet private weak var numTF: UITextField!
    
    @IBOutlet private weak var hourTF: UITextField!
    
    @IBOutlet private weak var stackView: UIStackView!
    
    init(_ config: [String : Any]) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "预约设置"
        navigationItem.rightBarButtonItem = naviRightBtn
        setSwitchUI()
        setTimes()
    }
    
    private func setSwitchUI() {
        reduceSwitch.backgroundColor = UIColor.ColorHex("#4a4a4a")
        reduceSwitch.tintColor = UIColor.ColorHex("#4a4a4a")
        reduceSwitch.layer.masksToBounds = true
        reduceSwitch.layer.cornerRadius = (reduceSwitch.bounds.size.height)/2.0
        reduceSwitch.isOn = config.intValue("isOpen") == 1
        
        [timeTF, numTF, hourTF].forEach { (tf) in
            tf?.setPlaceholderColor(dzy_HexColor(0x999999))
        }
        
        timeTF.text = "\(config.intValue("duration") ?? 0)"
        if let limit = config.intValue("limit"),
            limit != -1
        {
            numTF.text  = "\(limit)"
        }
        hourTF.text = "\(config.intValue("cancelTime") ?? 0)"
    }
    
    //    MARK: - 初始化可预约时间段
    private func setTimes() {
        let timeStr  = config.stringValue("timeline") ?? ""
        let tempArr: [String] = ToolClass.getJsonDataFromString(timeStr)
        tempArr.forEach { (stime) in
            let arr = stime.components(separatedBy: "-")
            if arr.count == 2 {
                let time = (Int(arr[0]) ?? 0, Int(arr[1]) ?? 0)
                times.append(time)
                let timeView = CoachSettingTimeView
                                .initFromNib(CoachSettingTimeView.self)
                timeView.updateUI(time: time)
                stackView.addArrangedSubview(timeView)
            }
        }
    }
    
    //    MARK: - 编辑完成以后，回来修改界面
    func updateTimes(_ times: [(Int, Int)]) {
        self.times = times
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews.first?.removeFromSuperview()
        }
        times.forEach { (time) in
            let timeView = CoachSettingTimeView
                            .initFromNib(CoachSettingTimeView.self)
            timeView.updateUI(time: time)
            stackView.addArrangedSubview(timeView)
        }
    }
    
    //    MARK: - 前往预约时间段选择界面
    @IBAction func selectTimeAction(_ sender: UIButton) {
        let vc = CoachReduceTimeVC(times)
        vc.settingVC = self
        dzy_push(vc)
    }
    
    //    MARK: - 保存
    @objc private func saveAction() {
        guard times.count > 0 else {
            ToolClass.showToast("请选择可预约时间段", .Failure)
            return
        }
        guard let duration = timeTF.text, duration.count > 0 else {
            ToolClass.showToast("请输入课时长", .Failure)
            return
        }
        guard let cancelTime = hourTF.text, cancelTime.count > 0 else {
            ToolClass.showToast("请输入取消预约可提前时长", .Failure)
            return
        }
        let timeLineArr = times.map { (value) -> String in
            return "\(value.0)-\(value.1)"
        }
        let timeLine = ToolClass.toJSONString(dict: timeLineArr)
        var dic = [
            "timeline" : timeLine,
            "duration" : duration,
            "cancelTime" : cancelTime,
            "isOpen" : reduceSwitch.isOn == true ? "1" : "0"
        ]
        if let limit = numTF.text,
            let intLimit = Int(limit),
            intLimit > 0
        {
            dic.updateValue(limit, forKey: "limit")
        }
        saveSettingApi(dic)
    }
    
    //    MARK: - api
    private func saveSettingApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.PtEditConfig
        request.dic = dic
        request.isSaasPt = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dzy_pop()
        }
    }

    //    MARK: - 懒加载
    private lazy var naviRightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = dzy_Font(16)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()

}
