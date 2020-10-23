//
//  DepositContentClassVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class DepositContentVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak private var bottomView: UIView!
    
    private let type: DepositType

    @IBOutlet weak private var emptyView: UIView!
    
    @IBOutlet weak private var emptyIV: UIImageView!
    
    @IBOutlet weak private var emptyLB: UILabel!
    
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var sureBtn: UIButton!
    
    @IBOutlet weak private var tableViewBottomLC: NSLayoutConstraint!
    /// 用户账户 id
    private var amountId: Int?
    /// 分账户 id
    private var priceId: Int?
    
    private var amounts: [[String : Any]] = []
    
    private var observer: Any?
    
    private var userType: Identity? {
        if let pvc = parent as? DepositVC {
            return pvc.type
        }else {
            return nil
        }
    }
    
    private var apiType: Int {
        switch type {
        case .buy_look:
            return 10
        case .buy_flow:
            return 20
        case .buy_deposit:
            return 30
        case .sell_lock:
            return 40
        case .sell_flow:
            return 50
        case .sell_deposit:
            return 60
        }
    }
    
    init(_ type: DepositType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        tableViewRegist()
        listAddHeader(false)
        amountApi()
        observerFunc()
    }
    
    //    MARK: - 获取用户账户信息成功
    func amountApiSuccess(_ data: [String : Any]?) {
        guard let amount = data?.dicValue("userAmount") else {return}
        amountId = amount.intValue("id")
        amounts = data?.arrValue("cashPriceList") ?? []
        
        if let pvc = parent as? DepositVC,
            (type == .buy_look || type == .sell_lock)
        {
            pvc.updateUI(amount)
        }
        if amounts.count > 0 {
            selectedFunc(0)
        }
    }
    
    //    MARK: - 选中对应账户
    private func selectedFunc(_ row: Int) {
        priceId = amounts[row].intValue("id")
        (0..<amounts.count).forEach { (index) in
            amounts[index][Public_isSelected] = index == row
        }
        listApi(1)
    }
    
    private func setUI() {
        var btnTitle = ""
        var emptyStr = ""
        var emptyImg = ""
        var selector: Selector?
        switch type {
        case .buy_deposit, .sell_deposit:
            btnTitle = "缴纳交易保证金"
            emptyStr = "您还未缴纳交易保证金"
            emptyImg = "order_deposit_empty"
            selector = type == .buy_deposit ?
                #selector(payBuyDeposit) : #selector(paySellDeposit)
        case .buy_look:
            btnTitle = "缴纳看房押金"
            emptyStr = "您还未缴纳看房押金"
            emptyImg = "look_deposit_empty"
            selector = #selector(payBuyDeposit)
        case .buy_flow, .sell_flow:
            tableViewBottomLC.constant = isiPhoneXScreen() ? 34 : 0
            emptyStr = "您还未产生交易收支"
            emptyImg = "order_flow_empty"
        case .sell_lock:
            btnTitle = "缴纳门锁押金"
            emptyStr = "您还未缴纳门锁押金"
            emptyImg = "lock_deposit_empty"
            selector = #selector(paySellDeposit)
        }
        sureBtn.setTitle(btnTitle, for: .normal)
        emptyLB.text  = emptyStr
        emptyIV.image = UIImage(named: emptyImg)
        if let selector = selector {
            sureBtn.addTarget(
                self, action: selector, for: .touchUpInside
            )
        }
    }
    
    private func showEmptyView(_ hidden: Bool) {
        emptyView.isHidden = !hidden
        bottomView.isHidden = hidden
        tableView.isHidden = hidden
    }
    
    private func tableViewRegist() {
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(DepositTitleOneLBCell.self)
        tableView.dzy_registerCellNib(DepositTitleTwoLBCell.self)
        tableView.dzy_registerCellNib(OrderFlowCell.self)
    }
    
    private func observerFunc() {
        observer = NotificationCenter.default.addObserver(
            forName: PublicConfig.Notice_UpdateDepositFlow,
            object: nil,
            queue: .main,
            using: { [weak self] (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.amountApi()
                }
        })
    }
    
    //    MARK: - 缴纳交易保证金
    @objc private func payBuyDeposit() {
        let vc = PayBuyDepositVC(.normal)
        dzy_push(vc)
    }
    
    @objc private func paySellDeposit() {
        let vc = PaySellDepositVC(.normal)
        dzy_push(vc)
    }
    
    //    MARK: - 懒加载
    private lazy var detailHeader: DepositHeaderView = {
        let header = DepositHeaderView
            .initFromNib(DepositHeaderView.self)
        header.updateUI("详情")
        return header
    }()
    
    private lazy var flowHeader: DepositHeaderView = {
        let header = DepositHeaderView
            .initFromNib(DepositHeaderView.self)
        header.updateUI("流水")
        return header
    }()
    
    //    MARK: - api
    private func amountApi() {
        guard let userType = userType else {return}
        let request = BaseRequest()
        request.url = BaseURL.amount
        request.dic = [
            "userType" : userType.rawValue,
            "type" : apiType,
            "city" : RegionManager.city()
        ]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.amountApiSuccess(data)
        }
    }
    
    private func refundPriceApi(_ cashId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.refundPrice
        request.dic = [
            "userType" : IDENTITY.rawValue,
            "cashId" : cashId
        ]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ZKProgressHUD.showMessage(error!)
                return
            }
            if data != nil {
                self.amountApi()
            }
        }
    }
    
    func listApi(_ page: Int) {
        guard let amountId = amountId else {return}
        var dic: [String : Any] = ["userAmountId" : amountId]
        if let priceId = priceId {
            dic["cashPriceId"] = priceId
        }else {
            showEmptyView(true)
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.amountDetail
        request.dic = dic
        request.page = [page, 10]
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.showEmptyView(data == nil)
        }
    }
}

extension DepositContentVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return amounts.count
        }else {
            return dataArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch type {
            case .buy_look, .buy_flow:
                let cell = tableView
                    .dzy_dequeueReusableCell(DepositTitleOneLBCell.self)
                cell?.updateUI(amounts[indexPath.row], row: indexPath.row, type: type)
                cell?.delegate = self
                return cell!
            default:
                let cell = tableView
                    .dzy_dequeueReusableCell(DepositTitleTwoLBCell.self)
                cell?.updateUI(amounts[indexPath.row], row: indexPath.row, type: type)
                cell?.delegate = self
                return cell!
            }
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(OrderFlowCell.self)
            cell?.updateUI(dataArr[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedFunc(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch type {
            case .buy_flow:
                return 80.0
            default:
                return 103.0
            }
        }else {
            return 134.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? detailHeader : flowHeader
    }
}

extension DepositContentVC: DepositTitleOneLBCellDelegate, DepositTitleTwoLBCellDelegate {
    func oneLBCell(
        _ oneLBCell: DepositTitleOneLBCell,
        didClickBtn btn: UIButton,
        amount: [String : Any]
    ) {
        guard let type = DepositFunType(rawValue: btn.tag) else {return}
        jumpAction(type, amount: amount)
    }

    func twoLBCell(
        _ twoLBCell: DepositTitleTwoLBCell,
        didClickBtn btn: UIButton,
        amount: [String : Any]
    ) {
        guard let type = DepositFunType(rawValue: btn.tag) else {return}
        jumpAction(type, amount: amount)
    }

    private func jumpAction(_ type: DepositFunType, amount: [String : Any]) {
        let cashId = amount.intValue("id") ?? -1
        switch type {
        case .payBuyFlow,
             .paySellFlow:
            let vc = SettlementVC(amount, type: type)
            dzy_push(vc)
        case .reSellFlow,
             .reBuyFlow:
            let vc = TakeMoneyFirstVC(amount)
            dzy_push(vc)
        case .reBuyDeposit:
            let alert = dzy_normalAlert(
                "提示", msg: "交易保证金可以在最后交易结算时一并计算结清。您确认现在就申请退还吗？",
            sureClick: { [weak self] (_) in
                self?.refundPriceApi(cashId)
            }, cancelClick: nil)
            present(alert, animated: true, completion: nil)
        case .reSellDeposit:
            let alert = dzy_normalAlert(
                "提示", msg: "交易保证金可以在最后交易结算时一并计算结清。您确认现在就申请退还吗？",
            sureClick: { [weak self] (_) in
                self?.refundPriceApi(cashId)
            }, cancelClick: nil)
            present(alert, animated: true, completion: nil)
        case .reLock:
            let alert = dzy_normalAlert(
                "提示", msg: "门锁押金可以在最后交易结算时一并计算结清。您确认现在就申请退还吗？",
            sureClick: { [weak self] (_) in
                self?.refundPriceApi(cashId)
            }, cancelClick: nil)
            present(alert, animated: true, completion: nil)
        case .reLook:
            let alert = dzy_normalAlert(
                "提示", msg: "看房押金可以在最后交易结算时一并计算结清。您确认现在就申请退还吗？ ",
            sureClick: { [weak self] (_) in
                self?.refundPriceApi(cashId)
            }, cancelClick: nil)
            present(alert, animated: true, completion: nil)
        }
    }
}
