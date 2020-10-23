//
//  CourseHistoryListVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class CourseHistoryListVC: BaseVC {
    @IBOutlet weak var tableList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "历史课程"
        
        
        tableList.register(UINib.init(nibName: "CoachCourseCell", bundle: nil), forCellReuseIdentifier: "CoachCourseCell")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.loadCourseApi(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableList.srf_addRefresher(refresh)
        loadCourseApi(1)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func loadCourseApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.CourseHistoryList
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
    
}

extension CourseHistoryListVC: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachCourseCell", for: indexPath) as! CoachCourseCell
        let dic = dataArr[indexPath.row]
        cell.setData(dic, history: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = dataArr[indexPath.row]
        let vc = CourseDetailVC()
        let course = dic["id"] as! Int
        vc.courseId = course
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

