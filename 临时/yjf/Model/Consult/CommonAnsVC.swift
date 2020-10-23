//
//  CommonAnsVC.swift
//  YJF
//
//  Created by edz on 2019/8/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CommonAnsVC: BaseVC {

    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var list: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "常见问题"
        inputTF.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
        inputTF.delegate = self
        tableView.dzy_registerCellNib(SingleMsgCell.self)
        listApi()
    }

    //    MARK: - api
    private func listApi(_ key: String? = nil) {
        let request = BaseRequest()
        request.url = BaseURL.commonQaList
        if let key = key {
            request.dic = ["key" : key]
        }
        request.dzy_start { (data, _) in
            self.list = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }
}

extension CommonAnsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(SingleMsgCell.self)
        cell?.normalUpdateUI(list[indexPath.row].stringValue("question") ?? "")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let qaid = list[indexPath.row].intValue("id") else {return}
        let vc = WkWebVC(.question(qaId: qaid))
        dzy_push(vc)
    }
}

extension CommonAnsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listApi(textField.text)
        textField.resignFirstResponder()
        return true
    }
}
