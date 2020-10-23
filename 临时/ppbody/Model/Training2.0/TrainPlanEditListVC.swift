//
//  TrainPlanEditListVC.swift
//  PPBody
//
//  Created by edz on 2019/12/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanEditListVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []

    @IBOutlet weak var tableView: UITableView!
    
    private let week: Int
    
    private var inDatas: [[String : Any]] = []
    
    private var outDatas: [[String : Any]] = []
    
    init(_ week: Int) {
        self.week = week
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "编辑周期训练"
        navigationItem.rightBarButtonItem = rightBtn
        tableView.dzy_registerCellNib(TrainPlanEditListCell.self)
        listApi()
        
        registObservers([Config.Notify_UserAddMotionPlan]) { [weak self] (_) in
            self?.listApi()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .setNavigationBarHidden(false, animated: true)
    }
    
    private func initUI(_ datas: [[String : Any]]) {
        inDatas = []
        outDatas = []
        datas.forEach { (data) in
            if data.intValue("isWeek") == 1 {
                inDatas.append(data)
            }else {
                outDatas.append(data)
            }
        }
        tableView.reloadData()
    }
    
//    MARK: - 保存
    @objc private func saveAction() {
        guard inDatas.count > 0 else {
            ToolClass.showToast("请添加至少一个计划", .Failure)
            return
        }
        let ids = inDatas.compactMap({$0.intValue("id")})
        editApi(ids)
    }
    
//    MARK: - 添加
    private func addAction() {
        let vc = PlanAddVC()
        dzy_push(vc)
    }
    
//    MARK: - api
    private func editApi(_ arr: [Int]) {
        let request = BaseRequest()
        request.url = BaseURL.EditMotionPlanWeek
        request.dic = [
            "week" : "\(week)",
            "motionPlanIds" : ToolClass.toJSONString(dict: arr)
        ]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                NotificationCenter.default.post(
                    name: Config.Notify_UserEditWeekMotionPlan,
                    object: nil)
                self.dzy_pop()
            }
        }
    }
    
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanWeek
        request.dic = ["week" : "\(week)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.initUI(data?.arrValue("list") ?? [])
        }
    }

//    MARK: - 懒加载
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(YellowMainColor, for: .normal)
        btn.titleLabel?.font = dzy_Font(13)
        btn.addTarget(self,
                      action: #selector(saveAction),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var fheader: TPEditListHeaderView = {
        let view = TPEditListHeaderView.initFromNib()
        view.titleLB.text = "已添加的计划"
        return view
    }()
    
    private lazy var sheader: TPEditListHeaderView = {
        let view = TPEditListHeaderView.initFromNib()
        view.titleLB.text = "未添加的计划"
        return view
    }()
    
    private lazy var footer: TPEditListFooterView = {
        let view = TPEditListFooterView.initFromNib()
        view.handler = { [weak self] in
            self?.addAction()
        }
        return view
    }()
}

extension TrainPlanEditListVC: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? inDatas.count : outDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(TrainPlanEditListCell.self)
        let arr = indexPath.section == 0 ? inDatas : outDatas
        cell?.updateUI(indexPath.section, data: arr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? nil : footer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? fheader : sheader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let data = inDatas.remove(at: indexPath.row)
            outDatas.append(data)
        }else {
            let data = outDatas.remove(at: indexPath.row)
            inDatas.append(data)
        }
        tableView.reloadData()
    }
}
