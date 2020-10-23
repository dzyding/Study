//
//  MyBiddingVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyBiddingVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet private weak var tableView: UITableView!
    /// tableView 到右边的边距，进行批量操作
    @IBOutlet private weak var tableViewRightLC: NSLayoutConstraint!
    /// tableView 到底部的边距 0 80
    @IBOutlet private weak var tableViewBottomLC: NSLayoutConstraint!
    
    @IBOutlet private weak var bottomView: UIView!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    private var isBatch: Bool = false
    
    private var observer: Any?
    
    private var timer: Timer? = nil
    
    deinit {
        dzy_log("销毁")
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.layer.shadowRadius = 6
        bottomView.layer.shadowColor = RGB(r: 153.0, g: 153.0, b: 153.0).cgColor
        bottomView.layer.shadowOpacity = 0.1
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -4)
        tableView.dzy_registerCellNib(MyBiddingCell.self)
        listAddHeader()
        listApi(1)
        
        observer = NotificationCenter.default.addObserver(
            forName: PublicConfig.Notice_UndoPriceSuccess,
            object: nil,
            queue: nil,
            using:
        { [weak self] (_) in
            self?.listApi(1)
        })
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
            if let cell = cell as? MyBiddingCell {
                cell.updatePriceAction(total)
            }
        }
    }

    func batchAction() {
        isBatch = !isBatch
        tableViewRightLC.constant = isBatch ? -32 : 0
        tableViewBottomLC.constant = isBatch ? 85 : 0
        tableView.reloadData()
    }
    
    //    MARK: - 选择状态的更新
    private func updateSelectStatus() {
        let all = dataArr.filter({$0.boolValue(Public_isSelected) == true}).count == dataArr.count
        selectAllBtn.isSelected = all
    }
    
    //    MARK: - 选择全部
    @IBAction func selectAllAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        (0..<dataArr.count).forEach { (index) in
            dataArr[index][Public_isSelected] = sender.isSelected
        }
        tableView.reloadData()
    }
    //    MARK: - 撤销报价
    @IBAction func cancelBidsAction(_ sender: UIButton) {
        let ids = dataArr.compactMap { (dic) -> Int? in
            if dic.boolValue(Public_isSelected) == true {
                return dic.dicValue("houseBuy")?.intValue("id")
            }else {
                return nil
            }
        }
        if ids.count != 0 {
            let dic = ["idList" : ToolClass.toJSONString(dict: ids)]
            DataManager.saveUndoMsg(dic)
            let vc = CertificationVC()
            dzy_push(vc)
        }else {
            showMessage("请选择需要取消的房源报价")
        }
    }
    
    //    MARK: - 加载数据之前的处理
    func dealWithTheDatas(_ datas: inout [[String : Any]]) {
        (0..<datas.count).forEach { (index) in
            datas[index].updateValue(false, forKey: Public_isSelected)
        }
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.buyerBidList
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data, isReload: true, isDeal: true)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
}

extension MyBiddingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(MyBiddingCell.self)
        cell?.updateUI(
            dataArr[indexPath.section],
            isBatch: isBatch,
            index: indexPath.section
        )
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isDeposit = dataArr[indexPath.section]
            .dicValue("houseBuy")?.intValue("effect") ?? 0
        return isDeposit == 1 ? 175 : 201
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10.0))
        footer.backgroundColor = dzy_HexColor(0xF5F5F5)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArr[indexPath.section]
        if let houseId = data.dicValue("house")?.intValue("id") {
            let vc = HouseDetailVC(houseId)
            dzy_push(vc)
        }
    }
}

extension MyBiddingVC: MyBiddingCellDelegate {
    func biddingCell(_ biddingCell: MyBiddingCell, didSelected index: Int) {
        let old = dataArr[index].boolValue(Public_isSelected) ?? false
        dataArr[index].updateValue(!old, forKey: Public_isSelected)
        updateSelectStatus()
    }
    
    func biddingCell(_ biddingCell: MyBiddingCell, didClickPayDepositBtn index: Int) {
        let vc = PayBuyDepositVC(.normal)
        dzy_push(vc)
    }
}
