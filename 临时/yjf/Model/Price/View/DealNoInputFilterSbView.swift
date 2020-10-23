//
//  DealNoInputFilterSbView.swift
//  YJF
//
//  Created by edz on 2019/7/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum DealNoInputType {
    case floor
    case time
}

class DealNoInputFilterSbView: UIView {
    
    private let height: CGFloat = 133
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var fStackView: UIStackView!
    
    @IBOutlet weak var sStackView: UIStackView!
    
    private var type: DealNoInputType = .floor
    
    private var datas: [[String : Any]] = []
    
    //    MARK: - 重制
    func reset(_ btn: UIButton? = nil) {
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
    func selectedFloorMsg() -> (Int, Int)? {
        if let msg = datas.first(where:
            {$0.boolValue(Public_isSelected) == true}
            )?.stringValue("name") {
            return dealFloorMsg(msg)
        }
        return nil
    }
    
    func selectedTimeMsg() -> (String, String)? {
        if let msg = datas.first(where:
            {$0.boolValue(Public_isSelected) == true}
            )?.stringValue("name") {
            return dealTimeMsg(msg)
        }
        return nil
    }
    
    private func dealFloorMsg(_ msg: String) -> (Int, Int) {
        if msg.hasSuffix("以下") {
            let value = msg.replacingOccurrences(of: "以下", with: "")
            return (0, Int(value) ?? 0)
        }else if msg.hasSuffix("以上") {
            let value = msg.replacingOccurrences(of: "以上", with: "")
            return (Int(value) ?? 0, 999)
        }else {
            let arr = msg.components(separatedBy: "-")
            let minStr = arr.first ?? "0"
            let maxStr = arr.last ?? "999"
            return (Int(minStr) ?? 0, Int(maxStr) ?? 0)
        }
    }
    
    private func dealTimeMsg(_ msg: String) -> (String, String) {
        let calendar = Calendar.current
        let now = dzy_date8()
        var component = DateComponents()
        switch msg {
        case "近一周":
            component.day = -7
        case "近一个月":
            component.month = -1
        case "近三个月":
            component.month = -3
        case "近半年":
            component.month = -6
        case "近一年":
            component.year = -1
        default: // 一年以上
            component.year = -99
        }
        let startDate = calendar
            .date(byAdding: component, to: now) ?? Date()
        return (startDate.description, now.description)
    }
    
    //    MARK: - 按钮点击事件
    @objc private func btnAction(_ btn: UIButton) {
        let tag = btn.tag
        if btn.isSelected {
            btn.isSelected = false
            datas[tag][Public_isSelected] = false
        }else {
            reset(btn)
        }
    }
    
    //    MARK: -  初始化
    func initUI(_ type: DealNoInputType) {
        self.type = type
        var title: String = ""
        var fBtns: [String] = []
        var sBtns: [String] = []
        switch type {
        case .floor:
            title = "楼层"
            fBtns = ["5以下", "6-10", "11-15", "16-20"]
            sBtns = ["21-25", "26-30", "30以上", ""]
        case .time:
            title = "成交时间"
            fBtns = ["近一周", "近一个月", "近三个月", "近半年"]
            sBtns = ["近一年", "一年以上", "", ""]
        }
        datas = (fBtns + sBtns).enumerated().map({ (index, str) -> [String : Any] in
            return [
                "name" : str,
                Public_isSelected : false
            ]
        })
        titleLB.text = title
        (fBtns + sBtns).enumerated().forEach { (index, str) in
            if str.count > 0 {
                let btn = DealListHelper.getFilterBtn(str)
                btn.addTarget(
                    self,
                    action: #selector(btnAction(_:)),
                    for: .touchUpInside
                )
                btn.isSelected = false
                btn.tag = index
                if index < 4 {
                    fStackView.addArrangedSubview(btn)
                }else {
                    sStackView.addArrangedSubview(btn)
                }
            }else {
                let view = UIView()
                if index < 4 {
                    fStackView.addArrangedSubview(view)
                }else {
                    sStackView.addArrangedSubview(view)
                }
            }
        }
        
        snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
    }
}
