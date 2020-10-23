//
//  FootMarkVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class FootMarkVC: BasePageVC, BaseRequestProtocol, JumpHouseDetailProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var inputTF: UITextField!
    /// 时间，对应数组
    private var dates: [String] = []
    
    private var dics: [[[String : Any]]] = []
    
    private var key: String?
    
    private var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        navigationItem.title = "浏览过的房源"
        inputTF.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
        inputTF.addTarget(self, action: #selector(editedEnd(_:)), for: .editingDidEnd)
        tableView.separatorStyle = .none
        tableView.backgroundColor = dzy_HexColor(0xf5f5f5)
        tableView.dzy_registerCellNib(HouseListNormalCell.self)
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
        tableView.dzy_registerCellNib(HouseListNormalMemoCell.self)
        listAddHeader()
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
            if let cell = cell as? HouseListNormalCell {
                cell.updatePriceAction(total)
            }else if let cell = cell as? HouseListNormalMemoCell {
                cell.updatePriceAction(total)
            }
        }
    }
    
    //    MARK: - 输入结束
    @objc private func editedEnd(_ tf: UITextField) {
        let oldKey = key
        key = tf.text
        if oldKey != key {
            listApi(1)
        }
    }
    
    //    MARK: - 数据处理，分类
    private func dealWithTheData(_ list: [[String : Any]]) {
        list.forEach({ (dic) in
            if let temp = dic
                .dicValue("browse")?
                .stringValue("updateTime")?
                .components(separatedBy: " ")
                .first,
                temp.count > 0
            {
                let time = String(temp[temp.index(temp.startIndex, offsetBy: 5)...])
                if let index = dates.firstIndex(where: {$0 == time}) {
                    dics[index].append(dic)
                }else {
                    dates.append(time)
                    dics.append([dic])
                }
            }
        })
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.footMarkList
        key.flatMap({request.dic = ["key" : $0]})
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.tableView.srf_endRefreshing()
            guard let page = data?["page"] as? [String : Any] else {return}
            let listData = data?.arrValue("list") ?? []
            self.page = page
            if self.currentPage == 1 {
                self.dates.removeAll()
                self.dics.removeAll()
            }
            let canLoadMore = self.currentPage! < self.totalPage!
            self.tableView.srf_canLoadMore(canLoadMore)
            self.dealWithTheData(listData)
            self.tableView.reloadData()
        }
    }
}

extension FootMarkVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dics[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = dics[indexPath.section][indexPath.row]
        let remark = dic.dicValue("houseRemark") ?? [:]
        let house = dic.dicValue("house") ?? [:]
        if house.isOrderSuccess() {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.paddingUpdateUI(house)
            return cell!
        }else if remark.count > 0 {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalMemoCell.self)
            cell?.updateUI(remark.stringValue("remark") ?? "", data: house)
            cell?.delegate = self
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalCell.self)
            cell?.delegate = self
            cell?.paddingUpdateUI(house)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let dic = dics[indexPath.section][indexPath.row]
        let remark = dic.dicValue("houseRemark") ?? [:]
        let house = dic.dicValue("house") ?? [:]
        if house.isOrderSuccess() {
            return 89
        }else if remark.count > 0 {
            return 159
        }else {
            return 97
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = FootMarkDateHeaderView.initFromNib(FootMarkDateHeaderView.self)
        header.updateUI(dates[section])
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = dics[indexPath.section][indexPath.row]
        let house = dic.dicValue("house") ?? [:]
        goHouseDetail(false, house: house)
    }
}

extension FootMarkVC: HouseListNormalCellDelegate {
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {}
    
    func normalCell(_ normalCell: HouseListNormalCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}

extension FootMarkVC: HouseListNormalMemoCellDelegate {
    func memoCell(_ memoCell: HouseListNormalMemoCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}
