//
//  SettlementVC.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SettlementVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    /// 需要用来判断是买方还是卖方
    private let type: DepositFunType
    
    private let amount: [String : Any]
    
    /// 70 15
    @IBOutlet weak var topLC: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    init(_ amount: [String : Any], type: DepositFunType) {
        self.amount = amount
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        listAddHeader(false)
        listApi(1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func initUI() {
        topLC.constant = 15
        view.backgroundColor = dzy_HexColor(0xF5F5F5)
        tableView.backgroundColor = dzy_HexColor(0xF5F5F5)
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(OrderFlowCell.self)
        headerView.updateUI("\(amount.doubleValue("price"), optStyle: .price)")
        footrView.updateUI(amount)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        guard let amountId = amount.intValue("amountId"),
            let priceId = amount.intValue("id")
        else {return}
        let request = BaseRequest()
        request.url = BaseURL.amountDetail
        request.dic = [
            "userAmountId" : amountId,
            "cashPriceId" : priceId
        ]
        request.page = [page, 20]
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
        }
    }
    
    //    MARK: - 懒加载
    lazy var headerView: SettlementHeaderView = {
        let header = SettlementHeaderView
            .initFromNib(SettlementHeaderView.self)
        return header
    }()
    
    lazy var footrView: SettlementFooterView = {
        let footer = SettlementFooterView
            .initFromNib(SettlementFooterView.self)
        footer.delegate = self
        return footer
    }()
}

extension SettlementVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(OrderFlowCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 270
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footrView
    }
}

extension SettlementVC: SettlementFooterViewDelegate {
    func footer(_ footer: SettlementFooterView, didClickPayBtn btn: UIButton) {
        guard let price = amount.doubleValue("price"),
            let cashId = amount.intValue("id")
        else {
            showMessage("数据错误")
            return
        }
        let dic: [String : Any] = [
            "price" : abs(price),
            "type" : type == .payBuyFlow ? 50 : 60,
            "cashId" : cashId,
            "userType" : type == .payBuyFlow ? 10 : 20,
            ]
        let vc = PayMoneyVC(dic, type: .payFlow)
        dzy_push(vc)
    }
}
