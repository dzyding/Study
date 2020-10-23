//
//  LocationOrderSubmitVC.swift
//  PPBody
//
//  Created by edz on 2019/10/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderSubmitVC: UIViewController, ActivityTimeProtocol {
    /// 来自分享
    var fpp: String?

    @IBOutlet weak var stackView: UIStackView!
    // bottom 18 0
    @IBOutlet weak var sureBtn: UIButton!
    // 免单
    @IBOutlet weak var freeLB: UILabel!
    
    private let gbDetail: [String : Any]
    /// 购买数量
    private var num: Int = 1
    /// 单价
    private var sprice: Double {
        if isActivity,
            let aprice = gbDetail.doubleValue("activityPrice"),
            aprice > 0
        {
            return aprice
        }else {
            return gbDetail.doubleValue("presentPrice") ?? 0
        }
    }
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    init(_ gbDetail: [String : Any]) {
        self.gbDetail = gbDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "提交订单"
        let str = String(format: "去支付%@元", sprice.decimalStr)
        sureBtn.setTitle(str, for: .normal)
        stackView.addArrangedSubview(thingView)
        stackView.addArrangedSubview(infoView)
        
        // 双十二的团购商品有几率免单
        if isActivity,
            let aprice = gbDetail.doubleValue("activityPrice"),
            aprice > 0
        {
            sureBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
            freeLB.isHidden = false
        }
    }

//    MARK: - 提交
    @IBAction func sureAction(_ sender: UIButton) {
        guard let goodId = gbDetail.intValue("id"),
            let name = gbDetail.stringValue("name")
        else {
            return
        }
        let price = sprice * Double(num)
        let dic: [String : String] = [
            "type" : "10", // 这里暂时只有团购
            "lbsGoodId" : "\(goodId)",
            "num" : "\(num)",
            "price" : "\(price)"
        ]
        submitApi(dic) { [weak self] orderId in
            let vc = LocationPayVC(orderId, price: price, name: name)
            self?.dzy_push(vc)
        }
    }
    
//    MARK: - Api
    private func submitApi(_ dic: [String : String],
                           complete: @escaping (Int)->()) {
        let request = BaseRequest()
        request.url = BaseURL.LSubmitOrder
        request.dic = dic
        request.isUser = true
        request.setFpp(fpp)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            data?.intValue("lbsOrderId").flatMap({
                complete($0)
            })
        }
    }
    
    //    MARK: - 懒加载
    private lazy var thingView: LOrderSubmitThingView = {
        let view = LOrderSubmitThingView.initFromNib()
        view.updateUI(gbDetail)
        view.delegate = self
        return view
    }()
    
    private lazy var infoView: LOrderSubmitInfoView = {
        let view = LOrderSubmitInfoView.initFromNib()
        view.updateUI(sprice)
        return view
    }()
}

extension LocationOrderSubmitVC: LOrderSubmitThingViewDelegate {
    func thingView(_ thingView: LOrderSubmitThingView,
                   didChangeNum num: Int)
    {
        self.num = num
        let price = sprice * Double(num)
        infoView.updateUI(price)
        let str = String(format: "去支付%@元", price.decimalStr)
        sureBtn.setTitle(str, for: .normal)
    }
}
