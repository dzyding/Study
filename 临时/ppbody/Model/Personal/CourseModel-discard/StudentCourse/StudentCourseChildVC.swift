//
//  StudentCourseChildVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class StudentCourseChildVC: BaseVC {
    
    @IBOutlet weak var tableList: UITableView!
    var itemInfo = IndicatorInfo(title: "View")
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.register(UINib.init(nibName: "StudentCourseCell", bundle: nil), forCellReuseIdentifier: "StudentCourseCell")
        tableList.showsVerticalScrollIndicator = false
        tableList.separatorStyle = .none
        tableList.estimatedRowHeight = 130.0
        tableList.rowHeight = UITableView.automaticDimension
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.loadApi(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableList.srf_addRefresher(refresh)
        
        loadApi(1)

        
        // Do any additional setup after loading the view.
    }
    
    func loadApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.MyCourse
        if self.itemInfo.title == "待学习" {
            request.dic["type"] = "10"
        }
        else if self.itemInfo.title == "已学习" {
            request.dic["type"] = "20"
        }
        request.page = [page,20]
        request.isUser = true
        request.start { (data, error) in
            
            self.tableList.srf_endRefreshing()
            
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
                    self.tableList.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.tableList.srf_canLoadMore(true)
                }else{
                    self.tableList.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.tableList.srf_canLoadMore(false)
            }
            self.dataArr.append(contentsOf: listData)
            self.tableList.reloadData()
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StudentCourseChildVC: UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCourseCell", for: indexPath) as! StudentCourseCell
        cell.selectionStyle = .none
        
        let dic = self.dataArr[indexPath.row]
        if itemInfo.title == "已学习" {
            cell.type = "2"
            cell.setData(data: dic)
            
        }
        else  {
            cell.type = "1"
            cell.setData(data: dic)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.dataArr[indexPath.row]
        if self.itemInfo.title == "待学习"
        {
            let planCode = dic["planCode"] as? String
            
            if planCode == nil || (planCode?.isEmpty)!{
                return
            }
            
            let vc = StudentCourseDetailVC()
            vc.planCode = planCode
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = CourseDetailVC()
            let course = dic["id"] as! Int
            vc.courseId = course
            self.navigationController?.pushViewController(vc, animated: true)
        }

        
    }
}












