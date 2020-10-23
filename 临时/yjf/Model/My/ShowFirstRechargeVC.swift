//
//  ShowFirstRechargeVC.swift
//  YJF
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ShowFirstRechargeVC: BaseVC {
    /// 单价
    var price: Double = 0
    /// 天数
    @IBOutlet weak var numTF: UITextField!
    /// 单价LB
    @IBOutlet weak var oneDayPriceLB: UILabel!
    /// 总价
    @IBOutlet weak var totalPriceLB: UILabel!
    /// 确定按钮
    @IBOutlet weak var sureBtn: UIButton!
    /// 优显说明
    @IBOutlet weak var msgLB: UILabel!
    
    private let houseId: Int
    /// 天数
    private var day: Int {
        return Int(numTF.text ?? "1") ?? 1
    }
    
    init(_ houseId: Int) {
        self.houseId = houseId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        navigationItem.title = "房源优显-充值"
        numTF.addTarget(self, action: #selector(editChange(_:)), for: .editingChanged)
        numTF.addTarget(self, action: #selector(editEnd(_:)), for: .editingDidEnd)
        cityConfigApi()
    }
    
    private func setInfoMsg() {
        //押金 限定时间 每分钟金额 保证金 保证金
        let str = String(format: PublicConfig.topMsg,
                         price.decimalStr,
                         price.decimalStr)
        let attStr = DzyAttributeString(
            str: str,
            color: dzy_HexColor(0x646464),
            font: dzy_Font(14),
            lineSpace: defaultLineSpace,
            innerSpace: nil)
        msgLB.attributedText = attStr.create()
    }
    
    private func updateUI() {
        oneDayPriceLB.text = "\(price.decimalStr)元/天"
        let totalStr = "\((Double(day) * price).decimalStr)"
        totalPriceLB.text = totalStr + "元"
        sureBtn.setTitle("同意，去支付¥" + totalStr, for: .normal)
    }
    
    private func initPrice(_ data: [String : Any]?) {
        guard data != nil else {
            showMessage("获取城市配置失败")
            return
        }
        let value = data?.dicValue("cityConfig")?.doubleValue("topPrice") ?? 0
        price = value
        if price > 0 {
            view.isHidden = false
            updateUI()
            setInfoMsg()
        }else {
            showMessage("获取价格失败")
        }
    }
    
    //    MARK: - 输入监测
    @objc func editChange(_ tf: UITextField) {
        updateUI()
    }
    
    @objc func editEnd(_ tf: UITextField) {
        if (tf.text?.count ?? 0) < 1 || Int(tf.text ?? "0") == 0 {
            tf.text = "1"
            updateUI()
        }
    }
 
    //    MARK: - 加减
    @IBAction func addAction(_ sender: UIButton) {
        if let text = numTF.text,
            let num = Int(text)
        {
            numTF.text = "\(num + 1)"
        }
        updateUI()
    }
    
    @IBAction func reduceAction(_ sender: UIButton) {
        if let text = numTF.text,
            let num = Int(text),
            num > 1
        {
            numTF.text = "\(num - 1)"
        }
        updateUI()
    }
    
    //    MARK: - 支付
    @IBAction func payAction(_ sender: UIButton) {
        let dic: [String : Any] = [
            "price" : Double(day) * price,
            "type" : 70,
            "userType" : 20,
            "houseIdList" : ToolClass.toJSONString(dict: [houseId]),
            "topDayNum" : day
        ]
        let vc = PayMoneyVC(dic, type: .showFirst)
        dzy_push(vc)
    }
    
    //    MARK: - 城市配置
    private func cityConfigApi() {
        PublicConfig.updateCityConfig { [weak self] (data) in
            self?.initPrice(data)
        }
    }
}
