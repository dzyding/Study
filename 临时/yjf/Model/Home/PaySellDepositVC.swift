//
//  PaySellDepositVC.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class PaySellDepositVC: BaseVC, CustomBackProtocol {
    
    private var amountInfo: [String : Any]?
    
    private let ctype: PayDepositType
    /// type 为 notice 时的自动选中
    var houseId: Int?
    /// scrollView 到顶部的距离
    @IBOutlet weak var scrollTopLC: NSLayoutConstraint!
    
    @IBOutlet weak var noticeLB: UILabel!
    /// 提示的视图
    @IBOutlet weak var noticeView: UIView!
    /// 门锁押金展示
    @IBOutlet weak var lockShowPriceLB: UILabel!
    /// 门锁押金单价
    @IBOutlet weak var lockPriceLB: UILabel!
    /// 选择房源的数量
    @IBOutlet private weak var lockNumLB: UILabel!
    /// 门锁押金总额
    @IBOutlet private weak var lockTotalLB: UILabel!
    
    /// 保证金展示
    @IBOutlet weak var depositShowPriceLB: UILabel!
    /// 保证金单价
    @IBOutlet weak var depositPriceLB: UILabel!
    /// 保证金数量的视图
    @IBOutlet private weak var depostiNumView: PayDepostiNumView!
    /// 保证金数量
    @IBOutlet weak var depositNumLB: UILabel!
    /// 保证金金额
    @IBOutlet private weak var depositTotalLB: UILabel!
    
    /// 总金额
    @IBOutlet weak var totalMoneyLB: UILabel!
    
    @IBOutlet weak var sureBtn: UIButton!
    /// 门锁押金
    private var lockPrice: Double = 0
    /// 门锁的租金
    private var lockRentPirce: Double = 1
    /// 门锁的拆装费用
    private var lockUnLoadPrice: Double = 200
    /// 保证金
    private var depositPrice: Double = 0
    
    @IBOutlet weak var stackView: UIStackView!

    // 顶部选择支付种类的
    @IBOutlet private weak var topHeightLC: NSLayoutConstraint!
    // 底部的确认按钮 135 185
    @IBOutlet private weak var bottomHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var infoLB: UILabel!
    
    private var houses: [[String : Any]] = []
    
    @IBOutlet weak var jumpBtn: UIButton!
    
    init(_ type: PayDepositType) {
        self.ctype = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "缴纳门锁押金和卖方交易保证金"
        view.backgroundColor = .white
        view.isHidden = true
        sureBtn.isHidden = true
        depostiNumView.changeNumHandler = { [unowned self] num in
            self.updateDepositMoney(num)
        }
        checkJumpBtn()
        configApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNoticeType()
    }
    
    //    MARK: - 初始化金额
    private func initPrice(_ data: [String : Any]?) {
        guard data != nil else {
            showMessage("获取城市配置失败")
            return
        }
        if let data = data?.dicValue("cityConfig"),
            let lock = data.doubleValue("lockPrice"),
            let deposit = data.doubleValue("cashPrice")
        {
            lockPrice = lock
            depositPrice = deposit
            let rentStr = data.stringValue("lockRentPrice") ?? "1"
            let unloadStr = data.stringValue("lockNnloadPrice") ?? "200"
            lockRentPirce = Double(rentStr) ?? 1
            lockUnLoadPrice = Double(unloadStr) ?? 200
            
            guard lockPrice > 0 && depositPrice > 0 else {
                showMessage("初始化金额失败")
                return
            }
            setInfoMsg()
            view.isHidden = false
            initUI()
            houseListApi()
        }else {
            showMessage("初始化金额失败")
        }
    }
    
    private func setInfoMsg() {
        /// 门锁押金 每天的租金1 拆装费200 保证金 保证金
        let str = String(format: PublicConfig.sellerDepositMsg,
                         lockPrice.decimalStr,
                         lockRentPirce.decimalStr,
                         lockUnLoadPrice.decimalStr,
                         depositPrice.decimalStr,
                         depositPrice.decimalStr)
        let attStr = DzyAttributeString(
            str: str,
            color: dzy_HexColor(0x646464),
            font: dzy_Font(14),
            lineSpace: defaultLineSpace,
            innerSpace: nil)
        
        let value = attStr.create()
        if let range = str.range(of: "智能门锁安装规则：") {
            value.setAttributes([
                NSAttributedString.Key.font : dzy_FontBlod(14)
                ], range: dzy_toNSRange(range, str: str))
        }
        if let range = str.range(of: "卖方参与竞价规则：") {
            value.setAttributes([
                NSAttributedString.Key.font : dzy_FontBlod(14)
                ], range: dzy_toNSRange(range, str: str))
        }
        infoLB.attributedText = value
    }
    
    private func initUI() {
        lockShowPriceLB.text = "¥\(lockPrice.decimalStr)/房源"
        lockPriceLB.text = "¥\(lockPrice.decimalStr)"
        depositShowPriceLB.text = "¥\(depositPrice.decimalStr)/交易"
        depositPriceLB.text = "¥\(depositPrice.decimalStr)"
        depositTotalLB.text = "¥\(depositPrice.decimalStr)"
        updateHouseMoney()
        updateResultMoney()
    }
    
    @IBAction func protocolAction(_ sender: UIButton) {
        let vc = UserProtocolVC()
        dzy_push(vc)
    }
    
    //    MARK: - 根据房源数量初始化界面
    private func updateUI(_ list: [[String : Any]]) {
        houses = list
        (0..<houses.count).forEach { (index) in
            let selected = houses[index].intValue("houseId") == houseId
            houses[index].updateValue(selected, forKey: Public_isSelected)
        }
        topHeightLC.constant = 275 + CGFloat(houses.count - 1) * 35
        for index in 0..<houses.count {
            let houseView = SellDepositHouseView
                .initFromNib(SellDepositHouseView.self)
            houseView.updateUI(houses[index], tag: index)
            houseView.delegate = self
            stackView.addArrangedSubview(houseView)
        }
        if houseId != nil {
            updateHouseMoney()
            updateResultMoney()
        }
    }
    
    //    MARK: - 检查返回按钮的类型
    private func checkJumpBtn() {
        if case .jump = ctype {
            bottomHeightLC.constant = 185
            jumpBtn.isHidden = false
            jumpBtn.layer.borderWidth = 1
            jumpBtn.layer.borderColor = MainColor.cgColor
            
            let pvcs = [
                HouseDetailVC.self,
                MyHouseVC.self,
                BaseTabbarVC.self
            ]
            dzy_removeToChildVCs(pvcs)
        }
    }
    
    private func checkNoticeType() {
        switch ctype {
        case .notice(let msg),
             .jump(let msg):
            scrollTopLC.constant = 50
            noticeLB.text = msg
            UIView.animate(withDuration: 0.5) {
                self.noticeView.isHidden = false
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    //    MARK: - 可以跳过的情况下，返回操作
    @IBAction func customBackAction() {
        dzy_pop()
    }
    
    //    MARK: - 更新交易保证金信息
    private func updateDepositMoney(_ num: Int) {
        depositNumLB.text = "\(num)"
        depositTotalLB.text = "¥" + (Double(num) * depositPrice).decimalStr
        updateResultMoney()
    }
    
    //    MARK: - 更新门锁押金总金额
    private func updateHouseMoney() {
        let num = houses.filter({$0.boolValue(Public_isSelected) == true}).count
        lockNumLB.text = "\(num)"
        lockTotalLB.text = "¥" + (Double(num) * lockPrice).decimalStr
    }
    
    //    MARK: - 更新总金额
    private func updateResultMoney() {
        func getNum(_ str: String) -> Double {
            let subStr = String(str[str.index(after: str.startIndex)...])
            return Double(subStr) ?? 0
        }
        let houseMoney = getNum(lockTotalLB.text ?? "¥0")
        let depostiMoney = getNum(depositTotalLB.text ?? "¥0")
        let price = (houseMoney + depostiMoney).decimalStr
        totalMoneyLB.text = "¥\(price)"
        sureBtn.isHidden = false
        if price == "0" {
            sureBtn.setTitleColor(dzy_HexColor(0xA3A3A3), for: .normal)
            sureBtn.backgroundColor = dzy_HexColor(0xd5d5d5)
            sureBtn.setTitle("请选择或填写支付项目", for: .normal)
            sureBtn.isUserInteractionEnabled = false
        }else {
            sureBtn.isUserInteractionEnabled = true
            sureBtn.setTitleColor(.white, for: .normal)
            sureBtn.backgroundColor = MainColor
            sureBtn.setTitle("同意，去支付¥\(price)", for: .normal)
        }
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
    
    //    MARK: - 去支付
    @IBAction func payAction(_ sender: UIButton) {
        guard let amountInfo = amountInfo else {
            showMessage("数据获取中，请稍后。")
            return
        }
        let sellDeposit = amountInfo.doubleValue("sellCashDeposit") ?? 0
        let sellLock    = amountInfo.doubleValue("sellLookPrice") ?? 0
        
        guard sellDeposit + sellLock > 0 else {
            basePayFunc()
            return
        }
        let msg = "您已交押金\(sellLock.decimalStr)元、" +
                  "保证金\(sellDeposit.decimalStr)元，您还要交吗？"
        let alert = dzy_normalAlert(
            "提示", msg: msg, sureClick:
            { [weak self] (_) in
                self?.basePayFunc()
            }, cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
    
    private func basePayFunc() {
        guard DataManager.isPwd() == true else {
            let vc = EditMyInfoVC(.notice)
            dzy_push(vc)
            return
        }
        var temp: Int = 0
        var dic: [String : Any] = [
            "type" : 30,
            "userType" : 20
        ]
        let list = houses
            .filter({$0.boolValue(Public_isSelected) == true})
            .compactMap({$0.intValue("houseId")})
        let lockNum = list.count
        if lockNum > 0,
            lockPrice > 0
        {
            // 如果需要交门锁押金，则需要传 price
            dic["price"] = Double(lockNum) * lockPrice
            dic["houseIdList"] = ToolClass.toJSONString(dict: list)
        }else {
            temp += 1
        }
        
        if let depositNumStr = depositNumLB.text,
            let depositNum = Int(depositNumStr),
            depositNum > 0,
            depositPrice > 0
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
        let vc = PayMoneyVC(dic, type: .sellDeposit)
        dzy_push(vc)
    }
    
    //    MARK: - api
    private func houseListApi() {
        let request = BaseRequest()
        request.url = BaseURL.notLockList
        request.isUser = true
        request.dzy_start { (data, _) in
            self.updateUI(data?.arrValue("list") ?? [])
        }
    }
}

//MARK: - 选择门锁押金对应的房源
extension PaySellDepositVC: SellDepositHouseViewDelegate {
    func houseView(_ houseView: SellDepositHouseView, didSelect btn: UIButton) {
        houses[houseView.tag].updateValue(
            btn.isSelected, forKey: Public_isSelected
        )
        updateHouseMoney()
        updateResultMoney()
    }
}
