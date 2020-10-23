//
//  PlanListVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PlanListVC: BaseVC, ObserverVCProtocol {
    var observers: [[Any?]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currentIndex: Int = 0
    
    var totalTemplate = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的计划库"
        navigationItem.rightBarButtonItem = rightBtn
        tableView.dzy_registerCellNib(TrainPlanCell.self)
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getCourseList()
        }
        tableView.srf_addRefresher(refresh)
        getCourseList()
        
        registObservers([
            Config.Notify_EditMotionPlanData
        ]) { [weak self] _ in
            self?.getCourseList()
        }
    }
    
    deinit {
        deinitObservers()
    }
    
//    MARK: - cell 的点击时间
    private func cellEditAction(_ index: Int, btn: UIButton) {
        guard let cell = tableView
            .cellForRow(at: IndexPath(row: index, section: 0))
        else {
            return
        }
        currentIndex = index
        let frame = cell.contentView.convert(btn.frame, to: view)
        funcView.show(in: view,
                      sframe: frame)
    }
    
//    MARK: - 增加，分享，删除，编辑
    @objc func addClick() {
        let vc = PlanAddVC()
        dzy_push(vc)
    }
    
    private func cellEdit() {
        let pid = dataArr[currentIndex].intValue("id") ?? 0
        let vc = TrainPlanPlayVC(.planEdit(pid: pid))
        dzy_push(vc)
    }
    
    private func cellShare() {
        
    }
    
    private func cellDelete() {
        let code = dataArr[currentIndex].stringValue("code") ?? ""
        //删除
        let alert = UIAlertController.init(title: "请确认是否删除？", message: "", preferredStyle: .alert)
        let actionN = UIAlertAction.init(title: "是", style: .default) { [weak self] (_) in
            self?.deleteCoursePlan(code)
        }
        let actionY = UIAlertAction.init(title: "否", style: .cancel) { (_) in
            
        }
        alert.addAction(actionN)
        alert.addAction(actionY)
        present(alert, animated: true, completion: nil)
    }
    
//    MARK: - api
    func getCourseList() {
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanList
        request.isUser = true
        request.start { (data, error) in
            self.tableView.srf_endRefreshing()
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            let listData = data?["list"] as! [[String:Any]]
            self.dataArr = listData
            self.tableView.reloadData()
        }
    }
    
    //删除计划
    func deleteCoursePlan(_ planCode: String) {
        let request = BaseRequest()
        request.url = BaseURL.DeleteMotionPlan
        request.dic["planCode"] = planCode
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("删除成功！", .Success)
            self.getCourseList()
        }
    }
    
    //    MARK: - 懒加载
    private lazy var funcView: TrainFuncListView = {
        let view = TrainFuncListView.initFromNib()
        view.initUI([
            ("分享", "train_plan_share"),
            ("编辑", "train_plan_share"),
            ("删除", "train_plan_delete")
            ],
        handlerArr: [
            { [weak self] in
                self?.cellShare()
            },
            { [weak self] in
                self?.cellEdit()
            },
            { [weak self] in
                self?.cellDelete()
            }
        ])
        return view
    }()
    
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("新增", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = dzy_Font(14)
        btn.addTarget(self,
                      action: #selector(addClick),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}

extension PlanListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(TrainPlanCell.self)
        cell?.updateUI(dataArr[indexPath.row], isCoach: true)
        cell?.handler = { [weak self] btn in
            self?.cellEditAction(indexPath.row, btn: btn)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pid = dataArr[indexPath.row].intValue("id") ?? 0
        let vc = TrainPlanPlayVC(.play(pid: pid))
        dzy_push(vc)
    }
}
