//
//  AssociateInputView.swift
//  YJF
//
//  Created by edz on 2019/8/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol AssociateInputViewDelegate: class {
    func inputView(_ inputView: AssociateInputView, didClickQuestion question: [String : Any])
}

class AssociateInputView: UIView {
    
    weak var delegate: AssociateInputViewDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topLC: NSLayoutConstraint!
    
    private var datas: [[String : Any]] = []
    
    private var key: String = ""
    
    func initUI() {
        clipsToBounds = true
        backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.dzy_registerCellNib(SingleMsgCell.self)
        tableView.rowHeight = 40.0
    }
    
    func updateUI(_ datas: [[String : Any]], key: String) {
        self.datas = datas
        self.key = key
        tableView.reloadData()
        if datas.count >= 5 {
            topLC.constant = 0
        }else {
            topLC.constant = 40.0 * CGFloat(5 - datas.count)
        }
    }
}

extension AssociateInputView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(datas.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(SingleMsgCell.self)
        cell?.keyUpdateUI(datas[indexPath.row], key: key)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.inputView(self, didClickQuestion: datas[indexPath.row])
    }
}
