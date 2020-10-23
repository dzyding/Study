//
//  LocationActivityVC.swift
//  PPBody
//
//  Created by edz on 2019/11/6.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationActivityVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    // 1 36 69
    private var type: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAddHeader()
        tableView.dzy_registerCellNib(LocationActivityCell.self)
        listApi(1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?
            .setNavigationBarHidden(false, animated: false)
    }

    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    func listApi(_ page: Int) {
        let manager = LocationManager.locationManager
        guard let cityCode = manager.cityCode else {
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.T12List
        request.dic = [
            "cityCode" : cityCode,
            "latitude" : manager.latitude,
            "longitude" : manager.longitude,
            "type" : "\(type)"
        ]
        request.page = [page, 20]
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
//    MARK: - 懒加载
    private lazy var header: LActivityTBHeaderView = {
        let view = LActivityTBHeaderView.initFromNib()
        view.delegate = self
        return view
    }()
}

extension LocationActivityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LocationActivityCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let gid = dataArr[indexPath.row].intValue("groupBuyId") else {
            ToolClass.showToast("无效的团购数据", .Failure)
            return
        }
        let vc = LocationGBDetailVC(gid)
        dzy_push(vc)
    }
}

extension LocationActivityVC: LActivityTBHeaderViewDelegate {
    func header(_ header: LActivityTBHeaderView, didSelectType type: Int) {
        if self.type == type {return}
        self.type = type
        listApi(1)
    }
}
