//
//  LocationEvaluateListVC.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationEvaluateListVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private var dic: [String : String] = [:]
    
    private let cid: String
    
    @IBOutlet weak var tableView: UITableView!
    
    init(_ dic: [String : String], cid: String) {
        self.dic = dic
        self.cid = cid
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ cid: String) {
        self.cid = cid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAddHeader()
        initUI()
        listApi(1)
    }
    
    private func initUI() {
        navigationItem.title = "用户评价"
        tableView.dzy_registerCellNib(LGymEvaluateCell.self)
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.CommentList
        request.dic = dic
        request.page = [page, 20]
        request.setClubId(cid)
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
}

extension LocationEvaluateListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LGymEvaluateCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 322
    }
}
