//
//  MessageListVC.swift
//  YJF
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MessageListVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    private let type: MessageType
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var emptyLB: UILabel!
    
    init(_ type: MessageType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = type.name()
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        tableView.dzy_registerCellNib(MessageUnreadCell.self)
        listAddHeader()
        listApi(1)
    }
    
    //    MARK: - 为空的显示
    private func checkEmptyView() {
        emptyView.isHidden = !dataArr.isEmpty
        emptyLB.text = "您暂时未有" + type.name()
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.messageList
        request.dic = ["type" : type.rawValue]
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.checkEmptyView()
        }
    }
}

extension MessageListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(MessageUnreadCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = dataArr[indexPath.row]
        let vc = MessageDetailVC(msg, type: type)
        dzy_push(vc)
    }
}
