//
//  TakeMoneyVC.swift
//  PPBody
//
//  Created by edz on 2019/11/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import ZKProgressHUD

class TakeMoneyVC: BaseVC {
    
    private let money: Double

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var bgViewWidthLC: NSLayoutConstraint!
    
    @IBOutlet weak var bgViewLeftLC: NSLayoutConstraint!
    /// 输入金额
    @IBOutlet weak var inputTF: UITextField!
    /// 当前余额1260.00元，
    @IBOutlet weak var moneyLB: UILabel!
    /// 验证码已经发送至您的手机15072049062
    @IBOutlet weak var phoneLB: UILabel!
    
    @IBOutlet weak var stackViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    /// 输入验证码
    @IBOutlet weak var codeTF: UITextField!
    
    var isTake = false
    
    init(_ money: Double) {
        self.money = money
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "提现"
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bgView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bgView.isHidden = true
    }
    
    private func initUI() {
        moneyLB.text = String(format: "当前余额%.2lf元，", money)
        phoneLB.text = "验证码已经发送至您的手机\(DataManager.mobile())"
        bgViewWidthLC.constant = ScreenWidth * 2.0
        let height = (ScreenWidth - 64.0 - 15 * 5.0) / 6.0
        stackViewHeightLC.constant = height
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        stackView.arrangedSubviews.forEach { (view) in
            view.layer.borderWidth = 1
            view.layer.borderColor = color.cgColor
        }
        
        inputTF.addTarget(self,
                          action: #selector(moneyEditingChanged(_:)),
                          for: .editingChanged)
        codeTF.addTarget(self,
                         action: #selector(codeEditingChanged(_:)),
                         for: .editingChanged)
    }
    
    @objc private func moneyEditingChanged(_ tf: UITextField) {
        tf.checkIsOnlyNumber(true)
    }
    
    @objc private func codeEditingChanged(_ tf: UITextField) {
        tf.checkIsOnlyNumber(false)
        guard let text = tf.text else {return}
        let count = text.count
        if count >= 6 {
            let sindex = text.startIndex
            let eindex = text.index(sindex, offsetBy: 6)
            let result = String(text[sindex..<eindex])
            tf.text = result
            tf.resignFirstResponder()
            takeMoneyFinalStep(result)
        }
        (0..<6).forEach { (index) in
            if let label = stackView.arrangedSubviews[index]
                .viewWithTag(99) as? UILabel
            {
                if index < count {
                    let sindex = text.index(text.startIndex,
                                           offsetBy: index)
                    label.text = String(text[sindex])
                }else {
                    label.text = nil
                }
            }
        }
    }
    
    private func takeMoneyFinalStep(_ code: String) {
        if isTake {return}
        guard let money = Double(inputTF.text ?? "0"), money >= 1 else {
            ToolClass.showToast("请输入至少一元的提现金额", .Failure)
            return
        }
        isTake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isTake = false
        }
        takeMoneyApi([
            "price" : money.decimalStr,
            "verCode" : code
        ])
    }

    @IBAction func allAction(_ sender: Any) {
        inputTF.text = String(format: "%.2lf", money)
    }
    
    @IBAction func takeMoneyAction(_ sender: Any) {
        guard let money = Double(inputTF.text ?? "0"), money >= 1 else {
            ToolClass.showToast("请输入至少一元的提现金额", .Failure)
            return
        }
        guard money <= self.money else {
            ToolClass.showToast("提现金额必须小于余额", .Failure)
            return
        }
        bgViewLeftLC.constant = -ScreenWidth
        UIView.animate(withDuration: 0.25, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { (_) in
            self.codeTF.becomeFirstResponder()
        }
        loadSendCodeApi()
    }
    
    @IBAction func becomeFirstResponderAction(_ sender: Any) {
        codeTF.becomeFirstResponder()
    }
    
//    MARK: - api
    private func loadSendCodeApi() {
        let request = BaseRequest()
        request.url = BaseURL.CommonSendCode
        request.dic = [
            "mobile" : DataManager.mobile(),
            "type" : "90",
            "valid" : "300"
        ]
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
        }
    }
    
    private func takeMoneyApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.TakeMoney
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                ToolClass.showToast("提现成功", .Success)
                self.dzy_delayCustomPopOrPop(1,
                                             cls: WalletVC.self,
                                             animated: true)
            }
        }
    }
}
