//
//  T12GoodsDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/11/12.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class T12GoodsDetailVC: BaseVC, AttPriceProtocol, ShareSaveImageProtocol {
    
    var fpp: String?
    
    private let goodsId: Int
    
    private var goods: [String : Any] = [:]
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var opriceLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    init(_ goodsId: Int) {
        self.goodsId = goodsId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商品详情"
        navigationItem.rightBarButtonItem = shareItem
        detailApi()
    }
    
    private func updateUI(_ data: [String : Any]) {
        self.goods = data
        titleLB.text = data.stringValue("title")
        let price = data.doubleValue("presentPrice") ?? 0
        priceLB.attributedText = attPriceStr(price)
        let oprice = data.doubleValue("originPrice") ?? 0
        opriceLB.text = "￥\(oprice.decimalStr)"
        (data["imgs"] as? [String])?.forEach({ (url) in
            let imgView = T12GoodsImgView.initFromNib()
            imgView.updateUI(url)
            stackView.addArrangedSubview(imgView)
        })
    }

//    MARK: - 分享
    @IBAction @objc private func shareAction(_ sender: Any) {
        func showShareView(_ url: String) {
            let sview = SharePlatformView.instanceFromNib()
            sview.frame = ScreenBounds
            sview.goodsUpdateUI(goods, url: url)
            sview.initUI(.goods)
            sview.saveHandler = { [weak self] image in
                self?.showSaveAlert(image)
            }
            UIApplication.shared.keyWindow?.addSubview(sview)
        }
        shareCodeApi { (url) in
            showShareView(url)
        }
    }
    
//    MARK: - 购买
    @IBAction func buyAction(_ sender: Any) {
        let vc = T12GoodsSubmitVC(goods)
        vc.fpp = fpp
        dzy_push(vc)
    }
    
//    MARK: - api
    private func detailApi() {
        let request = BaseRequest()
        request.url = BaseURL.GoodsDetail
        request.dic = ["goodsId" : "\(goodsId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("goods") {
                self.updateUI(data)
            }
        }
    }
    
    private func shareCodeApi(_ complete: @escaping (String)->()) {
        let request = BaseRequest()
        request.url = BaseURL.ShareCode
        request.dic = [
            "type" : "20",
            "goodsId" : "\(goodsId)",
            "title" : goods.stringValue("title") ?? ""
        ]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let url = data?.stringValue("url") {
                complete(url)
            }else {
                ToolClass.showToast("生成分享指令失败", .Failure)
            }
        }
    }
    
//    MARK: - 懒加载
    private lazy var shareItem: UIBarButtonItem = {
        let btn = DzySafeBtn(type: .custom)
        btn.enabledTime = 1
        btn.setImage(UIImage(named: "goods_share"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        btn.addTarget(self,
                      action: #selector(shareAction(_:)),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}
