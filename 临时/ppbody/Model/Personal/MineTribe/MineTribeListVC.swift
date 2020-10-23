//
//  MineTribeListVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeListVC: BaseVC {

    @IBOutlet weak var tableList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我加入的部落"
        
        tableList.register(UINib.init(nibName: "MineTribeListCell", bundle: nil), forCellReuseIdentifier: "MineTribeListCell")
    
//        let refresh = Refresher{ [weak self] (loadmore) -> Void in
//            self?.loadApi(loadmore ? (self!.currentPage)!+1 : 1)
//        }
//
//        tableList.srf_addRefresher(refresh)
        
        loadApi(1)
    }
    
    
    func loadApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.MyTribe
        request.isUser = true
        request.start { (data, error) in
            
            self.tableList.srf_endRefreshing()
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
    
//            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
//            if self.currentPage == 1
//            {
//
//                self.dataArr.removeAll()
//
//                if listData.isEmpty
//                {
//                }else{
//                    self.tableList.reloadData()
//                }
//                if self.currentPage! < self.totalPage!
//                {
//                    self.tableList.srf_canLoadMore(true)
//                }else{
//                    self.tableList.srf_canLoadMore(false)
//                }
//            }else if self.currentPage == self.totalPage
//            {
//                self.tableList.srf_canLoadMore(false)
//            }
//
            self.dataArr.append(contentsOf: listData)
            self.tableList.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MineTribeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MineTribeListCell", for: indexPath) as! MineTribeListCell
        cell.selectionStyle = .none
        cell.setData(dic: dataArr[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = dataArr[indexPath.row]
        let vc = TribeTrendsVC.init(nibName: "TribeTrendsVC", bundle: nil)
        vc.ctid = dic["ctid"] as! String
        vc.title = dic["name"] as? String
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
}







