//
//  CoachClassListVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachClassListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    private var list: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "本月课程"
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.dzy_registerCellNib(CoachClassListCell.self)
        
        listApi()
    }
    
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.MonthClassList
        request.isSaasPt = true
        request.start { (data, error) in
            self.list = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }
}

extension CoachClassListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(CoachClassListCell.self)
        cell?.updateUI(list[indexPath.row])
        cell?.lineView.isHidden = indexPath.row == list.count - 1
        return cell!
    }
    
}
