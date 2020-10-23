//
//  AddressListVC.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class AddressListVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet private weak var tableView: UITableView!
    
    weak var submitVC: T12GoodsSubmitVC?
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的收货地址"
        navigationItem.rightBarButtonItem = rightBtn
        tableView.rowHeight = 117
        tableView.dzy_registerCellNib(AddressListCell.self)
        listApi()
        
        registObservers([
                Config.Notify_RefreshAddressList
        ]) { [weak self] (_) in
            self?.listApi()
        }
    }
    
    @objc private func newAction() {
        let vc = AddressManagerVC(.new)
        dzy_push(vc)
    }
    
    private func editAction(_ address: [String : Any]) {
        let vc = AddressManagerVC(.edit)
        vc.old = address
        dzy_push(vc)
    }
    
    // 检查提交订单界面的地址是否还存在
    private func checkSubmitVC() {
        guard let address = submitVC?.address else {return}
        if dataArr.firstIndex(where: {
            $0.intValue("id") == address.intValue("id")
        }) == nil
        {
            submitVC?.updateAddress([:])
        }
    }
    
//    MARK: - api
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.AddressList
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr = data?.arrValue("list") ?? []
            self.tableView.reloadData()
            self.checkSubmitVC()
        }
    }
    
//    MARK: - 懒加载
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 65, height: 30)
        btn.setTitle("添加新地址", for: .normal)
        btn.setTitleColor(dzy_HexColor(0xF8E71C), for: .normal)
        btn.titleLabel?.font = dzy_Font(12)
        btn.addTarget(self,
                      action: #selector(newAction),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}

extension AddressListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(AddressListCell.self)
        let data = dataArr[indexPath.row]
        cell?.updateUI(data)
        cell?.handler = { [weak self] in
            self?.editAction(data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = submitVC else {return}
        vc.updateAddress(dataArr[indexPath.row])
        dzy_pop()
    }
}
