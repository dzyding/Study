//
//  LocationOrderBaseVC.swift
//  PPBody
//
//  Created by edz on 2019/10/31.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderBaseVC: BaseVC, BaseRequestProtocol, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private let itemInfo: IndicatorInfo
    
    private let type: LOrderType

    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        deinitObservers()
    }
    
    init(_ type: LOrderType) {
        self.itemInfo = IndicatorInfo(title: type.title())
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(LocationOrderCell.self)
        listAddHeader()
        listApi(1)
        
        registObservers([
            Config.Notify_RefreshLocationOrder
        ]) { [weak self] (_) in
            self?.listApi(1)
        }
    }
    
//    MARK: - Api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.LOrderList
        if type != .all {
            request.dic = ["type" : "\(type.apiType())"]
        }
        request.page = [page, 20]
        request.isUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
    func cancelOrderApi(_ oId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.LOrderDel
        request.dic = ["lbsOrderId" : "\(oId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                ToolClass.showToast("操作成功", .Success)
                self.listApi(1)
            }
        }
    }
}

extension LocationOrderBaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LocationOrderCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let status = dataArr[indexPath.row].intValue("status") ?? 1
        return [1, 40, 60].contains(status) ? 160 : 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataArr[indexPath.row].intValue("id").flatMap({
            let vc = LocationOrderDetailVC($0)
            dzy_push(vc)
        })
    }
}

extension LocationOrderBaseVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension LocationOrderBaseVC: LocationOrderCellDelegate {
    func orderCell(_ orderCell: LocationOrderCell,
                   didClickActionBtn btn: UIButton,
                   order: [String : Any])
    {
        guard let actionType = LOrderActionType(rawValue: btn.tag) else {
            ToolClass.showToast("无效的操作", .Failure)
            return
        }
        guard let orderId = order.intValue("id"),
            let price = order.doubleValue("actualPrice"),
            let name = order.stringValue("name")
        else {
            ToolClass.showToast("无效的数据", .Failure)
            return
        }
        switch actionType {
        case .cancel:
            let sureHandler: ((UIAlertAction) -> ()) = { [weak self] (_) in
                self?.cancelOrderApi(orderId)
            }
            let alert = dzy_normalAlert("提示",
                                        msg: "您的操作不可逆转，是否继续？",
                                        sureClick: sureHandler,
                                        cancelClick: nil)
            present(alert, animated: true, completion: nil)
        case .evaluate:
            let vc = LocationOrderEvaluateVC(orderId)
            dzy_push(vc)
        case .pay:
            let vc = LocationPayVC(orderId,
                                   price: price,
                                   name: name)
            dzy_push(vc)
        case .refund:
            let vc = LRefundOrderVC(order)
            dzy_push(vc)
        case .rProgress:
            print("退款进度")
        case .use:
            let vc = LocationOrderDetailVC(orderId)
            dzy_push(vc)
        case .none:
            print("无")
        }
    }
}
