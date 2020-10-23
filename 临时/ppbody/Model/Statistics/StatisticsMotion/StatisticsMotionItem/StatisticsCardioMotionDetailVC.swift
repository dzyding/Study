//
//  StatisticsCardioMotionDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsCardioMotionDetailVC: BaseVC {
    
    private let cellClass = StatisticsCardioMotionDetailCell.self
    
    private lazy var editView: StatisticsCardioMotionEditView = {
        let view = StatisticsCardioMotionEditView.initFromNib()
        view.frame = CGRect(x: 0, y: 0, width: 230.0, height: 180.0)
        view.handler = { [weak self] (value, date, gId) in
            self?.saveAction(value, date: date, gId: gId)
        }
        return view
    }()
    
    private lazy var popView = DzyPopView(.POP_center,
                                          viewBlock: editView)
    
    @IBOutlet weak var tableview: UITableView!
    var motionCode = ""
    var isOther = false //是否为学员
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //判断是否是学员
        if DataManager.memberInfo() == nil {
            isOther = false
        }else{
            isOther = true
        }
        tableview.dzy_registerCellNib(cellClass)
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
        
        getData(1)
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["motionCode":motionCode]
        if isOther
        {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.MotionData
        request.page = [page,20]
        request.start { (data, error) in
            self.tableview.srf_endRefreshing()
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            if self.currentPage == 1 {
                self.dataArr.removeAll()
                if listData.isEmpty {
                }else{
                    self.tableview.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.tableview.srf_canLoadMore(false)
            }
            
            self.dataArr.append(contentsOf: listData)
            self.tableview.reloadData()
        }
    }
    
    /// 删除
    private func deleteApi(_ mgId: Int,
                           time: String,
                           complete: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.DelMotionGroup
        request.dic = ["userMotionGroupId" : "\(mgId)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                NotificationCenter.default.post(
                    name: Config.Notify_ChangeStatisticsData,
                    object: nil,
                    userInfo: ["time" : time])
                complete()
            }
        }
    }
    
    /// 编辑
    private func editApi(_ dic: [String : String],
                         time: String,
                         complete: @escaping ()->())
    {
        let request = BaseRequest()
        request.url = BaseURL.EditMotionGroup
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                NotificationCenter.default.post(
                    name: Config.Notify_ChangeStatisticsData,
                    object: nil,
                    userInfo: ["time" : time])
                complete()
            }
        }
    }
    
//    MARK: - 编辑，删除
    private func editAction(_ data: [String : Any]) {
        editView.updateUI(data, title: title)
        popView.show(view)
    }
    
    private func delAction(_ data: [String : Any]) {
        let successHandler: (() -> ()) = { [weak self] in
            if let index = self?.dataArr.firstIndex(where: {
                data.intValue("userMotionGroupId") == $0.intValue("userMotionGroupId")
            }) {
                self?.dataArr.remove(at: index)
                self?.tableview.reloadData()
            }
        }
        let sureHandler: ((UIAlertAction) -> ()) = { [weak self] (_) in
            if let mgId = data.intValue("userMotionGroupId"),
                let time = data.stringValue("createTime")?
                    .components(separatedBy: " ").first
            {
                self?.deleteApi(mgId, time: time, complete: successHandler)
            }
        }
        let alert = dzy_normalAlert("提示",
                                    msg: "您的操作不可逆转，是否继续？",
                                    sureClick: sureHandler,
                                    cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
    
//    MARK: - 编辑完了保存
    private func saveAction(_ data: [String : Any], date: String, gId: Int) {
        let dic: [String : String] = [
            "userMotionGroupId" : "\(gId)",
            "motionAction" : ToolClass.toJSONString(dict: [data])
        ]
        editApi(dic, time: date) { [weak self] in
            self?.popView.hide()
            self?.getData(1)
        }
    }
}

extension StatisticsCardioMotionDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(cellClass)
        let data = dataArr[indexPath.row]
        cell?.updateUI(data)
        cell?.editHandler = { [weak self] in
            self?.editAction(data)
        }
        cell?.delHandler = { [weak self] in
            self?.delAction(data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

