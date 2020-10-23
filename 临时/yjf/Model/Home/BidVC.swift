//
//  BidVC.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class BidVC: BaseVC {
    
    @IBOutlet weak var totalPriceTF: UITextField!
    
    @IBOutlet weak var moneyTF: UITextField!
    
    @IBOutlet weak var loanTF: UITextField!
    
    private let house: [String : Any]
    /// 编辑
    var data: [String : Any]?
    
    init(_ house: [String : Any]) {
        self.house = house
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
        moneyTF.addTarget(self, action: #selector(editingChange(_:)), for: .editingChanged)
        
        checkIdentity()
        setInfoView()
    }
    
    deinit {
        dzy_log("销毁")
        DataManager.saveBidMsg(nil)
    }
    
    private func checkIdentity() {
        switch IDENTITY {
        case .buyer:
            navigationItem.title = "竞价"
        case .seller:
            navigationItem.title = "卖方报价"
            cancelBtn.isHidden = true
            sellUpdateUI()
        }
    }
    
    @objc private func editingChange(_ tf: UITextField) {
        guard let totalStr = totalPriceTF.text,
            let total = Double(totalStr), total > 0
        else {return}
        
        if var str = tf.text {
            if str.hasSuffix(".") {
                str = str + "0"
            }
            if let cash = Double(str) {
                if cash > total {
                    let index = str.index(before: str.endIndex)
                    moneyTF.text = String(str[..<index])
                }else {
                    loanTF.text = (total - cash).decimalStr
                }
            }
        }
    }
    
    private func setInfoView() {
        view.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(view.dzyLayout.snp.top)
            make.height.equalTo(173.0)
        }
    }
    
    private func sellUpdateUI() {
        if let data = data {
            totalPriceTF.text = "\(data.doubleValue("total"), optStyle: .price)"
            moneyTF.text = "\(data.doubleValue("cash"), optStyle: .price)"
            loanTF.text = "\(data.doubleValue("loan"), optStyle: .price)"
        }
    }
    
    // 提交
    @IBAction func sureAction(_ sender: UIButton) {
        guard let totalStr = totalPriceTF.text,
            let total = Double(totalStr), total > 0
        else {
                showMessage("请输入总价")
                return
        }
        guard let moneyStr = moneyTF.text,
            let money = Double(moneyStr)
        else {
                showMessage("请输入现金金额")
                return
        }
        guard money <= total else {
            showMessage("现金金额必须小于总价")
            return
        }
        guard let houseId = house.intValue("id") else {return}
        switch IDENTITY {
        case .seller:
            var dic: [String : Any] = [
                "houseId" : houseId,
                "total"   : total,
                "cash"    : money
            ]
            if let id = data?.intValue("id") {
                dic.updateValue(id, forKey: "sellId")
            }
            DataManager.saveBidMsg(dic)
        case .buyer:
            var dic: [String : Any] = [
                "houseId" : houseId,
                "cash"    : money,
                "loan"    : total - money
                ]
            if let id = data?.intValue("id") {
                dic.updateValue(id, forKey: "id")
            }
            DataManager.saveBidMsg(dic)
        }
        if DataManager.isPwd() == true {
            let vc = CertificationVC()
            dzy_push(vc)
        }else {
            let vc = EditMyInfoVC(.notice)
            dzy_push(vc)
        }
    }
    
    // 取消
    @IBAction func cancelAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    //    MARK: - 懒加载
    lazy var infoView: HouseInfoView = {
        let view = HouseInfoView.initFromNib(HouseInfoView.self)
        view.updateUI(self.house)
        return view
    }()
}

extension BidVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let totalStr = totalPriceTF.text,
            let total = Double(totalStr), total > 0
        else {return}
        if textField == moneyTF {
            if let str = textField.text,
                let cash = Double(str)
            {
                moneyTF.text = cash.decimalStr
                loanTF.text = (total - cash).decimalStr
            }else {
                loanTF.text = nil
            }
        }else {
            if let str = textField.text,
                let total = Double(str)
            {
                totalPriceTF.text = total.decimalStr
                moneyTF.text = nil
                loanTF.text = nil
            }
        }
    }
}
