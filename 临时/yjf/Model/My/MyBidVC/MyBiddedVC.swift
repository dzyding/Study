//
//  MyBiddedVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyBiddedVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(MyBiddedCell.self)
        listAddHeader()
        listApi(1)
    }

    //    MAKR: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.mySuccess
        request.dic = ["type" : 10]
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
}

extension MyBiddedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 201
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MyBiddedCell.self)
        cell?.delegate = self
        cell?.updateUI(dataArr[indexPath.section])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10.0))
        footer.backgroundColor = dzy_HexColor(0xF5F5F5)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension MyBiddedVC: MyBiddedCellDelegate {
    func biddedCell(_ cell: MyBiddedCell, didSelectBtn btn: UIButton, data: [String : Any]) {
        if let house = data.dicValue("house"),
            let id = house.intValue("id"),
            let dealNo = data.stringValue("dealNo")
        {
            let vc = OrderProgressBaseVC(id, dealNo: dealNo)
            dzy_push(vc)
        }
    }
}
