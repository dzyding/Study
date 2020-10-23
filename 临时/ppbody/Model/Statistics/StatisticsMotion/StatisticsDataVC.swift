//
//  StatisticsDataVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsDataVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var itemInfo = IndicatorInfo(title: "View")

    @IBOutlet weak var tableview: UITableView!
    
    let head = OverView.instanceFromNib()
    
    var isOther = false // 学员数据
    
    var planCode = ""
    
    /// 是否注册通知
    private var isRegist = false
    
    lazy var emptyView:EmptyView = {
       let emptyview = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        emptyview.setStyle(EmptyStyle.MotionStatistics)
        return emptyview
    }()
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //判断是否是学员
        if DataManager.memberInfo() == nil {
            isOther = false
        }else{
            isOther = true
        }
        tableview.tableHeaderView = head
        head.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overViewAction)))
        planCode = ToolClass.getPlanCode(itemInfo.title!)
        if planCode == "MG10006" {
            //有氧
            head.aveWeightLB.isHidden = true
            head.aveWeightUnitLB.isHidden = true
            head.aveWeightTitleLB.isHidden = true
            tableview.dzy_registerCellNib(BarChartViewCell.self)
        }else{
            tableview.dzy_registerCellNib(LineChartViewCell.self)
        }
        
        let refresh = Refresher{ [weak self] (loadmore) -> () in
            self?.getMotionData(loadmore ? (self!.currentPage)!+1 : 1)
            if !loadmore
            {
                self?.getOverViewData()
            }
        }
        tableview.srf_addRefresher(refresh)
        
        getOverViewData()
        getMotionData(1)
        
        registObservers([
            Config.Notify_ChangeMember
        ]) { [weak self] _ in
            let user = DataManager.memberInfo()
            if user != nil {
                self?.isOther = true
            }else{
                self?.isOther = false
            }
            self?.resetOther()
        }
    }
    
    @objc func overViewAction() {
        if planCode == "MG10006" {
            //有氧
            let vc = StatisticsCardioOverviewDetailVC()
            vc.planCode = ToolClass.getPlanCode(itemInfo.title!)
            vc.title = itemInfo.title!
            parent?.navigationController?
                .pushViewController(vc, animated: true)
            return
        }
        
        let vc = StatisticsOverviewDetailVC()
        vc.planCode = ToolClass.getPlanCode(itemInfo.title!)
        vc.title = itemInfo.title!
        parent?.navigationController?
            .pushViewController(vc, animated: true)
    }
    
    //接到学员改变通知进行切换
    func resetOther() {
        getOverViewData()
        getMotionData(1)
    }
    
//    MAKR: - 注册数据更变通知
    private func registDatasChangeNotice() {
        if isRegist {return}
        isRegist = true
        registObservers([
            Config.Notify_ChangeStatisticsData
        ]) { [weak self] _ in
            self?.getOverViewData()
            self?.getMotionData(1)
        }
    }
    
    func getOverViewData() {
        let request = BaseRequest()
        request.dic = ["planCode": planCode]
        if isOther {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.PlanOverview
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.head.setData(data!)
        }
    }
    
    func getMotionData(_ page: Int) {
        let request = BaseRequest()
        request.dic = ["planCode": ToolClass.getPlanCode(self.itemInfo.title!)]
        request.page = [page,50]
        if isOther {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.PlanMotion
        request.start { (data, error) in
            self.tableview.srf_endRefreshing()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            if self.currentPage == 1 {
                self.dataArr.removeAll()
                if listData.isEmpty {
                    self.tableview.reloadData()
                    if self.emptyView.superview == self.tableview {
                        return
                    }
                    self.tableview.addSubview(self.emptyView)
                    self.emptyView.center = CGPoint(x: self.tableview.bounds.width/2, y: self.tableview.bounds.height/2 + 50)
                    return
                }else{
                    self.emptyView.removeFromSuperview()
                }

                if self.currentPage! < self.totalPage! {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage {
                self.tableview.srf_canLoadMore(false)
            }
            self.dataArr.append(contentsOf: listData)
            
            self.tableview.reloadData()
        }
    }
}

extension StatisticsDataVC: IndicatorInfoProvider,UITableViewDelegate,UITableViewDataSource
{
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if planCode == "MG10006" {
            let chartCell = cell as? BarChartViewCell
            chartCell?.setData(self.dataArr[indexPath.row])
            return
        }
        
        let chartCell = cell as? LineChartViewCell
        chartCell?.setData(self.dataArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if planCode == "MG10006"{
            let cell = tableView
                .dzy_dequeueReusableCell(BarChartViewCell.self)
            return cell!
        }
        let cell = tableView
            .dzy_dequeueReusableCell(LineChartViewCell.self)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        registDatasChangeNotice()
        let dic = dataArr[indexPath.row]
        if planCode == "MG10006" {
            //有氧
            let vc = StatisticsCardioMotionDetailVC()
            vc.motionCode = dic["code"] as! String
            vc.title = dic["name"] as? String
            parent?.navigationController?
                .pushViewController(vc, animated: true)
            return
        }
        
        let vc = StatisticsMotionDetailVC()
        vc.motionCode = dic.stringValue("code") ?? ""
        vc.title = dic.stringValue("name")
        parent?.navigationController?
            .pushViewController(vc, animated: true)
    }
}
