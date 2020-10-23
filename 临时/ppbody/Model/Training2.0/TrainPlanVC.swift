//
//  TrainPlanVC.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var dateLB: UILabel!
    // 所有的计划
    private var datas = [[[String : Any]]](repeating: [], count: 7)
    // (月份，日期)
    private var dates: [(Int, Int)] = []
    // 当前选择的
    private var cweekday: Int = 1
    // 当前操作的 planId
    private var planId: Int = -1
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        navigationItem.title = "周期训练"
        navigationItem.rightBarButtonItem = rightBtn
        tableView.dzy_registerCellNib(TrainPlanCell.self)
        listApi()
        
        registObservers([Config.Notify_UserEditWeekMotionPlan]) {  [weak self] (_) in
            self?.listApi()
        }
    }
    
    private func initUI() {
        let font = dzy_FontBlod(14)
        dateLB.font = font
        stackView.arrangedSubviews.forEach { (view) in
            [1, 2].forEach { (tag) in
                if let label = view.viewWithTag(tag) as? UILabel {
                    label.font = font
                }
            }
        }
        
        let calendar = Calendar.current
        let today = Date()
        let cpom = calendar
            .dateComponents([.weekday, .day, .month], from: today)
        let weekday = cpom.weekday!
        cweekday = weekday == 1 ? 7 : weekday - 1
        dateLB.text = "\(cpom.month!)月\(cpom.day!)日训练"
        assert(weekday <= stackView.arrangedSubviews.count)
        let view = stackView.arrangedSubviews[cweekday - 1]
        (view.viewWithTag(1) as? UILabel).flatMap({
            $0.text = "今日"
            $0.textColor = YellowMainColor
        })
        (view.viewWithTag(2) as? UILabel).flatMap({
            $0.textColor = YellowMainColor
        })
        view.viewWithTag(3).flatMap({
            $0.backgroundColor = YellowMainColor
        })
        (1...7).forEach { (index) in
            var com = DateComponents()
            com.weekday = index - cweekday
            calendar.date(byAdding: com, to: today).flatMap({
                let month = calendar.component(.month, from: $0)
                let day = calendar.component(.day, from: $0)
                dates.append((month, day))
                if let dayLB = stackView.arrangedSubviews[index - 1]
                    .viewWithTag(2) as? UILabel
                {
                    dayLB.text = "\(day)"
                }
            })
        }
    }
    
    private func initListDatas(_ list: [[String : Any]]) {
        datas = [[[String : Any]]](repeating: [], count: 7)
        list.forEach { (data) in
            let week = data.intValue("week") ?? 1
            datas[week - 1].append(data)
        }
        tableView.reloadData()
    }

//    MARK: - 分享 删除
    private func cellEditAction(_ index: Int, btn: UIButton) {
        guard let cell = tableView
            .cellForRow(at: IndexPath(row: index, section: 0))
        else {
            return
        }
        assert(dates.count > (cweekday - 1) ||
               (datas[cweekday - 1].count > index))
        planId = datas[cweekday - 1][index]
            .intValue("motionPlanWeekId") ?? -1
        let frame = cell.contentView
            .convert(btn.frame, to: view)
        funcView.show(in: view,
                      sframe: frame)
    }
    
//    MARK: - 编辑
    @objc private func editAction() {
        let vc = TrainPlanEditListVC(cweekday)
        dzy_push(vc)
    }
    
//    MARK: - 选择日期
    @IBAction func selectDateAction(_ sender: UIButton) {
        let week = sender.tag - 1
        assert(dates.count > week)
        cweekday = sender.tag
        tableView.reloadData()
        let month = dates[week].0
        let day   = dates[week].1
        dateLB.text = "\(month)月\(day)日训练"
        stackView.arrangedSubviews.enumerated().forEach { (index, view) in
            let color = (week) == index ?
                YellowMainColor : .white
            let view = stackView.arrangedSubviews[index]
            (view.viewWithTag(1) as? UILabel).flatMap({
                $0.textColor = (week) == index ?
                YellowMainColor :
                RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.35)
            })
            (view.viewWithTag(2) as? UILabel).flatMap({
                $0.textColor = color
            })
            view.viewWithTag(3).flatMap({
                $0.backgroundColor = color
            })
        }
    }
    
//    MARK: - 分享数据
    private func cellShare() {
        print("分享")
    }
    
//    MARK: - 删除数据
    private func cellDelete() {
        let alert = dzy_normalAlert("提示", msg: "该操作无法撤回，是否确定删除？", sureClick: { [weak self] (_) in
            self?.deletePlanApi()
        }, cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
    
//    MARK: - api
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanWeekDetail
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data?.arrValue("list") ?? []
            self.initListDatas(list)
        }
    }
    
    private func deletePlanApi() {
        assert(planId != -1)
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanWeekDelete
        request.dic = ["motionPlanWeekId" : "\(planId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.listApi()
        }
    }
    
//    MARK: - 懒加载
    private lazy var funcView: TrainFuncListView = {
        let view = TrainFuncListView.initFromNib()
        view.initUI([
            ("分享", "train_plan_share"),
            ("删除", "train_plan_delete")
            ],
        handlerArr: [
            { [weak self] in
                self?.cellShare()
            },
            { [weak self] in
                self?.cellDelete()
            }
        ])
        return view
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: ScreenWidth,
                                        height: 80.0))
        view.backgroundColor = dzy_HexColor(0x232327)
        return view
    }()
    
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("编辑", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = dzy_Font(13)
        btn.addTarget(self,
                      action: #selector(editAction),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}

extension TrainPlanVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[cweekday - 1].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arr = datas[cweekday - 1]
        let cell = tableView
            .dzy_dequeueReusableCell(TrainPlanCell.self)
        cell?.updateUI(arr[indexPath.row], isCoach: false)
        cell?.handler = { [weak self] btn in
            self?.cellEditAction(indexPath.row, btn: btn)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
