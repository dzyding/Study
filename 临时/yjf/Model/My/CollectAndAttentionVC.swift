//
//  CollectAndAttentionVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum CollectOrAttentionType {
    case collect
    case attention
}

class CollectAndAttentionVC: BasePageVC, BaseRequestProtocol, JumpHouseDetailProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }

    let type: CollectOrAttentionType
    
    //空数据的现实
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var emptyLB: UILabel!
    
    @IBOutlet weak var emptyIV: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    /// 全选
    @IBOutlet weak var selectAllBtn: UIButton!
    /// 批量收藏 关注的按钮
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var tableViewRightLC: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewBottomLC: NSLayoutConstraint!
    /// 是否为批量操作中
    var isBatch: Bool = false
    
    private var timer: Timer? = nil
    
    init(_ type: CollectOrAttentionType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
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
            }
        }
    }
    
    // MARK: - 批量取消
    // 准备工作
    @objc func batchCancelPrepareAction() {
        isBatch = !isBatch
        tableViewRightLC.constant = isBatch ? -32 : 0
        tableViewBottomLC.constant = isBatch ? 70 : 0
        tableView.reloadData()
    }
    
    // 批量取消
    @IBAction func batchCancelAction(_ sender: UIButton) {
        let ids = dataArr
            .filter({$0.boolValue(Public_isSelected) == true})
            .compactMap({$0.intValue("id")})
        batchCancelApi(ids, success: { [weak self] in
            self?.listApi(1)
        })
    }
    
    // MARK: - 全选
    @IBAction func selectAllAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        (0..<dataArr.count).forEach { (index) in
            dataArr[index][Public_isSelected] = sender.isSelected
        }
        tableView.reloadData()
    }
    
    //    MARK: - 数据处理
    func dealWithTheDatas(_ datas: inout [[String : Any]]) {
        (0..<datas.count).forEach { (index) in
            datas[index].updateValue(false, forKey: Public_isSelected)
        }
    }
    
    //    MARK: - api
    // 数据请求
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = type == .collect ? BaseURL.myCollect : BaseURL.myAttention
        request.page = [page, 10]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.pageOperation(data: data, isReload: true, isDeal: true)
            self.emptyView.isHidden = self.dataArr.count != 0
        }
    }
    
    // 批量取消
    func batchCancelApi(_ ids: [Int], success: @escaping ()->()) {
        let request = BaseRequest()
        request.url = type == .collect ? BaseURL.batchCancelCollect : BaseURL.batchCancelAttention
        request.dic = ["idList" : ToolClass.toJSONString(dict: ids)]
        request.dzy_start { (data, _) in
            if data != nil {
                success()
            }
        }
    }

    //    MARK: - UI
    private func setUI() {
        navigationItem.rightBarButtonItem = rightNaviBtn
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(HouseListNormalCell.self)
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
        
        bottomView.layer.shadowRadius = 4
        bottomView.layer.shadowColor   = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.1
        bottomView.layer.shadowOffset  = CGSize(width: 0, height: -5)
        
        emptyView.isHidden = true
        
        switch type {
        case .collect:
            navigationItem.title = "收藏的房源"
            actionBtn.setTitle("取消收藏", for: .normal)
            emptyIV.image = UIImage(named: "collect_empty")
        case .attention:
            navigationItem.title = "关注的房源"
            actionBtn.setTitle("取消关注", for: .normal)
            emptyIV.image = UIImage(named: "attention_empty")
        }
    }
    
    //    MARK: - 懒加载
    lazy var rightNaviBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 45.0, height: 30.0)
        btn.setTitle("批量取消", for: .normal)
        btn.titleLabel?.font = dzy_Font(13)
        btn.setTitleColor(Font_Dark, for: .normal)
        btn.addTarget(self, action: #selector(batchCancelPrepareAction), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        return item
    }()
}

extension CollectAndAttentionVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let house = dataArr[indexPath.row].dicValue("house") ?? [:]
        if house.isOrderSuccess() {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.batchUpdateUI(house, isBatch: isBatch)
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalCell.self)
            cell?.updateUI(
                isBatch, data: dataArr[indexPath.row], row: indexPath.row
            )
            cell?.delegate = self
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let house = dataArr[indexPath.row].dicValue("house") ?? [:]
        return house.isOrderSuccess() ? 89 : 97
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let house = dataArr[indexPath.row].dicValue("house") ?? [:]
        goHouseDetail(false, house: house)
    }
}

extension CollectAndAttentionVC: HouseListNormalCellDelegate {
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {
        let current = dataArr[row].boolValue(Public_isSelected) ?? false
        dataArr[row][Public_isSelected] = !current
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        let selectedCount = dataArr.filter({$0.boolValue(Public_isSelected) == true}).count
        selectAllBtn.isSelected = selectedCount == dataArr.count
    }
    
    func normalCell(_ normalCell: HouseListNormalCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}
