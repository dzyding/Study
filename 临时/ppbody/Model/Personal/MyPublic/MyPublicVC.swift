//
//  MyPublicVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MyPublicVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    
    var timeArr = [String]()
    
    let topicDetailModel = TopicDetailModel()
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    override func viewDidLoad() {
        
        self.title = "我的发布"
        self.tableview.register(UINib(nibName: "MyPublicCell", bundle: nil), forCellReuseIdentifier: "MyPublicCell")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
        getData(1)
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.page = [page,20]
        request.isUser = true
        request.url = BaseURL.MyPublicTopic
        request.start { (data, error) in
            
            self.tableview.srf_endRefreshing()
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            if self.currentPage == 1
            {
                self.dataArr.removeAll()
                self.timeArr.removeAll()
                self.dataDic.removeAll()
                
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
            //做数据处理
            DispatchQueue.global().async {
                
                self.groupArr(listData)
                
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                    self.tableview.layoutIfNeeded()

                }
            }
        }
    }
    
    //重新组合日期数据
    func groupArr(_ list:[[String: Any]])
    {
    
        for item in list {
            let keys = Array(self.dataDic.keys)

            let createTime = item["createTime"] as! String
            let dateTime = createTime[0..<9]
            
            if !timeArr.contains(dateTime)
            {
                timeArr.append(dateTime)
                
                timeArr = timeArr.sorted(by: { (s1, s2) -> Bool in
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "yyyy-MM-dd"
                    let date1 = dateFormat.date(from: s1)
                    let date2 = dateFormat.date(from: s2)
                    return date2!.compare(date1!) == .orderedAscending
                })
            }

            
            if keys.contains(dateTime)
            {
                var arrData = self.dataDic[dateTime] as! [[String:Any]]
                arrData.append(item)
                self.dataDic[dateTime] = arrData
            }else{
                var arrData = [[String:Any]]()
                arrData.append(item)
                self.dataDic[dateTime] = arrData
            }
        }
    }
    
    
    func latelyIsToday() -> Bool {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let todayStr = dateFormat.string(from: Date())
            
        if self.timeArr.contains(todayStr)
        {
            return true
        }
        
        return false
    }
    
    //tableview 转 collectionview
    func getCollectionViewIndexPath(_ indexPath: IndexPath) -> IndexPath
    {
        
        var index = 0
        let sections = latelyIsToday() ? indexPath.section : indexPath.section - 1
        for section in 0...sections
        {
            let listData = dataDic[timeArr[section]] as! [[String:Any]]
            
            index += section == sections ? indexPath.row : listData.count
        }
        
        if latelyIsToday() {
            if sections == 0
            {
                index -= 1
            }
        }
       
        return IndexPath(item: index, section: 0)
    }
    
    //collectionview 转 tableview
    func getTableviewIndexPath(_ indexPath: IndexPath) -> IndexPath
    {
        print(indexPath)

        var sectionTV = 0
        var rowTV = 0
        var index = indexPath.row + 1
        for section in 0..<self.timeArr.count
        {
            let listData = dataDic[timeArr[section]] as! [[String:Any]]

            index -= listData.count
            
            if index <= 0
            {
                sectionTV = section
                rowTV = listData.count + index - 1
                break
            }
        }
        
        if latelyIsToday() {
            if sectionTV == 0
            {
                rowTV += 1
            }
        }else{
            sectionTV += 1
        }
        
        print(IndexPath(item: rowTV, section: sectionTV))

        return IndexPath(item: rowTV, section: sectionTV)
    }
    
    
    func deleteTopicAPI(_ tid: String)
    {
        
        let request = BaseRequest()
        request.dic = ["tid":tid]
        request.isUser = true
        request.url = BaseURL.DeleteTopic
        request.start { (data, error) in
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
        }
    }
}


extension MyPublicVC:UITableViewDelegate,UITableViewDataSource,TopicDetailScrollDelegate
{
    
    // MARK: - TopicDetailScrollDelegate
    func needLoadMore() {
        self.getData(self.currentPage!+1)
    }
    
    func scrollAtIndex(_ indexPath: IndexPath) {
        
        self.tableview.scrollToRow(at: getTableviewIndexPath(indexPath), at: .middle, animated: false)
    }
    
    func supportForIndex(_ indexPath: IndexPath, isSelect: Bool) {
        var dic = self.dataArr[indexPath.row]
        
        if (dic["isSupport"] as? Int) != nil
        {
            dic["isSupport"] = isSelect ? 1 : 0
        }
        
        var supportNum = dic["supportNum"] as! Int
        
        if isSelect
        {
            supportNum += 1
        }else{
            supportNum -= 1
        }
        dic["supportNum"] = supportNum
        
        self.dataArr[indexPath.row] = dic
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if latelyIsToday() {
            return timeArr.count
        }
        return timeArr.count + 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if latelyIsToday() {
            
            let listData = dataDic[timeArr[section]] as! [[String:Any]]
            return section == 0 ? listData.count + 1 : listData.count
        }else{
            if section == 0
            {
                return 1
            }else{
                let listData = dataDic[timeArr[section-1]] as! [[String:Any]]
                return listData.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPublicCell", for: indexPath) as! MyPublicCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myPublicCell = cell as? MyPublicCell
        
        if latelyIsToday() {
            if indexPath.section == 0 {
               
                if indexPath.row == 0 {

                    myPublicCell?.setData([String: Any](), indexPath)
                }
                else {
                    let listData = dataDic[timeArr[indexPath.section]] as! [[String:Any]]

                    myPublicCell?.setData(listData[indexPath.row-1],indexPath)
                }
            }
            else {
                let listData = dataDic[timeArr[indexPath.section]] as! [[String:Any]]
                myPublicCell?.setData(listData[indexPath.row],indexPath)
            }
            
        }
        else {
            if indexPath.section == 0 {
                myPublicCell?.setData([String: Any](), indexPath)
            }
            else {
                let listData = dataDic[timeArr[indexPath.section-1]] as! [[String:Any]]
                 myPublicCell?.setData(listData[indexPath.row],indexPath)
            }
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0
        {
            //拍照
            let mask = MaskPublicView.instanceFromNib()
            mask.initUI()
            mask.frame = ScreenBounds
            mask.navigationVC = self.navigationController
            UIApplication.shared.keyWindow?.addSubview(mask)
            return
        }

        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        vc.initIndex = getCollectionViewIndexPath(indexPath)
        vc.delegate = self
        vc.topicDetailModel = topicDetailModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 0
        {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let alert =  UIAlertController.init(title: "请确认是否删除？", message: "", preferredStyle: .alert)
            let actionN = UIAlertAction.init(title: "是", style: .default) { (_) in

                let cell = self.tableview.cellForRow(at: indexPath) as! MyPublicCell
                
                let tid = cell.tid
                
                if tid == nil
                {
                    return
                }
                self.deleteTopicAPI(tid!)
                
                self.dataArr.remove(at: self.getCollectionViewIndexPath(indexPath).row)
                
                var cellNum = 0
                if self.latelyIsToday() {
                   
                    let listData = self.dataDic[self.timeArr[indexPath.section]] as! [[String:Any]]
                    cellNum = listData.count
                    
                }
                else {
       
                    let listData = self.dataDic[self.timeArr[indexPath.section-1]] as! [[String:Any]]
                    cellNum = listData.count
                }
                
                DispatchQueue.global().async {
                    self.dataDic.removeAll()
                    self.timeArr.removeAll()
                    self.groupArr(self.dataArr)
                    
                    DispatchQueue.main.async {
                        if cellNum == 1
                        {
                            if indexPath.section == 0
                            {
                                self.tableview.deleteRows(at: [indexPath], with: .right)
                            }else{
                                self.tableview.deleteSections([indexPath.section], with: .right)
                            }
                        }else{
                            self.tableview.deleteRows(at: [indexPath], with: .right)
                        }
                    }
                }
            }
            let actionY = UIAlertAction.init(title: "否", style: .cancel) { (_) in
                
            }
            alert.addAction(actionN)
            alert.addAction(actionY)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
