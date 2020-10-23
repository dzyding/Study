//
//  GoodsOrderVC.swift
//  PPBody
//
//  Created by edz on 2019/11/13.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class GoodsOrderVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商品订单"
        tableView.dzy_registerCellNib(GoodsOrderCell.self)
        listApi(1)
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.GOrderList
        request.page = [page, 20]
        request.isUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }

}

extension GoodsOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(GoodsOrderCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GoodsOrderDetailVC(dataArr[indexPath.row])
        dzy_push(vc)
    }
}
