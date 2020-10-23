//
//  PayBuyDepositVC.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

enum PayDepositType {
    /// 正常状态
    case normal
    /// 可以跳过，并且需要提示
    case jump(String)
    /// 需要提示缴纳门锁押金或者看房押金
    case notice(String)
}

class PayBuyDepositVC: BaseVC, CustomBackProtocol {
    
    private var amountInfo: [String : Any]?
    
    private let type: PayDepositType
    
    @IBOutlet weak var lookDepositView: UIView!
    
    @IBOutlet weak var noticeLB: UILabel!
    // 看房押金
    private var lookPrice: Double = 0.0
    // 交易保证金的单价
    private var depositPrice: Double = 0.0
    
    /// 展示看房押金的单价
    @IBOutlet weak var lookShowPriceLB: UILabel!
    /// 看房押金的单价
    @IBOutlet weak var lookPriceLB: UILabel!
    /// 看房押金的总价
    @IBOutlet weak var lookTotalPriceLB: UILabel!
    /// 选中看房押金的按钮
    @IBOutlet weak var lookSelectedBtn: UIButton!
    
    /// 调整交易保证金的数量
    @IBOutlet weak var depositNumView: PayDepostiNumView!
    /// 展示交易保证金的单价
    @IBOutlet weak var depositShowPriceLB: UILabel!
    /// 交易保证金的单价
    @IBOutlet weak var depositPriceLB: UILabel!
    /// 交易保证金的份数
    @IBOutlet weak var depositPriceNumLB: UILabel!
    /// 交易保证金的总金额
    @IBOutlet weak var depositPriceTotalLB: UILabel!
    
    /// 总金额
    @IBOutlet weak var totalPriceLB: UILabel!
    
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var topLC: NSLayoutConstraint!
    
    @IBOutlet weak var bottomHeightLC: NSLayoutConstraint!
    /// 说明
    @IBOutlet weak var infoLB: UILabel!
    
    @IBOutlet weak var jumpBtn: UIButton!
    
    init(_ type: PayDepositType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "缴纳看房押金和买方交易保证金"
        view.backgroundColor = .white
        view.isHidden = true
        sureBtn.isHidden = true
        depositNumView.changeNumHandler = { [weak self] num in
            self?.updateDepositPriceUI(num)
        }
        checkJumpBtn()
        configApi()
    }
    
    //    MARK: - 初始化金额
    private func initPrice(_ data: [String : Any]?) {
        guard data != nil else {
            showMessage("获取城市配置失败")
            return
        }
        if let data = data?.dicValue("cityConfig"),
            let look = data.doubleValue("lookPrice"),
            let deposit = data.doubleValue("cashPrice")
        {
            lookPrice = look
            depositPrice = deposit
            guard lookPrice > 0 && depositPrice > 0 else {
                showMessage("初始化金额失败")
                return
            }
            setInfoMsg()
            view.isHidden = false
            PublicFunc.checkPayOrTrain(.buyLookHouse) { (_, data) in
                self.checkAllType(data)
                self.initUI()
            }
        }else {
            showMessage("初始化金额失败")
        }
    }
    
    //    MARK: - 设置提示信息
    private func setInfoMsg() {
        let price = PublicConfig
                    .sysConfigDoubleValue(.lookHouse_exceedPrice) ?? 1
        //押金 限定时间 每分钟金额 保证金 保证金
        let str = String(format: PublicConfig.buyerDepositMsg,
                         lookPrice.decimalStr,
                         PublicConfig
                            .sysConfigIntValue(.lookHouse_exceedTime) ?? 30,
                         price.decimalStr,
                         depositPrice.decimalStr,
                         depositPrice.decimalStr)
        let attStr = DzyAttributeString(
            str: str,
            color: dzy_HexColor(0x646464),
            font: dzy_Font(14),
            lineSpace: defaultLineSpace,
            innerSpace: nil)
        
        let value = attStr.create()
        if let range = str.range(of: "买方自助看房规则：") {
            value.setAttributes([
                NSAttributedString.Key.font : dzy_FontBlod(14)
                ], range: dzy_toNSRange(range, str: str))
        }
        if let range = str.range(of: "买方参与竞价规则：") {
            value.setAttributes([
                NSAttributedString.Key.font : dzy_FontBlod(14)
                ], range: dzy_toNSRange(range, str: str))
        }
        infoLB.attributedText = value
    }
    
    //    MARK: - 检查跳过按钮
    private func checkJumpBtn() {
        if case .jump = type {
            bottomHeightLC.constant = 185
            jumpBtn.isHidden = false
            jumpBtn.layer.borderWidth = 1
            jumpBtn.layer.borderColor = MainColor.cgColor
            dzy_removeToChildVCs([HouseDetailVC.self])
        }
    }
    
    @IBAction func protocolAction(_ sender: UIButton) {
        let vc = UserProtocolVC()
        dzy_push(vc)
    }
    
    //    MARK: - 可以跳过的情况下，返回操作
    @IBAction func customBackAction() {
        dzy_pop()
    }
    
    //    MARK: - 根据保证金的缴纳状态更新UI
    private func checkAllType(_ data: [String : Any]?) {
        let lookType = data?.intValue(UserAllType.buyLookHouse.rawValue) ?? 0
        let depositType = data?.intValue(UserAllType.buyDeposit.rawValue) ?? 0
        if lookType == 0 {
            switch type {
            case .notice(let msg),
                 .jump(let msg):
                showLookHouseView(msg)
            default:
                break
            }
        }else {
            lookPrice = 0.0
        }
        if depositType == 1 {
            depositNumView.setNum(0)
            depositPriceNumLB.text = "0"
        }
    }
    
    //    MARK: - 检查是否需要缴纳看房押金
    private func showLookHouseView(_ msg: String) {
        topLC.constant = 50
        noticeLB.text = msg
        UIView.animate(withDuration: 0.5) {
            self.lookDepositView.isHidden = false
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func initUI() {
        lookShowPriceLB.text = "¥\(lookPrice.decimalStr)/人"
        lookPriceLB.text = "¥\(lookPrice.decimalStr)"
        lookTotalPriceLB.text = "¥\(lookPrice.decimalStr)"
        
        depositShowPriceLB.text = "¥\(depositPrice.decimalStr)/交易"
        depositPriceLB.text = "¥\(depositPrice.decimalStr)"
        let num = Double(depositPriceNumLB.text ?? "0") ?? 0
        depositPriceTotalLB.text = "¥\((depositPrice * num).decimalStr)"
        updateTotalPriceUI()
    }
    
    //    MARK: - 选择看房押金
    @IBAction func lookHouseDepositAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateTotalPriceUI()
    }
    
    //    MARK: - 更新价格相关
    private func updateTotalPriceUI() {
        sureBtn.isHidden = false
        totalPriceLB.text = "¥\(totalPrice.decimalStr)"
        if totalPrice == 0 {
            sureBtn.setTitleColor(dzy_HexColor(0xA3A3A3), for: .normal)
            sureBtn.backgroundColor = dzy_HexColor(0xd5d5d5)
            sureBtn.setTitle("请选择或填写支付项目", for: .normal)
            sureBtn.isUserInteractionEnabled = false
        }else {
            sureBtn.isUserInteractionEnabled = true
            sureBtn.setTitleColor(.white, for: .normal)
            sureBtn.backgroundColor = MainColor
            sureBtn.setTitle("同意，去支付¥\(totalPrice.decimalStr)", for: .normal)
        }
    }
    
    private func updateDepositPriceUI(_ num: Int) {
        depositPriceNumLB.text = "\(num)"
        depositPriceTotalLB.text = "¥\((Double(num) * depositPrice).decimalStr)"
        updateTotalPriceUI()
    }
    
    //    MARK: - 获取配置信息 api
    func configApi() {
        PublicConfig.updateCityConfig { [weak self] (data) in
            self?.initPrice(data)
        }
        PublicFunc.updateUserDetail { [weak self] (_, info, _) in
            self?.amountInfo = info
        }
    }
    
    //   MARK: - 支付
    @IBAction func sureAction(_ sender: UIButton) {
        guard let amountInfo = amountInfo else {
            showMessage("数据获取中，请稍后。")
            return
        }
        let buyDeposit  = amountInfo.doubleValue("buyCashDeposit") ?? 0
        let buyLook     = amountInfo.doubleValue("buyLookPrice") ?? 0
        
        guard buyDeposit + buyLook > 0 else {
            payAction()
            return
        }
        let msg = "您已交押金\(buyLook.decimalStr)元、" +
                  "保证金\(buyDeposit.decimalStr)元，您还要交吗？"
        let alert = dzy_normalAlert(
            "提示", msg: msg, sureClick:
        { [weak self] (_) in
            self?.payAction()
        }, cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
    
    private func payAction() {
        guard DataManager.isPwd() == true else {
            let vc = EditMyInfoVC(.notice)
            dzy_push(vc)
            return
        }
        var temp: Int = 0
        var dic: [String : Any] = [
            "type" : 10,
            "userType" : 10
        ]
        if let lookPriceStr = lookTotalPriceLB.text?
            .replacingOccurrences(of: "¥", with: ""),
            let tlookPrice = Double(lookPriceStr),
            tlookPrice > 0,
            lookSelectedBtn.isSelected
        {
            // 如果需要交看房押金，则需要传 price
            dic["price"] = lookPrice
        }else {
            temp += 1
        }
        
        if let depositNumStr = depositPriceNumLB.text,
            let depositNum = Int(depositNumStr),
            depositNum > 0
        {
            dic["cashNum"] = depositNum
            dic["cashPrice"] = Double(depositNum) * depositPrice
        }else {
            temp += 1
        }
        guard temp < 2 else {
            showMessage("未选择任何支付项")
            return
        }
        DataManager.staffMsg().flatMap({
            dic.merge($0, uniquingKeysWith: {$1})
        })
        let vc = PayMoneyVC(dic, type: .buyDeposit)
        dzy_push(vc)
    }
    
    //    MARK: - 总价
    private var totalPrice: Double {
        var lookTotalStr = lookTotalPriceLB.text ?? "0"
        if lookTotalStr.count > 1 {
            lookTotalStr = String(lookTotalStr[
                lookTotalStr.index(after: lookTotalStr.startIndex)...
                ])
        }
        let lookTotal = Double(lookTotalStr) ?? 0
        
        var depositTotalStr = depositPriceTotalLB.text ?? "0"
        if depositTotalStr.count > 1 {
            let index = depositTotalStr
                .index(after: depositTotalStr.startIndex)
            depositTotalStr = String(depositTotalStr[index...])
        }
        let depositTotal = Double(depositTotalStr) ?? 0
        return lookSelectedBtn.isSelected ? (lookTotal + depositTotal) : depositTotal
    }
}
