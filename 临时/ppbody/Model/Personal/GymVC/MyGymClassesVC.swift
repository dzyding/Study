//
//  MyGymClassesVC.swift
//  PPBody
//
//  Created by edz on 2019/11/21.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymClassesVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "剩余课程"
        tableView.dzy_registerCellNib(MyGymClassesListCell.self)
        listApi()
    }

    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.Classes
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr = data?.arrValue("list") ?? []
            print(self.dataArr)
            self.tableView.reloadData()
        }
    }
}

extension MyGymClassesVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(MyGymClassesListCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
}
