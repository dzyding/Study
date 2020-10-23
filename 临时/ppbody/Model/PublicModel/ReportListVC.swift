//
//  ReportListVC.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum ReportType {
    case video
    case user
}

class ReportListVC: BaseVC {

    @IBOutlet private weak var tableView: UITableView!
    
    private let type: ReportType
    
    private let data: [String : Any]
    
    private var titles: [String] {
        switch type {
        case .user:
            return ["内容违规", "账号违规", "其他"]
        case .video:
            return ["内容违规", "未成年", "其他"]
        }
    }
    
    private var datas: [[String]] {
        switch type {
        case .user:
            return [
                [
                    "色情低俗", "政治敏感", "违法犯罪",
                    "发布垃圾广告、售卖假货等", "造谣传谣、涉嫌欺诈"
                ],
                ["冒充官方", "头像、昵称、签名违规"],
                ["疑似自我伤害", "侮辱谩骂"]
            ]
        case .video:
            return [
                [
                    "色情低俗", "政治敏感", "违法犯罪",
                    "发布垃圾广告、售卖假货等", "造谣传谣、涉嫌欺诈", "侮辱谩骂"
                ],
                ["未成年人不当行为", "内容不适合未成年观看"],
                [
                    "引人不适", "疑似自我伤害",
                    "诱导点赞、分享、关注", "其他"
                ]
            ]
        }
    }
    
    init(_ type: ReportType, data: [String : Any]) {
        self.type = type
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case .user:
            navigationItem.title = "用户举报"
        case .video:
            navigationItem.title = "视频举报"
        }
        tableView.dzy_registerCellNib(ReportListCell.self)
        tableView.register(ReportListHeaderView.self, forHeaderFooterViewReuseIdentifier: "ReportListHeaderView")
        tableView.register(ReportListFooterView.self, forHeaderFooterViewReuseIdentifier: "ReportListFooterView")
    }
}

extension ReportListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(ReportListCell.self)!
        cell.titleLB.text = datas[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ReportListFooterView") as? ReportListFooterView
        return footer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ReportListHeaderView") as? ReportListHeaderView
        header?.label.text = titles[section]
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = datas[indexPath.section][indexPath.row]
        var temp: [String : String] = ["title" : info]
        switch type {
        case .video:
            temp["tid"] = data.stringValue("tid") ?? ""
            temp["uid"] = data.dicValue("user")?.stringValue("uid") ?? ""
        case .user:
            temp["uid"] = data.dicValue("user")?.stringValue("uid") ?? ""
        }
        let vc = ReportDetailVC(type, data: temp)
        dzy_push(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
