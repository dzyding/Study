//
//  WalletDetailVC.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

enum WalletDetailType {
    case sweat
    case money
}

class WalletDetailVC: BaseVC {
    
    private let type: WalletDetailType

    @IBOutlet weak var tableView: UITableView!
    
    init(_ type: WalletDetailType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "历史明细"
        tableView.dzy_registerCellNib(MoneyDetailCell.self)
        tableView.dzy_registerCellNib(SweatDetailCell.self)
        tableView.separatorStyle = .none
        listAddHeader()
        listApi(1)
    }
    
    //    MARK: - 礼物流水
    func listApi(_ page: Int) {
        let url = type == .sweat ? BaseURL.SweatFlow : BaseURL.MoneyFlow
        let request = BaseRequest()
        request.url = url
        request.page = [page, 20]
        request.isUser = true
        request.start { [weak self] (data, error) in
            self?.pageOperation(data: data, error: error)
        }
    }
}

extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .sweat:
            let cell = tableView
                .dzy_dequeueReusableCell(SweatDetailCell.self)
            return cell!
        case .money:
            let cell = tableView
                .dzy_dequeueReusableCell(MoneyDetailCell.self)
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch type {
        case .sweat:
            if let cell = cell as? SweatDetailCell {
                cell.updateViews(dataArr[indexPath.row])
            }
        case .money:
            if let cell = cell as? MoneyDetailCell {
                cell.updateUI(dataArr[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return type == .sweat ? 85 : 76
    }
}

extension WalletDetailVC: BaseRequestProtocol {
    var re_listView: UIScrollView {
        return tableView
    }
}
