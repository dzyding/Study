//
//  AddCardVC.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class AddCardVC: BaseVC {
    /// 银行类型和名字
    @IBOutlet weak var bankBtn: UIButton!
    /// 持卡人
    @IBOutlet weak var nameTF: UITextField!
    /// 银行卡
    @IBOutlet weak var codeTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "添加银行卡"
        
        let color = RGB(r: 142.0, g: 142.0, b: 142.0)
        nameTF.setPlaceholderColor(color)
        codeTF.setPlaceholderColor(color)
        codeTF.delegate = self
    }

    //    MARK: - new or edit Api
    func cardEditApi(_ bankName: String, _ bankNo: String, _ name: String) {
        let request = BaseRequest()
        request.url = BaseURL.CardEdit
        request.dic = [
            "bankName" : bankName,
            "bankNo" : bankNo,
            "realname" : name
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self?.dzy_pop()
        }
    }

    @IBAction func selectBankAction(_ sender: Any) {
        let vc = BankListVC()
        vc.addCardVC = self
        dzy_push(vc)
    }
    
    func updateBank(_ model: BankModel) {
        bankBtn.setTitle(model.name, for: .normal)
        bankBtn.setImage(UIImage(named: model.logo), for: .normal)
    }
    
    @IBAction func sureAction(_ sender: Any) {
        guard let bankName = bankBtn.title(for: .normal), !bankName.isEmpty else {
            ToolClass.showToast("清选择银行卡类型", .Failure)
            return
        }
        guard let name = nameTF.text, !name.isEmpty else {
            ToolClass.showToast("清输入姓名", .Failure)
            return
        }
        guard let spaceBankNo = codeTF.text, !spaceBankNo.isEmpty else {
            ToolClass.showToast("清输入卡号", .Failure)
            return
        }
        let bankNo = spaceBankNo.replacingOccurrences(of: " ", with: "")
        cardEditApi(bankName, bankNo, name)
    }
}

extension AddCardVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {return true}
        let noSpace = text.replacingOccurrences(of: " ", with: "")
        if text.count == range.location {
            // 输入字符
            if noSpace.count % 4 == 0 && text.count != 0 {
               textField.text = text + " "
            }
        }else {
            // 删除字符 (count = location + 1)
            if text.hasSuffix(" ") {
                text.removeLast()
                textField.text = text
            }
        }
        return true
    }
}
