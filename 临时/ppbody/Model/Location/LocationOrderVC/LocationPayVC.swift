//
//  LocationPayVC.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationPayVC: BaseVC, ObserverVCProtocol, CustomBackProtocol, AttPriceProtocol {
    
    private let orderId: Int
    
    private let name: String
    
    private let price: Double
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var wxBtn: UIButton!
    
    @IBOutlet weak var alipayBtn: UIButton!
    
    private let pay = PayManager()
    
    init(_ orderId: Int, price: Double, name: String) {
        self.orderId = orderId
        self.price = price
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        registObservers([Config.Notify_PaySuccess]) { [weak self] (_) in
            self?.paySuccess(true)
        }
    }
    
    private func initUI() {
        navigationItem.title = "支付订单"
        dzy_removeChildVCs([
            LPtExpReserveCoachVC.self,
            LocationOrderSubmitVC.self,
        ])
        priceLB.attributedText = attPriceStr(price,
                                             signFont: dzy_Font(18),
                                             priceFont: dzy_Font(40),
                                             fontColor: .white)
        nameLB.text = name
    }
    
    private func paySuccess(_ isShow: Bool) {
        NotificationCenter.default.post(
            name: Config.Notify_RefreshLocationOrder,
            object: nil)
        if isShow {
            ToolClass.showToast("支付成功", .Success)
        }
        dzy_delayPop(1)
    }
    
    //    MARK: - 点击选择
    @IBAction private func wxAction(_ sender: UIButton) {
        sender.isSelected = true
        alipayBtn.isSelected = false
    }
    
    @IBAction private func alipayAction(_ sender: UIButton) {
        sender.isSelected = true
        wxBtn.isSelected = false
    }
    
    //    MARK: - 支付
    @IBAction func sureAction(_ sender: UIButton) {
        let isWx = wxBtn.isSelected
        let dic: [String : String] = [
            "lbsOrderId" : "\(orderId)",
            "payMethod" : isWx ? "10" : "20"
        ]
        payOrderApi(dic, isWx: isWx)
    }
    
    //   MARK: - Api
    private func payOrderApi(_ dic: [String : String], isWx: Bool) {
        let request = BaseRequest()
        request.url = BaseURL.LPayOrder
        request.dic = dic
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let isFree = data?.intValue("isFree"),
                isFree == 1
            {
                self.popView.show()
                return
            }
            if isWx {
                let info = data?.dicValue("payInfoWechat") ?? [:]
                self.pay.start(.wechat(info: info))
            }else {
                let str = data?.stringValue("payInfoAlipay") ?? ""
                self.pay.start(.alipay(order: str))
            }
        }
    }
    
//    MARK: - 懒加载
    private lazy var freeView: LFreeOrderView = {
        let view = LFreeOrderView.initFromNib()
        view.handler = { [weak self] in
            self?.paySuccess(false)
        }
        return view
    }()
    
    private lazy var popView: DzyPopView = {
        let view = DzyPopView(.POP_center_above, viewBlock: freeView)
        view.cancelHandler = { [weak self] in
            self?.paySuccess(false)
        }
        return view
    }()
}
