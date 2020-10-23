//
//  BankListVC.swift
//  PPBody
//
//  Created by edz on 2018/12/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

typealias BankModel = (name: String, logo: String)

class BankListVC: BaseVC {
    
    weak var addCardVC: AddCardVC?
    
    @IBOutlet weak var tableView: UITableView!
    
    static var data:[BankModel] = [
        ("建设银行", "bank_logo_jianshe"),
        ("中国银行", "bank_logo_zhongguo"),
        ("农业银行", "bank_logo_nongye"),
        ("招商银行", "bank_logo_zhaoshang"),
        ("工商银行", "bank_logo_gongshang"),
        ("邮储银行", "bank_logo_youzheng"),
        ("交通银行", "bank_logo_jiaotong"),
        ("浦发银行", "bank_logo_pufa"),
        ("民生银行", "bank_logo_minsheng"),
        ("兴业银行", "bank_logo_xingye"),
        ("平安银行", "bank_logo_pingan"),
        ("中信银行", "bank_logo_zhongxin"),
        ("华夏银行", "bank_logo_huaxia"),
        ("广发银行", "bank_logo_guangfa"),
        ("光大银行", "bank_logo_guangda"),
        ("北京银行", "bank_logo_beijing"),
        ("宁波银行", "bank_logo_ningbo"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择银行"
        tableView.dzy_registerCellNib(BankListCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = RGB(r: 51.0, g: 50.0, b: 55.0)
    }

}

extension BankListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BankListVC.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(BankListCell.self)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? BankListCell {
            cell.updata(BankListVC.data[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addCardVC?.updateBank(BankListVC.data[indexPath.row])
        dzy_pop()
    }
}
