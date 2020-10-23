//
//  MsgAttentionVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MsgSupportTopicVC: BaseVC {
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "点赞列表"
        
        self.tableview.register(UINib(nibName: "MsgSupportTopicCell", bundle: nil), forCellReuseIdentifier: "MsgSupportTopicCell")
                
        
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
        request.url = BaseURL.MsgTopicSupportList
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

extension MsgSupportTopicVC: UITableViewDelegate,UITableViewDataSource
{
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgSupportTopicCell", for: indexPath) as! MsgSupportTopicCell
        cell.setData(dataArr[indexPath.row])
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.dataArr[indexPath.row]
        let topic = dic["topic"] as! [String:Any]
        
        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        
        let topicDetailModel = TopicDetailModel()
        topicDetailModel.dataTopic = [topic]
        vc.topicDetailModel = topicDetailModel
        vc.initIndex = IndexPath(row: 0, section: 0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
