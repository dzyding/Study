//
//  CoachCourseChildVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachCourseChildVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var tableList: UITableView!
    
    var itemInfo = IndicatorInfo(title: "View")
    var day:String?
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.delegate = self
        tableList.dataSource = self
        
        tableList.register(UINib.init(nibName: "CoachCourseCell", bundle: nil), forCellReuseIdentifier: "CoachCourseCell")
        
        loadCourseApi()

        registObservers([
            Config.Notify_AddCourseData
        ], queue: .main) { [weak self] (nofity) in
            guard let userInfo = nofity.userInfo,
                let addDay = userInfo["day"] as? String else {
                    print("No userInfo found in notification")
                    return
            }
            if addDay == self?.day {
                self?.loadCourseApi()
            }
        }
    }
    
    func loadCourseApi() {
        let request = BaseRequest()
        request.url = BaseURL.CourseList
        let day = ToolClass.getStringFormDate(date: Date.init(), format: "yyyy-MM-dd")
        let tomor = ToolClass.getStringFormDate(date: Date.init(timeIntervalSinceNow: 24*60*60), format: "yyyy-MM-dd")
        let afterTomor = ToolClass.getStringFormDate(date: Date.init(timeIntervalSinceNow: 2*24*60*60), format: "yyyy-MM-dd")
        
        if self.itemInfo.title == "今" {
            request.dic["day"] = day
            self.day = day
        }
        else if self.itemInfo.title == "明" {
            request.dic["day"] = tomor
            self.day = tomor
        }
        else if self.itemInfo.title == "后" {
            request.dic["day"] = afterTomor
            self.day = afterTomor
        }
        request.isUser = true
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.dataArr = listData
            self.tableList.reloadData()
            
        }
    }
    
    func deleteCourseApi(_ courseId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.DeleteCourse
        request.dic = ["courseId":"\(courseId)"]
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("删除成功", .Success)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CoachCourseChildVC: UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider,CoachCourseCellDelegate {
    
    //MARK: CoachCourseCellDelegate---
    func deleteCourseAction(_ cell: CoachCourseCell) {
        let indexPath = self.tableList.indexPath(for: cell)
        
        let dic = self.dataArr[(indexPath?.row)!]
        self.deleteCourseApi(dic["id"] as! Int)
        
        self.dataArr.remove(at: indexPath!.row)
        self.tableList.deleteRows(at: [indexPath!], with: .right)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count  
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachCourseCell", for: indexPath) as! CoachCourseCell
        let dic = dataArr[indexPath.row]
         cell.setData(dic)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = dataArr[indexPath.row]
        let vc = CourseDetailVC()
        let course = dic["id"] as! Int
        vc.courseId = course
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}

