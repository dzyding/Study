//
//  BaseRequestProtocol.swift
//  PPBody
//
//  Created by edz on 2018/12/12.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

fileprivate extension UIScrollView {
    func sc_reloadData() {
        if let tableView = self as? UITableView {
            tableView.reloadData()
        }else if let collectionView = self as? UICollectionView {
            collectionView.reloadData()
        }
    }
}

/// 分页相关
protocol BaseRequestProtocol where Self: BaseVC {
    var re_listView: UIScrollView {get}
    
    func pageOperation(data: [String : Any]?,
                       error: String?,
                       isReload: Bool,
                       isDeal: Bool)
    
    func listApi(_ page: Int)
    
    func listAddHeader(_ isHead: Bool)
    
    func changeListKey(_ key: String, data: [String : Any]?) -> [String : Any]
    
    func dealWithTheDatas(_ datas: inout [[String : Any]])
}

extension BaseRequestProtocol {
    func pageOperation(data: [String : Any]?,
                       error: String?,
                       isReload: Bool = true,
                       isDeal: Bool = false)
    {
        re_listView.srf_endRefreshing()
        guard error == nil else {
            //执行错误信息
            ToolClass.showToast(error!, .Failure)
            return
        }
        guard let page = data?["page"] as? [String : Any] else {return}
        guard var listData = data?["list"] as? [[String : Any]] else {return}
        if isDeal {
            dealWithTheDatas(&listData)
        }
        self.page = page
        if currentPage == 1 {
            dataArr.removeAll()
        }
        if currentPage! < totalPage! {
            re_listView.srf_canLoadMore(true)
        }else{
            re_listView.srf_canLoadMore(false)
        }
        dataArr.append(contentsOf: listData)
        if isReload {
            re_listView.sc_reloadData()
        }
    }
    
    func listAddHeader(_ isHead: Bool = true) {
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            guard let currentPage = self?.currentPage else {return}
            self?.listApi(loadmore ? currentPage + 1 : 1)
        }
        refresh.ifHasHead = isHead
        re_listView.srf_addRefresher(refresh)
    }
    
    func changeListKey(_ key: String, data: [String : Any]?) -> [String : Any] {
        var temp = data
        let list = temp?.arrValue(key) ?? []
        temp?.removeValue(forKey: key)
        temp?.updateValue(list, forKey: "list")
        return temp ?? [:]
    }
    
    func dealWithTheDatas(_ datas: inout [[String : Any]]) {}
}
