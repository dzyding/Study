//
//  SearchTopicTagVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchTopicTagVC: BaseVC
{
    
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
        
        self.tableview.register(UINib(nibName: "TopicTagImgCell", bundle: nil), forCellReuseIdentifier: "TopicTagImgCell")
        self.tableview.register(UINib(nibName: "TopicTagCell", bundle: nil), forCellReuseIdentifier: "TopicTagCell")
        
        
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
        request.url = BaseURL.SearchTopicTag
        
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
    
}

extension SearchTopicTagVC: UITableViewDelegate,UITableViewDataSource,IndicatorInfoProvider
{

    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dic = dataArr[indexPath.row]
        let cover = dic["cover"] as! String
        var tableCell:UITableViewCell
        if cover == ""
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicTagCell", for: indexPath) as! TopicTagCell
            cell.setData(dic)
            
            tableCell = cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicTagImgCell", for: indexPath) as! TopicTagImgCell
            cell.setData(dic)
            
            tableCell = cell
        }
        return tableCell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        let dic = self.dataArr[indexPath.row]
        let vc = TopicTagDetailVC()
        vc.tag = (dic["name"] as! String)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
