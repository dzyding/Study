//
//  MySellingHouseVC.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class MySellingHouseVC: BasePageVC, BaseRequestProtocol, HouseTypeDealable, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    private var timer: Timer? = nil
    
    deinit {
        deinitObservers()
        dzy_log("销毁")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(MyHouseUnTradedCell.self)
        tableView.dzy_registerCellNib(MyHouseUnTradedPriceCell.self)
        tableView.dzy_registerCellNib(MyHouseTradedCell.self)
        listAddHeader()
        observerFunc()
        listApi(1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer(timeInterval: 1, repeats: true, block: timeAction)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    //    MARK: - 滚动的 timerAction
    private func timeAction(_ timer: Timer) {
        let total = Int(Date().timeIntervalSince1970)
        tableView.visibleCells.forEach { (cell) in
            if let cell = cell as? MyHouseUnTradedPriceCell {
                cell.updatePriceAction(total)
            }
        }
    }
    
    //    MARK: - 各种结果监听
    private func observerFunc() {
        registObservers([
            PublicConfig.Notice_UndoHouseSuccess,
            PublicConfig.Notice_AddHouseSuccess,
            PublicConfig.Notice_PayBuyDepositSuccess,
            PublicConfig.Notice_PaySellDepositSuccess,
            PublicConfig.Notice_AddPriceSuccess
            ], block: { [weak self] in
                self?.listApi(1)
        })
    }
    
    //    MARK: - 数据处理
    func dealWithTheDatas(_ datas: inout [[String : Any]]) {
        (0..<datas.count).forEach { (index) in
            let data = datas[index]
            if let houseType = dealHouseData(data) {
                datas[index].updateValue(houseType, forKey: HouseTypeKey)
            }
        }
    }
    
    //    MARK: - 选择房源
    private func selectedHouseAction(_ index: Int) {
        let type = (dataArr[index][HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        switch type {
        case .signed, .traded:
            dataArr[index].intValue("id").flatMap({
                let vc = HouseDetailVC($0)
                vc.isDeal = true
                dzy_push(vc)
            })
        default : //审核，待发布 (需满足用户看房需求)
            //已发布
            dataArr[index].intValue("id").flatMap({
                let vc = HouseDetailVC($0)
                dzy_push(vc)
            })
        }
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.sellerHouseList
        request.dic = ["type" : 10]
        request.page = [page, 10]
        request.isUser = true
        if page == 1 {
            ZKProgressHUD.show()
        }
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            self.pageOperation(data: data, isReload: true, isDeal: true)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
    
    func installLockApi(_ data: [String : Any]) {
        var temp = data
        DataManager.staffMsg().flatMap({
            temp.merge($0, uniquingKeysWith: {$1})
        })
        let request = BaseRequest()
        request.url = BaseURL.installLock
        request.dic = temp
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            DataManager.saveStaffMsg(nil)
            ZKProgressHUD.dismiss()
            if data != nil {
                self.listApi(1)
            }
        }
    }
}

extension MySellingHouseVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = (dataArr[indexPath.section][HouseTypeKey] as? MyHouseType) ?? MyHouseType.traded
        switch type {
        case .released(_, _, let isPrice),
             .waitAudit(_, _, let isPrice),
             .auditSuccess(_, _, let isPrice):
            if isPrice {
                let cell = tableView
                    .dzy_dequeueReusableCell(MyHouseUnTradedPriceCell.self)
                cell?.updateUI(dataArr[indexPath.section], index: indexPath.section)
                cell?.delegate = self
                return cell!
            }else {
                let cell = tableView
                    .dzy_dequeueReusableCell(MyHouseUnTradedCell.self)
                cell?.delegate = self
                cell?.updateUI(dataArr[indexPath.section], index: indexPath.section)
                return cell!
            }
        default : //.signed, .traded
            let cell = tableView
                .dzy_dequeueReusableCell(MyHouseTradedCell.self)
            cell?.delegate = self
            cell?.updateUI(dataArr[indexPath.section], index: indexPath.section)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = dataArr[indexPath.section][HouseTypeKey] as? MyHouseType
        return MyHouseCellHelper.cellHeight(type ?? MyHouseType.traded)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MySellingHouseVC: MyHouseUnTradedCellDelegate {
    
    func unTradedCell(_ cell: MyHouseUnTradedCell, didClickBtn btn: UIButton, index: Int) {
        guard let type = MyHouseCellAction(rawValue: btn.tag) else {return}
        let data = dataArr[index]
        typeBtnClickAction(data, type: type)
    }
    
    func unTradedCell(_ cell: MyHouseUnTradedCell, selectedHouse btn: UIButton, index: Int) {
        selectedHouseAction(index)
    }
}

extension MySellingHouseVC: MyHouseUnTradedPriceCellDelegate {
    func priceCell(_ pirceCell: MyHouseUnTradedPriceCell, didClickBtn btn: UIButton, withIndex index: Int) {
        guard let type = MyHouseCellAction(rawValue: btn.tag) else {return}
        let data = dataArr[index]
        typeBtnClickAction(data, type: type)
    }
    
    func priceCell(_ pirceCell: MyHouseUnTradedPriceCell, selectedHouse btn: UIButton, withIndex index: Int) {
        selectedHouseAction(index)
    }
}

extension MySellingHouseVC: MyHouseTradedCellDelegate {
    func tradedCell(_ cell: MyHouseTradedCell, didClickBtn btn: UIButton, index: Int) {
        guard let type = MyHouseCellAction(rawValue: btn.tag) else {return}
        let data = dataArr[index]
        typeBtnClickAction(data, type: type)
    }
    
    func tradedCell(_ cell: MyHouseTradedCell, selectedHouse btn: UIButton, index: Int) {
        selectedHouseAction(index)
    }
}
