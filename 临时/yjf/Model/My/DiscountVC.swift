//
//  DiscountVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DiscountVC: BaseVC, ShareVCProtocol {

    @IBOutlet weak var topViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var stackHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    ///我已推广15人：
    @IBOutlet weak var numLB: UILabel!
    ///9.6折
    @IBOutlet weak var discountLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeightLC.constant = isiPhoneXScreen() ? 210 : 186
        detailApi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    private func initUI(_ str: String, num: Int) {
        var discount: String = ""
        let arr = str.components(separatedBy: ",")
        stackHeightLC.constant = CGFloat(arr.count + 1) * 40.0
        
        arr.forEach { (temp) in
            let view = DiscountView.initFromNib(DiscountView.self)
            view.updateUI(temp)
            stackView.addArrangedSubview(view)
            
            let valueArr = temp.components(separatedBy: ":")
            if let numStr = valueArr.first {
                let numArr = numStr.components(separatedBy: "-")
                if let min = Int(numArr.first ?? "0"),
                    let max = Int(numArr.last ?? "0"),
                    (num >= min) && (num <= max)
                {
                    discount = valueArr.last ?? "0"
                }
            }
        }
        
        numLB.text = "我已推广\(num)人："
        if num > 0 {
            if let discount = Double(discount) {
                discountLB.text = String(format: "%.1lf折", discount * 10)
            }
        }else {
            discountLB.text = "暂无折扣"
        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        shareBaseFun()
    }
    
    //    MARK: - api
    private func detailApi() {
        let request = BaseRequest()
        request.url = BaseURL.userAssist
        request.isUser = true
        request.dzy_start { (data, _) in
            if let str = data?.stringValue("assistDetail"),
                let num = data?.intValue("popularizeNum")
            {
                self.initUI(str, num: num)
            }
        }
    }
}
