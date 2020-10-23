//
//  LocationOrderDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/11/1.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderDetailVC: BaseVC, AttPriceProtocol {
    
    private let orderId: Int
    
    private var phone: String = ""
    
    private var data: [String : Any] = [:]
    
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var imgIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    /// 60 10
    @IBOutlet weak var nameRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var clubNameLB: UILabel!
    
    @IBOutlet weak var clubAddressLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    init(_ orderId: Int) {
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单详情"
        stackView.isHidden = true
        detailApi()
    }
    
    @IBAction func goodsAction(_ sender: Any) {
        guard let type = data.intValue("type"),
            let goodsId = data.intValue("lbsGoodId")
        else {return}
        if type == 10 {
            let vc = LocationGBDetailVC(goodsId)
            dzy_push(vc)
        }else if type == 20 {
            let vc = LocationPtExpDetailVC(goodsId)
            dzy_push(vc)
        }
    }
    
    @IBAction func locationAction(_ sender: Any) {
        let club = data.dicValue("club")
        if let latitude = club?.doubleValue("latitude"),
            let longitude = club?.doubleValue("longitude"),
            let name = club?.stringValue("name")
        {
            let vc = MapVC(name, latitude, lon: longitude)
            dzy_push(vc)
        }
    }
    
    @IBAction func phoneAction(_ sender: Any) {
        let arr = phone.components(separatedBy: [",", "，", " "])
        guard arr.count > 0 else {
            ToolClass.showToast("无可用手机号", .Failure)
            return
        }
        let textColor = dzy_HexColor(0x333333)
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .light
        }
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        cancelAction.setTextColor(textColor)
        alert.addAction(cancelAction)
        arr.forEach { (code) in
            guard let url = URL(string: "tel:" + code)
                else {return}
            let codeAction = UIAlertAction(
                title: code,
                style:
                .default)
            { (_) in
                UIApplication.shared.open(url)
            }
            codeAction.setTextColor(textColor)
            alert.addAction(codeAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func updateUI(_ data: [String : Any]) {
        self.data = data
        let club = data.dicValue("club")
        phone = club?.stringValue("tel") ?? ""
        if phone.count == 0 {
            phoneView.isHidden = true
            nameRightLC.constant = 10
        }
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = data.stringValue("name")
        numLB.text = "x\(data.intValue("num") ?? 1)"
        clubNameLB.text = club?.stringValue("name")
        clubAddressLB.text = club?.stringValue("address")
        priceLB.attributedText = attPriceStr(data.doubleValue("actualPrice") ?? 0)
        
        if let list = data.dicValue("coupons")?.arrValue("list"),
            !list.isEmpty,
            let endTime = data.stringValue("endTime"),
            let orderId = data.intValue("id")
        {
            qrView.initUI(list,
                          endTime: endTime,
                          orderId: orderId)
            stackView.insertArrangedSubview(qrView, at: 1)
        }
        let code = data.stringValue("code") ?? ""
        let orderMsg: [(String, String)] = [
            ("订单编号", code.count > 0 ? code : "暂未生成"),
            ("手机号", DataManager.mobile()),
            ("数量", "\(data.intValue("num") ?? 1)"),
            ("总价", "¥" + (data.doubleValue("totalPrice") ?? 0).decimalStr),
            ("实价", "¥" + (data.doubleValue("actualPrice") ?? 0).decimalStr)
        ]
        
        infoView.twoLBInitUI(orderMsg, title: "订单信息")
        if code.count > 0 {
            addCopyBtn()
        }
        stackView.addArrangedSubview(infoView)
        stackView.isHidden = false
    }
    
    private func addCopyBtn() {
        guard infoView.stackView.arrangedSubviews.count > 0 else {
            return
        }
        let view = infoView.stackView.arrangedSubviews[0]
        let btn = UIButton(type: .custom)
        btn.setTitle("复制", for: .normal)
        btn.setTitleColor(YellowMainColor, for: .normal)
        btn.titleLabel?.font = dzy_Font(13)
        btn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(view)
        }
    }
    
    @objc private func copyAction() {
        data.stringValue("code").flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }

//    MARK: - API
    private func detailApi() {
        let request = BaseRequest()
        request.url = BaseURL.LOrderDetail
        request.dic = ["lbsOrderId" : "\(orderId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("orderInfo") {
                self.updateUI(data)
            }
        }
    }
    
//    MARK: - 懒加载
    private lazy var infoView = LocationPublicInfoListView.initFromNib()
    
    private lazy var qrView: LocationOrderQrView = {
        let view = LocationOrderQrView.initFromNib()
        return view
    }()
}
