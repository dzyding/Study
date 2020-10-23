//
//  DealInputFilterSbView.swift
//  YJF
//
//  Created by edz on 2019/7/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum DealInputType {
    /// 单价
    case sPrice
    /// 总价
    case tPrice
}

class DealInputFilterSbView: UIView {
    
    private let MaxValue = 9999
    
    private var type: DealInputType = .sPrice
    
    private let height: CGFloat = 177.0
    
    private var datas: [[String : Any]] = []

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var fStackView: UIStackView!
    
    @IBOutlet weak var sStackView: UIStackView!
    
    @IBOutlet weak var minTF: UITextField!
    
    @IBOutlet weak var maxTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        minTF.delegate = self
        maxTF.delegate = self
    }
    
    //    MARK: - 重制
    func reset(_ btn: UIButton? = nil) {
        minTF.text = nil
        maxTF.text = nil
        [fStackView, sStackView].forEach { (stackView) in
            stackView.arrangedSubviews.forEach { (view) in
                if let btn = view as? UIButton {
                    btn.isSelected = false
                }
            }
        }
        
        btn?.isSelected = true
        (0..<datas.count).forEach { (index) in
            let selected = btn?.tag == index
            datas[index][Public_isSelected] = selected
        }
    }
    
    //    MARK: - 获取数据
    func selectedMsg() -> (Double, Double)? {
        if let msg = datas.first(where:
            {$0.boolValue(Public_isSelected) == true}
            )?.stringValue("name")
        {
            return dealNormalPriceMsg(msg)
        }
        let minText = minTF.text
        let maxText = maxTF.text
        let minValue = Int(minText ?? "0") ?? 0
        let maxValue = Int(maxText ?? "\(MaxValue)") ?? MaxValue
        var str = ""
        if !minText.isEorN && !maxText.isEorN {
            str = "\(minValue)-\(maxValue)"
        }else if minText.isEorN && !maxText.isEorN {
            str = "0-\(maxValue)"
        }else if !minText.isEorN && maxText.isEorN {
            str = "\(minValue)-\(MaxValue)"
        }
        return dealCustomPriceMsg(str)
    }
    
    private func dealNormalPriceMsg(_ str: String) -> (Double, Double)? {
        if str.hasSuffix("万以下") {
            let value = str.replacingOccurrences(of: "万以下", with: "")
            return (0, Double(value) ?? 0)
        }else if str.hasSuffix("万以上") {
            let value = str.replacingOccurrences(of: "万以上", with: "")
            return (Double(value) ?? 0, Double(MaxValue))
        }else {
            return dealCustomPriceMsg(str)
        }
    }
    
    private func dealCustomPriceMsg(_ str: String) -> (Double, Double)? {
        let str = str.replacingOccurrences(of: "万", with: "")
        let arr = str.components(separatedBy: "-")
        if arr.count == 2 {
            let min = Double(arr[0]) ?? 0
            let max = Double(arr[1]) ?? Double(MaxValue)
            return (min, max)
        }else {
            return nil
        }
    }
    
    //    MARK: - 点击事件
    @objc private func btnAction(_ btn: UIButton) {
        minTF.text = nil
        maxTF.text = nil
        endEditing(true)
        let tag = btn.tag
        if btn.isSelected {
            btn.isSelected = false
            datas[tag][Public_isSelected] = false
        }else {
            reset(btn)
        }
    }
    
    //    MARK: - 初始化
    func initUI(_ type: DealInputType) {
        self.type = type
        var title: String = ""
        var fBtns: [String] = []
        var sBtns: [String] = []
        switch type {
        case .sPrice:
            title = "单价"
            fBtns = ["1万以下", "1-1.5万", "1.5-2万"]
            sBtns = ["2-3万", "3-5万", "5万以上"]
        case .tPrice:
            title = "总价"
            fBtns = ["80万以下", "80-100万", "100-150万"]
            sBtns = ["150-200万", "200-300万", "300万以上"]
        }
        datas = (fBtns + sBtns).enumerated().map({ (index, str) -> [String : Any] in
            return [
                "name" : str,
                Public_isSelected : false
            ]
        })
        titleLB.text = title
        (fBtns + sBtns).enumerated().forEach { (index, str) in
            let btn = DealListHelper.getFilterBtn(str)
            btn.addTarget(
                self,
                action: #selector(btnAction(_:)),
                for: .touchUpInside
            )
            btn.isSelected = false
            btn.tag = index
            if index < 3 {
                fStackView.addArrangedSubview(btn)
            }else {
                sStackView.addArrangedSubview(btn)
            }
        }
        
        snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
    }
}

extension DealInputFilterSbView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        [fStackView, sStackView].forEach { (stackView) in
            stackView.arrangedSubviews.forEach { (view) in
                if let btn = view as? UIButton {
                    btn.isSelected = false
                }
            }
        }
        (0..<datas.count).forEach { (index) in
            datas[index][Public_isSelected] = false
        }
    }
}
