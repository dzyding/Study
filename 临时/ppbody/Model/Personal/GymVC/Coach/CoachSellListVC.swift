//
//  CoachSellListVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachSellListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    private var list: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "本月销售"
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(CoachSellListCell.self)
        
        listApi()
    }
    
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.MonthSellList
        request.isSaasPt = true
        request.start { (data, error) in
            self.list = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }
}

extension CoachSellListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(CoachSellListCell.self)
        cell?.updateUI(list[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

