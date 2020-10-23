//
//  TakeSweatVC.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

enum TakeSweatType {
    case normal //提现
    case cancelRepresent(Double)    //取消推广大使
}

class TakeSweatVC: BaseVC {

    @IBOutlet weak var bankBtn: UIButton!
    // 输入框
    @IBOutlet weak var numTF: UITextField!
    // 可提现
    @IBOutlet weak var maxLB: UILabel!
    // 当前汗水余额
    @IBOutlet weak var sweatLB: UILabel!
    // 提现时的界面
    @IBOutlet weak var normalView: UIView!
    // 取消推广大使时的界面
    @IBOutlet weak var representView: UIView!
    
    @IBOutlet weak var representMoneyLB: UILabel!
    // 确认弹出框
    var popView: DzyPopView?
    // 当前 vc 类型
    var type: TakeSweatType
    
    var data: [String : Any]?
    
    init(_ type: TakeSweatType = .normal) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicStep()
        cardDefualtApi()
    }
    
    func basicStep() {
        navigationItem.title = "提现"
        switch type {
        case .normal:
            representView.isHidden = true
            numTF.delegate = self
            
            let color = RGB(r: 142.0, g: 142.0, b: 142.0)
            numTF.setPlaceholderColor(color)
            let sweat = DataManager.getSweat()
            sweatLB.text = "当前汗水余额\(sweat)，"
            setMaxLB(0)
        case .cancelRepresent(let money):
            representView.isHidden = false
            normalView.isHidden = true
            representMoneyLB.text = "\(money)元"
        }
    }
    
    //   MARK: - 根据当前的数值设置可提现金额
    func setMaxLB(_ sweat: Int) {
        let color = RGB(r: 142.0, g: 142.0, b: 142.0)
        let str = "可提现\(Double(sweat) / 2.0)元"
        let attStr = NSMutableAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : ToolClass.CustomFont(15),
            NSAttributedString.Key.foregroundColor : color,
            ])
        let range = NSRange(location: 3, length: str.count - 4)
        attStr.addAttributes([
            NSAttributedString.Key.font : ToolClass.CustomFont(17),
            NSAttributedString.Key.foregroundColor : YellowMainColor
            ], range: range)
        maxLB.attributedText = attStr
    }
    
    @IBAction func selectCardAction(_ sender: Any) {
        let vc = CardListVC()
        vc.current = data
        vc.takeMoneyVC = self
        dzy_push(vc)
    }
    
    func update() {
        if let bankName = data?.stringValue("bankName"),
            let bankNo = data?.stringValue("bankNo"), bankNo.count > 4,
            let icon = BankListVC.data.filter({$0.name == bankName}).first?.logo
        {
            let index = bankNo.index(bankNo.endIndex, offsetBy: -4)
            let title = bankName + "（\(bankNo[index...])）"
            bankBtn.setTitle(title, for: .normal)
            bankBtn.setImage(UIImage(named: icon), for: .normal)
        }else {
            // 无数据的时候
            bankBtn.setTitle(nil, for: .normal)
            bankBtn.setImage(nil, for: .normal)
        }
    }
    
    //    MARK: - 获取默认银行卡api
    func cardDefualtApi() {
        let request = BaseRequest()
        request.url = BaseURL.CardDefault
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self?.data = data
            self?.update()
        }
    }
    
    //    MARK: - 提现api
    func withdrawalApi(_ sweat: Int, _ ubId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.Withdrawal
        request.dic = [
            "ubId" : "\(ubId)",
            "sweat" : "\(sweat)"
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("操作成功", .Success)
            self?.popView?.hide()
            let pre = DataManager.getSweat()
            let final = pre - sweat
            DataManager.changeSweat(final)
            self?.sweatLB.text = "当前汗水余额\(final)，"
            self?.numTF.text = ""
            self?.setMaxLB(0)
        }
    }
    
    //    MARK: - 取消推广大使 api
    func cancelRepresentApi(_ ubid: Int) {
        let requset = BaseRequest()
        requset.url = BaseURL.cancelRepresent
        requset.dic = [
            "ubId" : "\(ubid)"
        ]
        requset.isUser = true
        requset.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("操作成功", .Success)
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //    MARK: - 提现
    @IBAction func sureAction(_ sender: Any) {
        view.endEditing(true)
        guard let sweatStr = numTF.text, !sweatStr.isEmpty, let sweat = Int(sweatStr)  else {
            ToolClass.showToast("请输入需提现的汗水值", .Failure)
            return
        }
        if sweat < 100 {
            ToolClass.showToast("单笔最少提现 100 滴汗水", .Failure)
            return
        }
        guard let id = data?.intValue("id") else {
            ToolClass.showToast("请选择到账银行卡", .Failure)
            return
        }
        if let popView = popView {
            popView.show()
        }else {
            let v = TakeSweatSuccessView
                .initFromNib(TakeSweatSuccessView.self)
            v.handler = { [weak self] in
                self?.withdrawalApi(sweat, id)
            }
            popView = DzyPopView(.POP_center, viewBlock: v)
            popView?.show()
        }
    }
    
    //    MARK: - 取消推广大使的提现界面
    @IBAction func cancelAction(_ sender: Any) {
        guard let id = data?.intValue("id") else {
            ToolClass.showToast("请选择到账银行卡", .Failure)
            return
        }
        cancelRepresentApi(id)
    }
    
    
    //    MARK: - 全部提现
    @IBAction func takeAllAction(_ sender: Any) {
        let sweat = DataManager.getSweat()
        numTF.text = "\(sweat)"
        setMaxLB(sweat)
    }
}

extension TakeSweatVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {return false}
        // 只让输入数字
        let regex = "^[0-9]*$"
        let pred = NSPredicate.init(format: "SELF MATCHES %@", regex)
        if !pred.evaluate(with: string) {return false}
        
        if text.count == range.location {
            // 输入字符
            let final = text + string
            if let sweat = Int(final) {
                // 如果输入值大于余额，则不变
                if sweat > DataManager.getSweat() {return false}
                setMaxLB(sweat)
            }
        }else {
            // 删除字符 (count = location + 1)
            text.removeLast()
            if let sweat = Int(text) {
                setMaxLB(sweat)
            }else {
                setMaxLB(0)
            }
        }
        return true
    }
}
