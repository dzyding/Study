//
//  MyCourseHistoryVC.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyCourseHistoryVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "核销历史"
        listAddHeader()
        tableView.dzy_registerCellNib(MyCourseHistoryCell.self)
        listApi(1)
    }

    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.CourseHistory
        request.page = [page, 20]
        request.isSaasUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
}

extension MyCourseHistoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(MyCourseHistoryCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
}
