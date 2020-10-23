//
//  RelationVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RelationVC: BaseVC
{
    @IBOutlet weak var tableview: UITableView!
    var type = "1" //1为粉丝，2为关注，3为会员
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == "1" {
            self.title = "我的粉丝"
            self.tableview.register(UINib(nibName: "RelationCell", bundle: nil), forCellReuseIdentifier: "RelationCell")
            
        }
        else if type == "2" {
            self.title = "我的关注"
            self.tableview.register(UINib(nibName: "RelationCell", bundle: nil), forCellReuseIdentifier: "RelationCell")
            
        }
        else if type == "3" {
            self.title = "我的会员"
            self.tableview.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
            
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        header.backgroundColor = self.view.backgroundColor
        self.tableview.tableHeaderView = header
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        footer.backgroundColor = self.view.backgroundColor
        self.tableview.tableFooterView = footer
        
        
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
        if type == "1" {
            request.url = BaseURL.FollowList
        }
        else if type == "2" {
            request.url = BaseURL.AttentionList
        }
        else if type == "3" {
            request.url = BaseURL.CoachMemberList
        }
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

extension RelationVC: UITableViewDelegate,UITableViewDataSource,RelationCellAttentionDelegate
{
    func editRemarkName(_ indexPath: IndexPath) {
        var dic = self.dataArr[indexPath.row]
        
        let remarkView = RemarkView.instanceFromNib()
        remarkView.frame = ScreenBounds
        remarkView.userDic = dic
        remarkView.complete = { [weak self] (remark) in
            dic["remark"] = remark
            self?.dataArr[indexPath.row] = dic
            self?.tableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        self.navigationController!.view.addSubview(remarkView)
    }
    
    
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
        
        if type == "3"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
            cell.setData(dataArr[indexPath.row],indexPath: indexPath)
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelationCell", for: indexPath) as! RelationCell
            cell.setData(dataArr[indexPath.row],indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PersonalPageVC()
        vc.user = dataArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
