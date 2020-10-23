//
//  CoachMemberListVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachMemberListVC: BaseVC {
    
    weak var setClassVC: CoachSetClassVC?
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var list: [[String : Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的会员"
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.dzy_registerCellNib(CoachMemberListCell.self)
        tableView
            .dzy_registerHeaderFooterClass(CoachMemberHeaderView.self)
        
        listApi()
    }
    
    private func clickAction(_ section: Int) {
        if setClassVC != nil {
            setClassVC?.updateStu(list[section])
            dzy_pop()
        }else {
            if let uid = list[section].stringValue("uid") {
                let vc = PersonalPageVC()
                vc.uid = uid
                dzy_push(vc)
            }
        }
    }
    
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.MemberList
        request.isSaasPt = true
        request.start { (data, error) in
            self.list = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }
}

extension CoachMemberListVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].arrValue("classes")?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arr = list[indexPath.section].arrValue("classes") ?? []
        let cell = tableView
            .dzy_dequeueReusableCell(CoachMemberListCell.self)
        cell?.updateUI(arr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickAction(indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 83
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView
            .dzy_dequeueReusableHeaderFooter(CoachMemberHeaderView.self)
        header.updateUI(list[section])
        header.handler = { [weak self] in
            self?.clickAction(section)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
