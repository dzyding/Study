//
//  SearchPersonalVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchPersonalVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    var itemInfo = IndicatorInfo(title: "View")

    var key:String?
    
    lazy var emptyView:EmptyView = {
        let emptyview = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        emptyview.setStyle(EmptyStyle.SearchEmpty)
        return emptyview
    }()
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.register(UINib(nibName: "SearchPersonalCell", bundle: nil), forCellReuseIdentifier: "SearchPersonalCell")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
    
        if key != nil && !(key?.isEmpty)!
        {
            getData(1)
        }
    }
    
    func startSearch(_ key: String)
    {
        self.key = key
        if self.tableview != nil
        {
            getData(1)
        }
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["key": self.key!]
        request.page = [page,20]
        request.isUser = true
        request.url = BaseURL.SearchPersonal

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
                    if self.emptyView.superview == self.tableview
                    {
                        return
                    }
                    self.tableview.addSubview(self.emptyView)
                    self.emptyView.center = CGPoint(x: self.tableview.bounds.width/2, y: self.tableview.bounds.height/2 - 40)
                    
                    return
                    
                }else{
                    self.emptyView.removeFromSuperview()
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

extension SearchPersonalVC: UITableViewDelegate,UITableViewDataSource,SearchPersonalCellAttentionDelegate,IndicatorInfoProvider
{
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPersonalCell", for: indexPath) as! SearchPersonalCell
        cell.setData(dataArr[indexPath.row],indexPath: indexPath)
        cell.delegate = self
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PersonalPageVC()
        vc.user = self.dataArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
