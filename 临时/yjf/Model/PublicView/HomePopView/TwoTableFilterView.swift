//
//  DistrictFilterView.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

@objc protocol TwoTableFilterViewDelegate {
    func ttView(_ ttView: TwoTableFilterView, didClickSureBtnWith fStr: String?, sStr: String?)
    func ttView(_ ttView: TwoTableFilterView, didClickClearBtn btn: UIButton)
}

enum TwoTableType {
    case district // 区域
    case order    // 排序
}

class TwoTableFilterView: UIView {
    
    weak var delegate: TwoTableFilterViewDelegate?
    
    private let firstCellBgColor = dzy_HexColor(0xF8F8F8)
    
    private let secondCellBgColor = dzy_HexColor(0xF5F5F5)
    
    private var firstDatas: [[String : Any]] = []
    
    private var secondDatas: [[String : Any]] = []

    @IBOutlet weak var firstTable: UITableView!

    @IBOutlet weak var secondTable: UITableView!
    
    var type: TwoTableType = .district
    
    private var leftValue: String?
    
    private var rightValue: Int?
    
    override func awakeFromNib() {
        firstTable.delegate     = self
        firstTable.dataSource   = self
        secondTable.delegate    = self
        secondTable.dataSource  = self
        firstTable.dzy_registerCellNib(DistrictFilterCell.self)
        secondTable.dzy_registerCellNib(DistrictFilterCell.self)
    }
    
    private func dealList(_ list :[[String : Any]]) -> [[String : Any]] {
        var temp = list
        (0..<temp.count).forEach { (index) in
            temp[index].updateValue(false, forKey: Public_isSelected)
        }
        return temp
    }
    
    func dealMsgInfo() -> Int? {
        guard let leftValue = leftValue, let rightValue = rightValue else {
            return nil
        }
        switch leftValue {
        case "面积":
            return rightValue == 0 ? 10 : 20
        case "成交时间":
            return rightValue == 0 ? 30 : 40
        case "单价":
            return rightValue == 0 ? 50 : 60
        default:
            return rightValue == 0 ? 70 : 80
        }
    }
    
    func initUI(_ type: TwoTableType) {
        self.type = type
        switch type {
        case .district:
            let cityId = RegionManager.cityId()
            firstDatas = dealList(RegionManager.list(cityId))
        case .order:
            let fd = ["面积", "成交时间", "单价", "总价"]
                .map({["name" : $0]})
            firstDatas = dealList(fd)
        }
        secondDatas = []
        firstTable.reloadData()
        secondTable.reloadData()
    }
    
    func reset() {
        leftValue = nil
        rightValue = nil
        initUI(type)
    }
    
    private func getOrderList(_ name: String) -> [[String : Any]] {
        switch name {
        case "面积":
            return ["由小到大", "由大到小"]
                .map({["name" : $0]})
        case "成交时间":
            return ["由旧到新", "由新到旧"]
                .map({["name" : $0]})
        default:
            return ["由低到高", "由高到低"]
                .map({["name" : $0]})
        }
    }
    
    func isEmpty() -> Bool {
        return firstDatas.isEmpty
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        delegate?.ttView(self, didClickClearBtn: sender)
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        let first = firstDatas
            .first(where: {$0.boolValue(Public_isSelected) == true})?
            .stringValue("name")
        leftValue = first
        if type == .district {
            let second = secondDatas
                .first(where: {$0.boolValue(Public_isSelected) == true})?
                .stringValue("name")
            delegate?.ttView(self, didClickSureBtnWith: first, sStr: second)
        }else {
            let second = secondDatas
                .firstIndex(where: {$0.boolValue(Public_isSelected) == true})
            rightValue = second
            let str = second == nil ? nil : ("\(first ?? "0")" + "\(second ?? 0)")
            delegate?.ttView(self, didClickSureBtnWith: first, sStr: str)
        }
    }
}

extension TwoTableFilterView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == firstTable ? firstDatas.count : secondDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(DistrictFilterCell.self)
        if tableView == firstTable {
            cell?.contentView.backgroundColor = firstCellBgColor
            cell?.updateUI(firstDatas[indexPath.row])
        }else {
            cell?.contentView.backgroundColor = secondCellBgColor
            cell?.updateUI(secondDatas[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == firstTable {
            if firstDatas[indexPath.row].boolValue(Public_isSelected) == true {
                return
            }
            (0..<firstDatas.count).forEach { (index) in
                firstDatas[index][Public_isSelected] = false
            }
            firstDatas[indexPath.row][Public_isSelected] = true
            switch type {
            case .district:
                if let id = firstDatas[indexPath.row].intValue("id") {
                    secondDatas = dealList(RegionManager.list(id))
                }
            case .order:
                if let name = firstDatas[indexPath.row].stringValue("name") {
                    let list = getOrderList(name)
                    secondDatas = dealList(list)
                }
            }
            secondTable.reloadData()
        }else {
            if secondDatas[indexPath.row]
                .boolValue(Public_isSelected) == true
            {
                return
            }
            (0..<secondDatas.count).forEach { (index) in
                secondDatas[index][Public_isSelected] = false
            }
            secondDatas[indexPath.row][Public_isSelected] = true
        }
        tableView.reloadData()
    }
}
