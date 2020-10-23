//
//  TrainHistoryVC.swift
//  PPBody
//
//  Created by edz on 2020/1/7.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainHistoryVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "历史轨迹"
        tableView.dzy_registerCellNib(TrainHistoryCell.self)
        tableView.dzy_registerHeaderFooterClass(
            TrainHistoryHeaderView.self)
        tableView.dzy_registerHeaderFooterClass(
            TrainHistoryFooterView.self)
        listAddHeader(false)
        listApi(1)
    }

    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.TrainingHis
        request.isUser = true
        request.page = [page, 20]
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
}

extension TrainHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = dataArr[section].arrValue("list") ?? []
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = dataArr[indexPath.section]
            .arrValue("list") ?? []
        let cell = tableView
            .dzy_dequeueReusableCell(TrainHistoryCell.self)
        cell?.updateUI(list[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dzy_dequeueReusableHeaderFooter(
            TrainHistoryHeaderView.self)
        view.updateUI(dataArr[section])
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 28.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dzy_dequeueReusableHeaderFooter(
            TrainHistoryFooterView.self)
        view.initUI()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pid = dataArr[indexPath.section]
            .arrValue("list")?[indexPath.row]
            .intValue("id")
        else {return}
        let vc = TrainPlanFinishVC(pid)
        dzy_push(vc)
    }
}
