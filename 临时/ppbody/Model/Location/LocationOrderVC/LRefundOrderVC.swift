//
//  LCancelOrRefundOrderVC.swift
//  PPBody
//
//  Created by edz on 2019/11/1.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LRefundOrderVC: BaseVC, AttPriceProtocol {
    
    private let order: [String : Any]

    @IBOutlet weak var placeHolderLB: UILabel!
    
    @IBOutlet weak var inputTX: UITextView!
    
    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var sureBtn: UIButton!
    
    init(_ order: [String : Any]) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTX.delegate = self
        logoIV.setCoverImageUrl(order.stringValue("cover") ?? "")
        nameLB.text = order.stringValue("name")
        numLB.text = "x\(order.intValue("num") ?? 1)"
        priceLB.attributedText = attPriceStr(order.doubleValue("totalPrice") ?? 0)
        navigationItem.title = "退款"
        placeHolderLB.text = "退款理由（选填）"
        sureBtn.setTitle("确认退款", for: .normal)
        
    }
    
    private func refundSuccess() {
        ToolClass.showToast("操作成功", .Success)
        NotificationCenter.default.post(
            name: Config.Notify_RefreshLocationOrder,
            object: nil)
        dzy_delayPop(1)
    }

    @IBAction func btnAction(_ sender: UIButton) {
        guard let oId = order.intValue("id") else {
            ToolClass.showToast("订单数据异常", .Failure)
            return
        }
        guard let reason = inputTX.text, reason.count > 0 else {
            ToolClass.showToast("请输入退款理由", .Failure)
            return
        }
        refundOrderApi([
            "lbsOrderId" : "\(oId)",
            "reason" : reason
        ])
    }
    
//    MARK: - api
    private func refundOrderApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.LOrderRefund
        request.dic = dic
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.refundSuccess()
            }
        }
    }
}

extension LRefundOrderVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLB.isHidden = textView.text.count > 0
    }
}
