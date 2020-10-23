//
//  BlackListVC.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import ZKProgressHUD

class BlackListVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(BlackListCell.self)
        listAddHeader()
        listApi(1)
        navigationItem.title = "黑名单"
    }
    
    private func initBlackType() {
        (0..<dataArr.count).forEach { (index) in
            dataArr[index][SelectedKey] = false
        }
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.BlackList
        request.page = [page, 10]
        request.isUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
            self.initBlackType()
        }
    }
    
    private func blackApi(_ dic: [String : String], complete: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.BecomeBlack
        request.dic = dic
        request.isUser = true
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            complete()
        }
    }
}

extension BlackListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(BlackListCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        cell?.handler = { [weak self] in
            let data = self?.dataArr[indexPath.row] ?? [:]
            let old = data.boolValue(SelectedKey) ?? false
            let dic: [String : String] = [
                "uid" : data.stringValue("uid") ?? "",
                "type" : old ? "10" : "20"
            ]
            self?.blackApi(dic, complete: { [weak self] in
                self?.dataArr[indexPath.row][SelectedKey] = !old
                self?.tableView.reloadData()
            })
        }
        return cell!
    }
}
