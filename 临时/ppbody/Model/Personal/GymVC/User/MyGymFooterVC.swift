//
//  MyGymFooterVC.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymFooterVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "打卡详情"
        listAddHeader()
        tableView.dzy_registerCellNib(MyGymFooterCell.self)
        listApi(1)
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.EntryFlow
        request.page = [page, 20]
        request.isSaasUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
}

extension MyGymFooterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(MyGymFooterCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
}
