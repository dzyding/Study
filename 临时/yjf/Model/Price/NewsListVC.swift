//
//  NewsListVC.swift
//  YJF
//
//  Created by edz on 2019/8/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum NewsType {
    /// 房产新闻
    case house
    /// 政策法规
    case policy
    /// 专家点评
    case expert
    
    func intType() -> Int {
        switch self {
        case .house:
            return 10
        case .policy:
            return 20
        case .expert:
            return 30
        }
    }
    
    func strValue() -> String {
        switch self {
        case .house:
            return "房产新闻"
        case .policy:
            return "政策法规"
        case .expert:
            return "专家点评"
        }
    }
}

class NewsListVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private let type: NewsType

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var emptyLB: UILabel!
    
    init(_ type: NewsType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        listAddHeader()
        listApi(1)
        tableView.dzy_registerCellNib(NewsListCell.self)
    }
    
    private func initUI() {
        switch type {
        case .expert:
            emptyLB.text = "暂无专家点评"
        case .house:
            emptyLB.text = "暂无房产新闻"
        case .policy:
            emptyLB.text = "暂无政策法规"
        }
    }

    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.newsList
        request.dic = ["type" : type.intType()]
        request.page = [page, 10]
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
}

extension NewsListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(NewsListCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pid = dataArr[indexPath.row].intValue("id") else {
            ToolClass.showToast("数据错误", .Failure)
            return
        }
        let vc = NewsDetailVC(pid, vcTitle: type.strValue())
        dzy_push(vc)
    }
}
