//
//  AddMoneyVC.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import StoreKit
import ZKProgressHUD

let Recharge = "ppbody_sweat_recharge_"

fileprivate typealias PayModel = (transactionId: String, rechargeId: String, iap: String?)

fileprivate var key = "SKReceiptRefreshRequest"

fileprivate extension SKReceiptRefreshRequest {
    var trans: SKPaymentTransaction? {
        get {
            return objc_getAssociatedObject(self, &key) as? SKPaymentTransaction
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
}

class AddSweatVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    // 所有初次获取票据失败的订单id
    fileprivate var orders: [PayModel] = []
    
    var payQueue: SKPaymentQueue {
        return SKPaymentQueue.default()
    }
    //接口返回的商品数据
    var localDatas: [[String : Any]] = []
    
    var header: AddSweatHeaderView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "汗水充值"
        
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(AddSweatCell.self)
        
        let footer = AddSweatFooterView.initFromNib()
        footer.proHandler = { [weak self] in
            self?.gotoProDetail()
        }
        tableView.tableFooterView = footer
        
        // 添加内购的观察者
        payQueue.add(self)
        
        listApi()
    }
    
    //获取商品列表
    func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.RechargeList
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let list = data?["list"] as? [[String : Any]], list.count > 0 {
                self?.localDatas = list
                self?.tableView.reloadData()
                self?.tableView.isHidden = false
            }else {
                ToolClass.showToast("无可购买商品", .Failure)
            }
        }
    }
    
    //完成订单
    fileprivate func finishOrderApi(_ trans: SKPaymentTransaction, _ model: PayModel) {
        ZKProgressHUD.show()
        let sweat = model.rechargeId.replacingOccurrences(of: Recharge, with: "")
        guard let rechargeId = localDatas.filter({$0.intValue("sweat") == Int(sweat)}).first?.intValue("id") else {return}
        let request = BaseRequest()
        request.url = BaseURL.IapVerify
        request.dic = [
            "rechargeId" : "\(rechargeId)",
            "transactionId" : model.transactionId,
            "payload" : model.iap ?? ""
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                ToolClass.showToast(error ?? "", .Failure)
                return
            }
            ToolClass.showToast("充值成功", .Success)
            self?.changeLocalSweat(sweat)
            self?.payQueue.finishTransaction(trans)
        }
    }
    
    func changeLocalSweat(_ s: String) {
        if let count = Int(s) {
            let sweat = DataManager.getSweat()
            DataManager.changeSweat(sweat + count)
            header?.sweatLB.text = "\(sweat + count) 汗水"
        }
    }
    
    // 检查是否允许应用内购买
    func checkAuthority() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // 查询商品
    func requestProducts(_ ids: [String]) {
        if !checkAuthority() {
            ToolClass.showToast("没有购买权限", .Failure)
            return
        }
        let set = Set(ids)
        let request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
        ZKProgressHUD.show()
    }
    
    // 创建订单前检查一下是否有未完成的交易
    func checkExistedOrder() {
        let transactions = payQueue.transactions
        if let trans = transactions.first,
            trans.transactionState == .purchased
        {
            payQueue.finishTransaction(trans)
        }
    }
    
    // 创建支付订单
    func createOrder(_ product: SKProduct) {
        checkExistedOrder()
        let payment = SKPayment(product: product)
        payQueue.add(payment)
        ZKProgressHUD.show()
    }
    
    // 获取票据
    func iapReceipt() -> String? {
        var str: String? = nil
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path)
        {
            do {
                let data = try Data(contentsOf: receiptURL)
                str = data.base64EncodedString()
            }catch {
                dzy_log("获取票据失败")
            }
        }
        return str
    }
    
    // 如果获取票据失败，刷新票据结果
    func refreshReceipt(_ trans: SKPaymentTransaction) {
        let refresh = SKReceiptRefreshRequest(receiptProperties: nil)
        refresh.trans = trans
        refresh.delegate = self
        refresh.start()
    }
    
    //    MARK: - 前往协议详情
    func gotoProDetail() {
        let vc = WKWebVC(Config.AddMoneyPro, false)
        vc.title = "充值服务协议"
        dzy_push(vc)
    }
    
    deinit {
        payQueue.remove(self)
    }
}

extension AddSweatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(AddSweatCell.self)!
        cell.product = localDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 59
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AddSweatHeaderView.initFromNib()
        header.sweatLB.text = "\(DataManager.getSweat()) 滴汗水"
        self.header = header
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sweat = localDatas[indexPath.row].intValue("sweat") {
            requestProducts([Recharge + "\(sweat)"])
        }
    }
}

extension AddSweatVC: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        ZKProgressHUD.dismiss()
        if let product = response.products.first {
            createOrder(product)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // 失败
        if request.isKind(of: SKReceiptRefreshRequest.self) {
            ToolClass.showToast("刷新票据失败", .Failure)
        }else if request.isKind(of: SKProductsRequest.self) {
            ZKProgressHUD.dismiss()
            ToolClass.showToast("获取商品失败", .Failure)
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        // 完成
        if let final = request as? SKReceiptRefreshRequest,
            let trans = final.trans,
            let transid = trans.transactionIdentifier
        {
            // 刷新票据
            if let iap = iapReceipt() {
                for index in (0..<orders.count) {
                    if orders[index].transactionId == transid {
                        finishOrderApi(trans, (
                            transactionId: transid,
                            rechargeId: orders[index].rechargeId,
                            iap: iap
                        ))
                        orders.remove(at: index)
                        break
                    }
                }
            }else {
                ToolClass.showToast("刷新票据失败", .Failure)
            }
        }else if request.isKind(of: SKProductsRequest.self) {
            // 查询商品
            ZKProgressHUD.dismiss()
        }
    }
}

extension AddSweatVC: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        ZKProgressHUD.dismiss()
        for trans in transactions {
            switch trans.transactionState {
            case .purchasing:   //加入队列
                dzy_log("purchasing")
            case .deferred:     //队列中
                dzy_log("deferred")
            case .purchased:    //完成
                dzy_log("purchased")
                if let iap = iapReceipt() {
                    finishOrderApi(trans, (
                        transactionId: trans.transactionIdentifier ?? "errorOrder",
                        rechargeId: trans.payment.productIdentifier,
                        iap: iap
                    ))
                }else {
                    // 没有第一时间获取到的，本地存一下
                    orders.append(
                        (trans.transactionIdentifier ?? "errorOrder", //订单 id
                         trans.payment.productIdentifier,     //商品 id
                         nil)
                    )
                    refreshReceipt(trans)
                }
            case .failed:       //失败
                payQueue.finishTransaction(trans)
            case .restored:     //购买过
                payQueue.finishTransaction(trans)
            @unknown default:
                dzy_log("unknown default")
            }
        }
    }
}
