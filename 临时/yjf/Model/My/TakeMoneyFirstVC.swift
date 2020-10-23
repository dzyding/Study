//
//  TakeMoneyFirstVC.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class TakeMoneyFirstVC: BaseVC {
    
    private let amount: [String : Any]
    
    @IBOutlet weak var canLB: UILabel!
    
    private var price: Double {
        return amount.doubleValue("price") ?? 0
    }

    @IBOutlet weak var inputTF: UITextField!
    
    init(_ amount: [String : Any]) {
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        navigationItem.title = "结算"
        canLB.text = price.decimalStr + "元"
        inputTF.text = "¥\(price.decimalStr)"
        inputTF.addTarget(self, action: #selector(editingChange(_:)), for: .editingChanged)
    }
    
    @IBAction func takeAllAction(_ sender: UIButton) {
        inputTF.text = "¥\(price.decimalStr)"
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        guard let cashId = amount.intValue("id"),
            var temp = inputTF.text, temp.count > 1
        else {
            showMessage("请输入金额")
            return
        }
        temp = temp.replacingOccurrences(of: "¥", with: "")
        let money = Double(temp) ?? 0
        guard money <= price else {
            showMessage("超过最大可结算金额")
            return
        }
        guard money > 0 else {
            showMessage("无可结算金额")
            return
        }
        guard money < 1 else {
            showMessage("最小提现金额1元")
            return
        }
        let vc = TakeMoneySecondVC(.takeMoney(cashId: cashId, price: money))
        dzy_push(vc)
    }
    
    @objc private func editingChange(_ tf: UITextField) {
        if tf.text == nil || tf.text?.count == 0 {
            tf.text = "¥"
        }
    }
}
