//
//  PayMoneyVC.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum PayItem {
    /// 买方交易保证金
    case buyDeposit
    /// 卖方交易保证金
    case sellDeposit
    /// 优显
    case showFirst
    /// 补缴结算
    case payFlow
}

class PayMoneyVC: BaseVC, CustomBackProtocol {
    
    @IBOutlet weak var wxBtn: UIButton!
    
    @IBOutlet weak var aliBtn: UIButton!
    
    private let dic: [String : Any]
    
    private let type: PayItem
    
    private var observer: Any?
    
    init(_ dic: [String : Any], type: PayItem) {
        self.dic = dic
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "付款方式"
        dzy_removeChildVCs([PayBuyDepositVC.self, PaySellDepositVC.self])
        
        observer = NotificationCenter.default.addObserver(
            forName: PublicConfig.Notice_PaySuccess,
            object: nil,
            queue: nil,
            using:
        { [weak self] (_) in
            self?.cBackAction()
        })
    }
    
    private func cBackAction() {
        DataManager.saveStaffMsg(nil)
        showMessage("支付成功")
        // 这个地方太快返回偶尔会报错，比如支付结果处理延迟的时候
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let sSelf = self else {return}
            switch sSelf.type {
            case .buyDeposit:
                [
                    PublicConfig.Notice_UpdateDepositFlow,
                    PublicConfig.Notice_PayBuyDepositSuccess
                ].forEach { (name) in
                    NotificationCenter.default.post(name:name , object: nil)
                }
                sSelf.dzy_pop()
            case .sellDeposit:
                [
                    PublicConfig.Notice_UpdateDepositFlow,
                    PublicConfig.Notice_PaySellDepositSuccess
                ].forEach { (name) in
                    NotificationCenter.default.post(name:name , object: nil)
                }
                sSelf.dzy_pop()
            case .payFlow:
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_UpdateDepositFlow, object: nil
                )
                sSelf.dzy_customPopOrPop(DepositVC.self)
            case .showFirst:
                sSelf.dzy_pop()
            }
        }
    }
    
    @IBAction func wxPayAction(_ sender: UIButton) {
        sender.isSelected = true
        aliBtn.isSelected = false
    }
    
    @IBAction func alipayAction(_ sender: UIButton) {
        sender.isSelected = true
        wxBtn.isSelected = false
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        let type: PayMode = wxBtn.isSelected ? .wechat : .alipay
        let manager = PayManager()
        manager.set(type, dic: dic)
        manager.start()
    }
    
}
