//
//  BaseRequestProtocol.swift
//  PPBody
//
//  Created by edz on 2018/12/12.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

public let Public_isSelected = "isSelected"

fileprivate extension UIScrollView {
    func sc_reloadData() {
        if let tableView = self as? UITableView {
            tableView.reloadData()
        }else if let collectionView = self as? UICollectionView {
            collectionView.reloadData()
        }
    }
}

protocol BaseRequestProtocol where Self: BasePageVC {
    var re_listView: UIScrollView {get}
    
    func pageOperation(data: [String : Any]?, isReload: Bool, isDeal: Bool)
    
    func listApi(_ page: Int)
    
    func listAddHeader(_ isHead: Bool)
    
    func changeListKey(_ key: String, data: [String : Any]?) -> [String : Any]
    
    func dealWithTheDatas(_ datas: inout [[String : Any]])
}

extension BaseRequestProtocol {
    
    func pageOperation(
        data: [String : Any]?,
        isReload: Bool = true,
        isDeal: Bool = false
    ) {
        re_listView.srf_endRefreshing()
        guard let page = data?["page"] as? [String : Any] else {return}
        var listData = data?.arrValue("list") ?? []
        if isDeal {
            dealWithTheDatas(&listData)
        }
        self.page = page
        
        if currentPage == 1 {
            dataArr.removeAll()
        }
        if currentPage! < totalPage! {
            re_listView.srf_canLoadMore(true)
        }else {
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
