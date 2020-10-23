//
//  MessageVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MessageVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(MessageEmptyCell.self)
        tableView.dzy_registerCellNib(MessageUnreadCell.self)
        tableView.isHidden = true
        listAddHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listApi(1)
    }
    
    //    MAKR: - Api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.message
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.tableView.isHidden = false
        }
    }
    //    MARK: - 懒加载
    lazy var header: MessageTypeHeaderView = {
        let header = MessageTypeHeaderView
            .initFromNib(MessageTypeHeaderView.self)
        header.delegate = self
        return header
    }()
}

extension MessageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.isEmpty ? 1 : dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArr.isEmpty {
            let cell = tableView
                .dzy_dequeueReusableCell(MessageEmptyCell.self)
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(MessageUnreadCell.self)
            cell?.updateUI(dataArr[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataArr.isEmpty ? 50.0 : 80.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 270
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArr.isEmpty {return}
        let msg = dataArr[indexPath.row]
        if let typeInt = msg.intValue("type"),
            let type = MessageType(rawValue: typeInt)
        {
            let vc = MessageDetailVC(msg, type: type)
            dzy_push(vc)
        }
    }
}

extension MessageVC: MessageTypeHeaderViewDelegate {
    func typeHeader(_ header: MessageTypeHeaderView, didClickType type: MessageType) {
        let vc = MessageListVC(type)
        dzy_push(vc)
    }
}
