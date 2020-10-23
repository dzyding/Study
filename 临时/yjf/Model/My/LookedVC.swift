//
//  LookedVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class LookedVC: BasePageVC, BaseRequestProtocol, JumpHouseDetailProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    /// 搜索关键字
    private var key: String?
    
    private var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        navigationItem.title = "实地看过的房源"
        inputTF.addTarget(self, action: #selector(editEnd(_:)), for: .editingDidEnd)
        inputTF.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
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
    
    @objc private func editEnd(_ tf: UITextField) {
        let new = tf.text
        if key != new {
            key = new
            listApi(1)
        }
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.lookHouseList
        if let key = key, key.count > 0 {
            request.dic = ["key" : key]
        }
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data)
            self.emptyView.isHidden = self.dataArr.count > 0
        }
    }
    
    //    MARK: - 懒加载
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10))
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        return view
    }()
}

extension LookedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        let memo = data.dicValue("houseRemark")?.stringValue("remark")
        let house = data.dicValue("lockOpenLog")?.dicValue("house") ?? [:]
        if house.isOrderSuccess() {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.paddingUpdateUI(house)
            return cell!
        }else if let memo = memo {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalMemoCell.self)
            cell?.delegate = self
            cell?.updateUI(memo, data: house)
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
        let data = dataArr[indexPath.row]
        let memo = data.stringValue("remark")
        let house = data.dicValue("house") ?? [:]
        if house.isOrderSuccess() {
            return 89
        }else if memo != nil {
            return 159
        }else {
            return 97
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataArr[indexPath.row]
            .dicValue("lockOpenLog")?
            .dicValue("house")
            .flatMap({
                goHouseDetail(false, house: $0)
            })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        inputTF.resignFirstResponder()
    }
}

extension LookedVC: HouseListNormalCellDelegate {
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {}
    
    func normalCell(_ normalCell: HouseListNormalCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}

extension LookedVC: HouseListNormalMemoCellDelegate {
    func memoCell(_ memoCell: HouseListNormalMemoCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}
