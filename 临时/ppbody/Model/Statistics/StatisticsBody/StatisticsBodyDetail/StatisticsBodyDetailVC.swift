//
//  StatisticsBodyDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsBodyDetailVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    
    var bodyPart = ""
    
    var isOther = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ToolClass.getTitleFromLetter(bodyPart)
        
        //判断是否是学员
        if DataManager.memberInfo() == nil {
            isOther = false
        }else{
            isOther = true
        }
        
        tableview.register(UINib(nibName: "StatisticsBodyDetailCell", bundle: nil), forCellReuseIdentifier: "StatisticsBodyDetailCell")
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableview.srf_addRefresher(refresh)
        
        getData(1)
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["bodyPart":bodyPart]
        if isOther
        {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.BodyPart
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
            
            if self.currentPage == 1
            {
                
                self.dataArr.removeAll()
                
                if listData.isEmpty
                {
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

}

extension StatisticsBodyDetailVC:UITableViewDelegate,UITableViewDataSource
{
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsBodyDetailCell", for: indexPath) as! StatisticsBodyDetailCell
        cell.setData(dataArr[indexPath.row], bodyPart)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
