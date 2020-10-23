//
//  CoachReduceBaseVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceBaseVC: BaseVC {
    
    private let itemInfo: IndicatorInfo
    
    @IBOutlet weak var tableView: UITableView!
    /// 对应日期与今天的差值
    private let x: Int
    /// 当前 vc 对应的日期
    private let date: Date
    
    private var list: [[String : Any]] = []
    
    private lazy var tableFooterView: UIView = {
        let footer = Bundle.main.loadNibNamed("MyCoachFooterView", owner: self, options: nil)?.first as! UIView
        footer.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50.0)
        return footer
    }()
    
    init(_ itemInfo: IndicatorInfo, date: Date, x: Int) {
        self.itemInfo = itemInfo
        self.date = date
        self.x = x
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100.0
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(MyCoachClassCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reserveListApi()
    }
    
    private func updateUI(_ data: [String : Any]) {
        list = data.arrValue("list") ?? []
        if list.count > 0 {
            tableView.tableFooterView = tableFooterView
        }else {
            tableView.tableFooterView = nil
        }
        tableView.reloadData()
    }
    
    //    MARK: - api
    // 今日预约详情
    private func reserveListApi() {
        let time = date.description.components(separatedBy: " ").first ?? ""
        let request = BaseRequest()
        request.url = BaseURL.ReserveList_Pt
        request.dic = ["reserveTime" : time]
        request.isSaasPt = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.updateUI(data)
            }
        }
    }
    
    // 取消预约
    private func cancelReserveApi(_ reserveId: Int, mid: String) {
        let request = BaseRequest()
        request.url = BaseURL.CancelPtReserve
        request.dic = [
            "reserveId" : "\(reserveId)",
            "fromPt" : "1"
        ]
        request.setMemberId(mid)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.reserveListApi()
            }
        }
    }
}

extension CoachReduceBaseVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MyCoachClassCell.self)
        cell?.topLine.isHidden = indexPath.row == 0
        cell?.ptUpdateUI(list[indexPath.row], date: date, x: x)
        cell?.delegate = self
        return cell!
    }
}


extension CoachReduceBaseVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension CoachReduceBaseVC: MyCoachClassCellDelegate {
    func classCell(_ classCell: MyCoachClassCell, didSelectDelBtn btn: UIButton, reserveId: Int, mid: String) {
        let alert = dzy_normalAlert("提示", msg: "是否取消此次预约", sureClick: { [weak self] (_) in
            self?.cancelReserveApi(reserveId, mid: mid)
            }, cancelClick: nil)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func classCell(_ classCell: MyCoachClassCell,
                   didSelectQrCodeBtn btn: UIButton, code: String) {}
}
