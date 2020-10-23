//
//  BodyIndexBaseVC.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class BodyIndexBaseVC: BaseVC {
    
    private let itemInfo: IndicatorInfo
    
    private let type: BodyStatusType
    
    private var min: Double = 0
    
    private var max: Double = 0
    
    private var low: Double = 0
    
    private var high: Double = 0
    
    private var current: Double = 0
    
    private var unit: String {
        switch type {
        case .Weight, .Muscle, .Fat:
            return "kg"
        default:
            return "cm"
        }
    }
    
    private var part: String {
        switch type {
        case .Weight:
            return "weight"
        case .Muscle:
            return "muscle"
        case .Fat:
            return "fat"
        case .Bust:
            return "bust"
        case .Arm:
            return "arm"
        case .Waist:
            return "waist"
        case .Hipline:
            return "hipline"
        case .Thigh:
            return "thigh"
        }
    }
    
    private var headerView = BodyIndexHeaderView.initFromNib()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    init(_ type: BodyStatusType) {
        self.itemInfo = IndicatorInfo(title: type.rawValue)
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        loadData()
    }
    
//    MARK: - Action
    @IBAction func showRulerAction(_ sender: Any) {
        popView.show()
    }
    
//    MARK: - UI
    private func initUI() {
        saveBtn.setTitle("记录" + type.rawValue, for: .normal)
        headerView.initUI(type)
        tableView.dzy_registerCellNib(BodyIndexHistoryCell.self)
    }
    
    private func updateUI(_ list: [[String : Any]]) {
        headerView.updateUI(list)
        dataArr = list
        tableView.reloadData()
    }
    
    func initValues(_ data: [String : Any]) {
        let scale = getRulerSize(type)
        min = Double(scale[0])
        max = Double(scale[1])
        switch type {
        case .Weight:
            let dic = data.dicValue("weight") ?? [:]
            low = dic.doubleValue("min") ?? 0
            high = dic.doubleValue("max") ?? 0
            current = dic.doubleValue("current") ?? 0
            headerView.initValues(.Weight, min: min, max: max, low: low, high: high, current: current, unit: unit)
        case .Muscle:
            let dic = data.dicValue("muscle") ?? [:]
            low = dic.doubleValue("min") ?? 0
            high = dic.doubleValue("max") ?? 0
            current = dic.doubleValue("current") ?? 0
            headerView.initValues(.Muscle, min: min, max: max, low: low, high: high, current: current, unit: unit)
        case .Fat:
            let dic = data.dicValue("fat") ?? [:]
            low = dic.doubleValue("min") ?? 0
            high = dic.doubleValue("max") ?? 0
            current = dic.doubleValue("current") ?? 0
            headerView.initValues(.Fat, min: min, max: max, low: low, high: high, current: current, unit: unit)
        default:
            break
        }
        rulerView.updateUI(min: Int(min), max: Int(max), low: CGFloat(low), high: CGFloat(high), current: CGFloat(current), unit: unit)
    }
    
    private func updateValues(_ value: Float) {
        current = Double(value)
        switch type {
        case .Weight, .Muscle, .Fat:
            headerView.initValues(type, min: min, max: max, low: low, high: high, current: current, unit: unit)
        default:
            break
        }
        loadData()
    }
    
    func getRulerSize(_ type: BodyStatusType) -> [Int] {
        switch type {
        case .Weight:
            return [30,130,45]
        case .Muscle:
            return [10,120,30]
        case .Fat:
            return [0,100,20]
        case .Bust:
            return [70,180,90]
        case .Arm:
            return [10,100,20]
        case .Waist:
            return  [30,170,70]
        case .Hipline:
            return [30,170,70]
        case .Thigh:
            return [30,130,60]
        }
    }
    
//    MARK: - 懒加载
    private lazy var rulerView: BodyIndexRulerView = {
        let view = BodyIndexRulerView.initFromNib()
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 250)
        view.saveHandler = { [weak self] value in
            self?.saveBodyDataApi(value)
        }
        return view
    }()
    
    private lazy var popView = DzyPopView(.POP_bottom, viewBlock: rulerView)
    
//    MARK: - api
    private func loadData() {
        let request = BaseRequest()
        request.url = BaseURL.OneBodyData
        request.dic = ["bodyPart" : part]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data?.arrValue("list") ?? []
            self.updateUI(list)
        }
    }
    
    private func saveBodyDataApi(_ value: Float) {
        let request = BaseRequest()
        request.dic = [part : String(format: "%.1f", value)]
        request.isUser = true
        request.url = BaseURL.AddBodyData
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("体态数据记录成功", .Success)
            self.updateValues(value)
        }
    }
}

extension BodyIndexBaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(BodyIndexHistoryCell.self)
        cell?.updateUI(dataArr[indexPath.row], unit: unit)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataArr.count == 0 ? 0.1 : headerView.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataArr.count == 0 ? nil : headerView
    }
}

extension BodyIndexBaseVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
