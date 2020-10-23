//
//  MsgAttentionVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MsgAttentionVC: BaseVC {
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "关注列表"
        
        self.tableview.register(UINib(nibName: "MsgAttentionCell", bundle: nil), forCellReuseIdentifier: "MsgAttentionCell")
                
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
        request.url = BaseURL.MsgUserFollowList
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
    
    //关注用户 和取消
    func attentionAPI(uid: String, _ isAttention: Bool)
    {
        let request = BaseRequest()
        request.dic = ["uid":uid,"type":isAttention ? "10" : "20"]
        request.url = BaseURL.Attention
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            NotificationCenter.default.post(name: Config.Notify_AttentionPersonal, object: nil, userInfo: ["uid":uid])
        }
    }
}

extension MsgAttentionVC: UITableViewDelegate,UITableViewDataSource,RelationCellAttentionDelegate
{
    
    func attentionIndexPath(_ indexPath: IndexPath, isAttention: Bool) {
        var dic = self.dataArr[indexPath.row]
        let uid = dic["uid"] as! String
        
        self.attentionAPI(uid: uid, isAttention)
        
        dic["isAttention"] = isAttention ? 1 : 0
        
        self.dataArr[indexPath.row] = dic
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgAttentionCell", for: indexPath) as! MsgAttentionCell
        cell.setData(dataArr[indexPath.row],indexPath: indexPath)
        cell.delegate = self
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PersonalPageVC()
        vc.user = dataArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
