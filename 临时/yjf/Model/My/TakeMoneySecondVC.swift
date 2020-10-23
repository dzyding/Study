//
//  TakeMoneySecondVC.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum TakeMoneyType {
    case takeMoney(cashId: Int, price: Double)
    case topRefund(houseId: Int)
}

class TakeMoneySecondVC: BaseVC {
    
    private let type: TakeMoneyType
    /// 159 106
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    @IBOutlet weak var msgLB: UILabel!
    
    // 收款人姓名
    @IBOutlet weak var nameTF: UITextField!
    
    // 支付宝相关
    @IBOutlet weak var alipayBtn: UIButton!
    
    @IBOutlet weak var alipayView: UIView!

    @IBOutlet weak var alipayTF: UITextField!
    
    // 微信相关
    @IBOutlet weak var wechatBtn: UIButton!
    
    @IBOutlet weak var wechatView: UIView!
    
    @IBOutlet weak var wechatNumTF: UITextField!
    
    @IBOutlet weak var wechatBankLB: UILabel!
    
    @IBOutlet weak var wechatBankBtn: UIButton!
    
    init(_ type: TakeMoneyType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    @IBAction private func takeMoneyAction(_ sender: UIButton) {
        guard let name = nameTF.text, name.count > 0 else {
            showMessage("请输入收款人姓名")
            return
        }
        var dic: [String : Any] = [
            "userName" : name
        ]
        func checkPayType(_ isTop: Bool) {
            if wechatBtn.isSelected {
                dic["payWay"] = 20
                wechatFunc(&dic, isTop: isTop)
            }else if alipayBtn.isSelected {
                dic["payWay"] = 10
                alipayFunc(&dic, isTop: isTop)
            }else {
                showMessage("请选择支付方式")
            }
        }
        switch type {
        case .takeMoney(let cashId, let price):
            dic["cashId"] = cashId
            dic["price"]  = price
            checkPayType(false)
        case .topRefund(let houseId):
            dic["houseId"] = houseId
            checkPayType(true)
        }
    }
    
    private func alipayFunc(_ dic: inout [String : Any], isTop: Bool) {
        guard let phone = alipayTF.text, phone.count > 0 else {
            showMessage("请输入收款帐号")
            return
        }
        dic["userPhone"] = phone
        if isTop {
            topRefundApi(dic)
        }else {
            takeMoneyAction(dic)
        }
    }
    
    private func wechatFunc(_ dic: inout [String : Any], isTop: Bool) {
        guard let bankNum = wechatNumTF.text, bankNum.count > 0 else {
            showMessage("请输入银行卡卡号")
            return
        }
        dic["userPhone"] = bankNum
        
        guard let bankCode = wechatBankLB.text, bankCode.count > 0 else {
            showMessage("请选择所属银行")
            return
        }
        dic["bankCode"] = bankCode
        if isTop {
            topRefundApi(dic)
        }else {
            takeMoneyAction(dic)
        }
    }
    
    //    MARK: - 微信选择银行
    @IBAction func selectBankAction(_ sender: UIButton) {
        sender.isSelected = true
        sheetView.updateUI(banks.compactMap({$0.stringValue("name")}))
        popView.updateSourceView(sheetView)
        popView.show()
    }
    
    //    MARK: - 选择类型
    @IBAction func selectedAction(_ sender: UIButton) {
        if sender.isSelected == true {return}
        sender.isSelected = true
        if sender.tag == 0 {
            alipayBtn.isSelected = false
            alipayView.isHidden = true
            wechatView.isHidden = false
            heightLC.constant = 159
        }else {
            wechatBtn.isSelected = false
            wechatView.isHidden = true
            alipayView.isHidden = false
            heightLC.constant = 106
        }
    }
    
    private func setUI() {
        navigationItem.title = "提供收款信息"
        view.backgroundColor = dzy_HexColor(0xF5F5F5)
        
        var attStr = DzyAttributeString()
        attStr.str = "1.请认真核对您所填写的信息，以确保其准确无误。\n2.若因您提供的收款账号信息有误导致款项划拨错误或延迟，将由您承担全部责任。\n3.我们将在x个工作日内及时处理您的提现申请，请耐心等待。"
        attStr.color = dzy_HexColor(0xa3a3a3)
        attStr.font  = dzy_Font(14)
        attStr.lineSpace = defaultLineSpace
        msgLB.attributedText = attStr.create()
    }
    
    //    MARK: - 点击空白背景
    private func popBgClick() {
        wechatBankBtn.isSelected = false
    }
    
    //    MARK: - api
    private func takeMoneyAction(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.takePrice
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.dzy_customPopOrRootPop(DepositVC.self)
            }
        }
    }
    
    /// 退钱
    private func topRefundApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.topRefund
        request.dic = dic
        request.start { (data, error) in
            if data != nil {
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_TopRefundSuccess,
                    object: nil,
                    userInfo: nil)
                self.dzy_pop()
            }
        }
    }
    
    //    MARK: - 懒加载
    private lazy var sheetView: ActionSheetView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200.0)
        let sheet = ActionSheetView(frame: frame)
        sheet.delegate = self
        return sheet
    }()
    
    private lazy var popView: DzyPopView = {
        let pop = DzyPopView(.POP_bottom)
        pop.bgDismissHandler = { [weak self] in
            self?.popBgClick()
        }
        return pop
    }()
    
    private lazy var banks: [[String : Any]] = [
        ["name" : "工商银行", "code" : "1002"],
        ["name" : "农业银行", "code" : "1005"],
        ["name" : "中国银行", "code" : "1026"],
        ["name" : "建设银行", "code" : "1003"],
        ["name" : "招商银行", "code" : "1001"],
        ["name" : "邮储银行", "code" : "1066"],
        ["name" : "交通银行", "code" : "1020"],
        ["name" : "浦发银行", "code" : "1004"],
        ["name" : "民生银行", "code" : "1006"],
        ["name" : "兴业银行", "code" : "1009"],
        ["name" : "平安银行", "code" : "1010"],
        ["name" : "中信银行", "code" : "1021"],
        ["name" : "华夏银行", "code" : "1025"],
        ["name" : "广发银行", "code" : "1027"],
        ["name" : "光大银行", "code" : "1022"],
        ["name" : "北京银行", "code" : "4836"],
        ["name" : "宁波银行", "code" : "1056"],
        ["name" : "上海银行", "code" : "1024"]
    ]
}

extension TakeMoneySecondVC: ActionSheetViewDelegate {
    func sheetView(_ sheetView: ActionSheetView, didSelectString str: String) {
        popView.hide()
        wechatBankLB.text = str
    }
    
    func sheetView(_ sheetView: ActionSheetView, didClickCancelBtn btn: UIButton) {
        wechatBankBtn.isSelected = false
        popView.hide()
    }
}
