//
//  StatisticsOverviewDetail.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsMotionDetailVC: BaseVC {
    @IBOutlet weak var tableview: UITableView!
    var selectSectionArr = [Int]()
    var motionCode = ""
    var isOther = false //是否为学员
    
    /// 正在编辑的组 id
    private var editMgId: Int = 0
    
    /// 正在编辑的日期
    private var editTime: [String : String] = [:]
    
    private lazy var editView: StatisticsMotionEditView = {
        let view = StatisticsMotionEditView.initFromNib()
        view.frame = CGRect(x: 0,
                            y: 0,
                            width: ScreenWidth - 32.0,
                            height: 400)
        view.delegate = self
        return view
    }()
    
    private lazy var popView = DzyPopView(.POP_center, viewBlock: editView)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //判断是否是学员
        if DataManager.memberInfo() == nil {
            isOther = false
        }else{
            isOther = true
        }
        tableview.dzy_registerHeaderFooterClass(
            StatisticsMotionDetailHeader.self)
        tableview.dzy_registerCellNib(StatisticsMotionDetailCell.self)
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
        
        getData(1)
    }
    
    func getData(_ page: Int) {
        let request = BaseRequest()
        request.dic = ["motionCode" : motionCode]
        if isOther {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.MotionData
        request.page = [page, 20]
        request.start { (data, error) in
            self.tableview.srf_endRefreshing()
            guard error == nil else {
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
    private func deleteApi(_ mgId: Int, complete: @escaping ()->()) {
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
                    userInfo: self.editTime)
                complete()
            }
        }
    }
    
    /// 编辑
    private func editApi(_ motions: [[String : Any]],
                         complete: @escaping ()->())
    {
        let request = BaseRequest()
        request.url = BaseURL.EditMotionGroup
        request.dic = [
            "userMotionGroupId" : "\(editMgId)",
            "motionAction" : ToolClass.toJSONString(dict: motions)
        ]
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
                    userInfo: self.editTime)
                complete()
            }
        }
    }
}

extension StatisticsMotionDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr[section].arrValue("list")?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dzy_dequeueReusableHeaderFooter(
            StatisticsMotionDetailHeader.self)
        header.tag = section
        header.setData(dataArr[section])
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(StatisticsMotionDetailCell.self)
        let dic = dataArr[indexPath.section]
        if let list = dic.arrValue("list") {
            cell?.setData(list[indexPath.row], index: indexPath.row)
        }
        return cell!
    }
}

extension StatisticsMotionDetailVC: StatisticsMotionDetailHeaderDelegate {
    func motionHeader(_ header: StatisticsMotionDetailHeader,
                      didClickEditBtn btn: UIButton,
                      data: [String : Any])
    {
        data.intValue("userMotionGroupId").flatMap({
            editMgId = $0
        })
        data.stringValue("createTime").flatMap({
            $0.components(separatedBy: " ").first
            }).flatMap({
                editTime["time"] = $0
            })
        if let list = data.arrValue("list") {
            editView.initUI(list, title: title ?? "")
            popView.show(view)
        }
    }
    
    func motionHeader(_ header: StatisticsMotionDetailHeader,
                      didClickDeleteBtn btn: UIButton,
                      data: [String : Any])
    {
        let successHandler: (() -> ()) = { [weak self] in
            if let index = self?.dataArr.firstIndex(where: {
                data.intValue("userMotionGroupId") == $0.intValue("userMotionGroupId")
            }) {
                self?.dataArr.remove(at: index)
                self?.tableview.reloadData()
            }
        }
        let sureHandler: ((UIAlertAction) -> ()) = { [weak self] (_) in
            data.stringValue("createTime").flatMap({
                $0.components(separatedBy: " ").first
                }).flatMap({
                    self?.editTime["time"] = $0
                })
            if let mgId = data.intValue("userMotionGroupId") {
                self?.deleteApi(mgId, complete: successHandler)
            }
        }
        let alert = dzy_normalAlert("提示",
                                    msg: "您的操作不可逆转，是否继续？",
                                    sureClick: sureHandler,
                                    cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
}

extension StatisticsMotionDetailVC: StatisticsMotionEditViewDelegate {
    func editView(_ editView: StatisticsMotionEditView,
                  didClickSaveBtn btn: UIButton,
                  datas: [[String : Any]])
    {
        let complete = { [weak self] in
            self?.popView.hide()
            ToolClass.showToast("编辑成功", .Success)
            self?.getData(1)
        }
        let ifAllDel = datas.filter({$0.intValue("delete") == 1}).count == datas.count
        if ifAllDel {
            // 等于 0 就直接删除
            deleteApi(editMgId, complete: complete)
        }else {
            editApi(datas, complete: complete)
        }
    }
}
