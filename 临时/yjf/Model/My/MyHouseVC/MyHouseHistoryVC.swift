//
//  MyHouseHistoryVC.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyHouseHistoryVC: BasePageVC, BaseRequestProtocol, HouseTypeDealable {

    var re_listView: UIScrollView {
        return tableView
    }
    
    private var observer: Any?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(MyHouseUnTradedCell.self)
        tableView.dzy_registerCellNib(MyHouseTradedCell.self)
        listAddHeader()
        listApi(1)
        observerFunc()
    }
    
    deinit {
        dzy_log("销毁")
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //    MARK: - 选择房源
    private func selectedHouseAction(_ index: Int) {
        let house = dataArr[index]
        let type = (house[HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        guard let houseId = house.intValue("id") else {return}
        let vc = HouseDetailVC(houseId)
        switch type {
        case .end:
            vc.isDeal = true
        case .undo:
            vc.isUndo = true
        default:
            break
        }
        dzy_push(vc)
    }
    
    private func observerFunc() {
        [
            PublicConfig.Notice_UndoHouseSuccess,
            PublicConfig.Notice_AddHouseSuccess
        ].forEach { (name) in
            observer = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: nil
            ) { [weak self] (_) in
                self?.listApi(1)
            }
        }
    }
    
    func dealWithTheDatas(_ datas: inout [[String : Any]]) {
        (0..<datas.count).forEach { (index) in
            let data = datas[index]
            if let houseType = dealHouseData(data) {
                datas[index].updateValue(houseType, forKey: HouseTypeKey)
            }
        }
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.sellerHouseList
        request.dic = ["type" : 20]
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data, isReload: true, isDeal: true)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
    
    func installLockApi(_ data: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.installLock
        request.dic = data
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.listApi(1)
            }
        }
    }
}

extension MyHouseHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = (dataArr[indexPath.section][HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        switch type {
        case .undo, .auditFail:
            let cell = tableView
                .dzy_dequeueReusableCell(MyHouseUnTradedCell.self)
            cell?.updateUI(dataArr[indexPath.section], index: indexPath.section)
            cell?.delegate = self
            return cell!
        default: //.end
            let cell = tableView
                .dzy_dequeueReusableCell(MyHouseTradedCell.self)
            cell?.delegate = self
            cell?.updateUI(dataArr[indexPath.section], index: indexPath.section)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = (dataArr[indexPath.section][HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        return MyHouseCellHelper.cellHeight(type)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10.0))
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension MyHouseHistoryVC: MyHouseUnTradedCellDelegate {
    
    func unTradedCell(_ cell: MyHouseUnTradedCell, didClickBtn btn: UIButton, index: Int) {
        guard let type = MyHouseCellAction(rawValue: btn.tag) else {return}
        let data = dataArr[index]
        typeBtnClickAction(data, type: type)
    }
    
    func unTradedCell(_ cell: MyHouseUnTradedCell, selectedHouse btn: UIButton, index: Int) {
        selectedHouseAction(index)
    }
}

extension MyHouseHistoryVC: MyHouseTradedCellDelegate {
    func tradedCell(_ cell: MyHouseTradedCell, didClickBtn btn: UIButton, index: Int) {
        guard let type = MyHouseCellAction(rawValue: btn.tag) else {return}
        let data = dataArr[index]
        typeBtnClickAction(data, type: type)
    }
    
    func tradedCell(_ cell: MyHouseTradedCell, selectedHouse btn: UIButton, index: Int) {
        selectedHouseAction(index)
    }
}
