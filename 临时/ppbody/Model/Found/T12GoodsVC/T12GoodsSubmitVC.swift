//
//  T12GoodsSubmitVC.swift
//  PPBody
//
//  Created by edz on 2019/11/13.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import ZKProgressHUD

class T12GoodsSubmitVC: BaseVC, AttPriceProtocol, ObserverVCProtocol {
    
    var fpp: String?
    
    var observers: [[Any?]] = []
    // 地址相关UI --
    @IBOutlet weak var adrNameLB: UILabel!
    
    @IBOutlet weak var adrPhoneLB: UILabel!
    
    @IBOutlet weak var adrAddressLB: UILabel!
    
    @IBOutlet weak var addressView: UIView!
    
    // 商品相关UI --
    @IBOutlet weak var goodsIV: UIImageView!
    
    @IBOutlet weak var goodsNameLB: UILabel!
    /// 当前价格
    @IBOutlet weak var goodsPriceLB: UILabel!
    /// 原价
    @IBOutlet weak var goodsOPriceLB: UILabel!
    
    // 数量相关UI --
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var numBgView: UIView!
    
    // 支付相关UI --
    @IBOutlet weak var wxBtn: UIButton!
    
    @IBOutlet weak var alipayBtn: UIButton!
    
    // 总价相关UI --
    @IBOutlet weak var tpriceLB: UILabel!
    
    @IBOutlet weak var topriceLB: UILabel!
    /// 备注
    @IBOutlet weak var remarkTF: UITextField!
    
    /// 商品数据
    private let goods: [String : Any]
    /// 当前地址
    var address: [String : Any] = [:]
    /// 当前价格
    private var price: Double {
        return goods.doubleValue("presentPrice") ?? 0
    }
    /// 原始价格
    private var oprice: Double {
        return goods.doubleValue("originPrice") ?? 0
    }
    /// 当前数量
    private var num: Int {
        return Int(numLB.text ?? "1") ?? 1
    }
    
    private let pay = PayManager()
    
    deinit {
        deinitObservers()
    }
    
    init(_ goods: [String : Any]) {
        self.goods = goods
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商品购买"
        numBgView.layer.borderWidth = 0.5
        numBgView.layer.borderColor = UIColor.white.cgColor
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        remarkTF.attributedPlaceholder = NSAttributedString(
            string: "请输入",
            attributes: [
                NSAttributedString.Key.font : dzy_Font(14),
                NSAttributedString.Key.foregroundColor : color
        ])
        initUI()
        defAddressApi()
        
        registObservers([Config.Notify_PaySuccess]) { [weak self] (_) in
            self?.paySuccess()
        }
    }
    
    private func initUI() {
        goodsIV.setCoverImageUrl(goods.stringValue("cover") ?? "")
        goodsNameLB.text = goods.stringValue("title")
        goodsPriceLB.attributedText = attPriceStr(price)
        goodsOPriceLB.text = "¥\(oprice.decimalStr)"
        updateTotalPriceAction()
    }
    
    private func updateTotalPriceAction() {
        tpriceLB.attributedText = attPriceStr(price * Double(num))
        topriceLB.text = "¥\(oprice * Double(num))"
    }
    
    private func paySuccess() {
        ToolClass.showToast("支付成功", .Success)
        dzy_delayPop(1)
    }
    
//    MARK: - 更新地址
    func updateAddress(_ address: [String : Any]) {
        self.address = address
        if address.count > 0 {
            addressView.isHidden = false
            adrNameLB.text = address.stringValue("name")
            adrPhoneLB.text = address.stringValue("mobile")
            var area = address.stringValue("area") ?? ""
            area = area.replacingOccurrences(of: " ", with: "")
            let adr = address.stringValue("address") ?? ""
            adrAddressLB.text = area + adr
        }else {
            addressView.isHidden = true
        }
    }

//    MARK: - 加、减
    @IBAction func addAction(_ sender: UIButton) {
        numLB.text = "\(num + 1)"
        updateTotalPriceAction()
    }
    
    @IBAction func reduceAction(_ sender: UIButton) {
        guard num > 1 else {return}
        numLB.text = "\(num - 1)"
        updateTotalPriceAction()
    }
    
//    MAKR: - 选择地址
    @IBAction func addressAction(_ sender: UIButton) {
        let vc = AddressListVC()
        vc.submitVC = self
        dzy_push(vc)
    }
    
//    MARK: - 选择支付方式
    @IBAction func wxAction(_ sender: UIButton) {
        sender.isSelected = true
        alipayBtn.isSelected = false
    }
    
    @IBAction func alipayAction(_ sender: UIButton) {
        alipayBtn.isSelected = true
        wxBtn.isSelected = false
    }
    
//    MARK: - 提交订单
    @IBAction func buyAction(_ sender: DzySafeBtn) {
        guard let addressId = address.intValue("id") else {
            ToolClass.showToast("请选择收获地址", .Failure)
            return
        }
        guard let goodsId = goods.intValue("id") else {
            ToolClass.showToast("错误的商品数据", .Failure)
            return
        }
        var dic: [String : String] = [
            "addressId" : "\(addressId)",
            "goodsId" : "\(goodsId)",
            "num" : "\(num)"
        ]
        if let remark = remarkTF.text,
            remark.count > 0
        {
            dic["remark"] = remark
        }
        orderGoodsApi(dic)
    }
    
//    MARK: - api
    private func defAddressApi() {
        let request = BaseRequest()
        request.url = BaseURL.DefAddress
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("address") {
                self.updateAddress(data)
            }
        }
    }
    
    private func orderGoodsApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.OrderGoods
        request.dic = dic
        request.isUser = true
        request.setFpp(fpp)
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let orderId = data?.intValue("goodsOrderId") {
                self.payOrderApi(orderId)
            }else {
                ToolClass.showToast("生成订单失败", .Failure)
            }
        }
    }
    
    private func payOrderApi(_ orderId: Int) {
        let isWx = wxBtn.isSelected
        let request = BaseRequest()
        request.url = BaseURL.PayOrder
        request.dic = [
            "goodsOrderId" : "\(orderId)",
            "payMethod" : "\(isWx ? 10 : 20)"
        ]
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
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
}
