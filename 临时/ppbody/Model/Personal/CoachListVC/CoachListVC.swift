//
//  CoachListVC.swift
//  PPBody
//
//  Created by edz on 2019/11/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(CoachListCell.self)
        navigationItem.title = "我的教练"
        loadApi()
    }
    
    func loadApi() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MyCoach
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }
}
 
extension CoachListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(CoachListCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PersonalPageVC()
        vc.user = dataArr[indexPath.row]
        dzy_push(vc)
    }
}
