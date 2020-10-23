//
//  StatisticsBodyVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsBodyVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var isOther = false//学员数据
    
    lazy var tableview:UITableView = {
        let tableview = UITableView(frame: self.view.bounds)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = BackgroundColor
        tableview.separatorStyle = .none
        tableview.alwaysBounceVertical = true
        tableview.register(UINib(nibName: "StatisticsBodyCell", bundle: nil), forCellReuseIdentifier: "StatisticsBodyCell")
        return tableview
    }()
    
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
        
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableview.srf_canLoadMore(false)
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getBodyData()
        }
        
        tableview.srf_addRefresher(refresh)
        getBodyData()
        
        registObservers([
            Config.Notify_ChangeMember
        ], queue: .main) {[weak self] _ in
            let user = DataManager.memberInfo()
            if user != nil {
                self?.isOther = true
            }else{
                self?.isOther = false
            }
            self?.resetOther()
        }
        registObservers([
            Config.Notify_BodyDataChange,
            Config.Notify_ChangeStatisticsData
        ]) { [weak self] _ in
            self?.getBodyData()
        }
    }
    
    //学员切换
    func resetOther()
    {
        self.dataArr.removeAll()
        self.getBodyData()
    }
    
    func getBodyData()
    {
        let request = BaseRequest()
        if isOther
        {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.LastBodyData
        request.start { (data, error) in
            
            self.tableview.srf_endRefreshing()
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.dataArr.removeAll()
            
            let body = data!["bodyData"] as! [String:Any]
            
            let weightDic = ["weight": body["weight"] as! [Double]]
            self.dataArr.append(weightDic)
      
            let muscleDic = ["muscle": body["muscle"] as! [Double]]
            self.dataArr.append(muscleDic)
            
            let fatDic = ["fat": body["fat"] as! [Double]]
            self.dataArr.append(fatDic)
            
            let armDic = ["arm": body["arm"] as! [Double]]
            self.dataArr.append(armDic)
            
            let bustDic = ["bust": body["bust"] as! [Double]]
            self.dataArr.append(bustDic)
            
            let thighDic = ["thigh": body["thigh"] as! [Double]]
            self.dataArr.append(thighDic)
            
            let hiplineDic = ["hipline": body["hipline"] as! [Double]]
            self.dataArr.append(hiplineDic)
            
            let waistDic = ["waist": body["waist"] as! [Double]]
            self.dataArr.append(waistDic)
           
            self.tableview.reloadData()
        }
    }
}

extension StatisticsBodyVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let chartCell = cell as? StatisticsBodyCell
        chartCell?.setData(self.dataArr[indexPath.row], indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsBodyCell", for: indexPath) as! StatisticsBodyCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = self.dataArr[indexPath.row]
        let title = dic.keys.first
        let vc = StatisticsBodyDetailVC()
        vc.bodyPart = title!
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
