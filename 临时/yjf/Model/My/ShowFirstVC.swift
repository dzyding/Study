//
//  ShowFirstVC.swift
//  YJF
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class ShowFirstVC: BasePageVC, ObserverVCProtocol, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    var observers: [[Any?]] = []

    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    /// 房源列表
    private var houses: [[String : Any]] = []
    /// 当前房源的优显状态
    private var isTop: Bool = false
    
    private var houseId: Int?
    
    @IBOutlet weak var isTopView: UIView!
    
    @IBOutlet weak var notTopView: UIView!
    
    @IBOutlet weak var memoLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "房源优显"
        tableView.dzy_registerCellNib(ShowFirstCell.self)
        topListApi(false)
        
        registObservers([PublicConfig.Notice_PaySuccess]) { [weak self] in
            self?.topListApi(true)
        }
        registObservers([PublicConfig.Notice_TopRefundSuccess]) { [weak self] in
            self?.topDetailApi()
            self?.listApi(1)
        }
        listAddHeader()
    }
    
    deinit {
        dzy_log("销毁")
        deinitObservers()
    }
    
    //    MARK: - 列表请求成功
    private func dealWithTheData(_ isRefresh: Bool, data: [String : Any]?) {
        houses = data?.arrValue("list") ?? []
        if isRefresh {
            let data = houses.filter({$0.intValue("id") == houseId}).first
            updateHouseMsg(data, index: 0)
        }else {
            updateHouseMsg(houses.first, index: 0)
        }
        emptyView.isHidden = houses.count > 0
    }
    
    //    MARK: - 初始化视图
    private func updateHouseMsg(_ data: [String : Any]?, index: Int) {
        if let house = data {
            memoLB.isHidden = true
            showHeader.updateTitle(house.stringValue("houseTitle"), index: index)
            houseId = house.intValue("id")
            topDetailApi()
            listApi(1)
        }
    }
    
    //    MARK: - 根据选择房源刷新界面
    private func updateTopView(_ data: [String : Any]) {
        isTop = data.intValue("isTop") == 1
        updateBottomTypeView()
        showHeader.updateUI(data)
    }
    
    private func updateBottomTypeView() {
        if isTop {
            isTopView.superview?.bringSubviewToFront(isTopView)
        }else {
            notTopView.superview?.bringSubviewToFront(notTopView)
        }
    }
    
    //    MARK: - 供 popPicker 使用
    private func getPoint(_ sender: UIButton) -> CGPoint {
        let rect = sender.superview?.convert(sender.frame, to: KEY_WINDOW) ?? .zero
        let point = CGPoint(x: rect.maxX - 7.0, y: rect.maxY)
        return point
    }
    
    //    MARK: - 开始优显
    @IBAction func startAction(_ sender: UIButton) {
        ZKProgressHUD.show()
        startOrTopApi { [weak self] (result, error) in
            ZKProgressHUD.dismiss()
            if result {
                self?.memoLB.isHidden = true
                self?.topDetailApi()
                self?.listApi(1)
            }else {
                self?.memoLB.isHidden = false
                self?.memoLB.text = error
            }
        }
    }
    
    //    MARK: - 退余额
    @IBAction func refundAction(_ sender: UIButton) {
        guard let houseId = houseId else {
            showMessage("错误的房源信息")
            return
        }
        let vc = TakeMoneySecondVC(.topRefund(houseId: houseId))
        dzy_push(vc)
    }
    
    //    MARK: - 懒加载
    private lazy var showHeader: ShowFirstHeaderView = {
        let header = ShowFirstHeaderView
            .initFromNib(ShowFirstHeaderView.self)
        header.delegate = self
        return header
    }()
    
    /// 弹出框
    lazy var picker: YJFPickerView = {
        let pickerView = YJFPickerView()
        pickerView.delegate = self
        return pickerView
    }()
    
    //    MARK: - api
    /// 优显列表
    private func topListApi(_ isRefresh: Bool) {
        let request = BaseRequest()
        request.url = BaseURL.topList
        request.isUser = true
        request.dzy_start { [weak self] (data, _) in
            self?.dealWithTheData(isRefresh, data: data)
        }
    }
    
    /// 优显详情
    private func topDetailApi() {
        guard let houseId = houseId else {
            showMessage("错误的房源信息")
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.topDetail
        request.dic = ["houseId" : houseId]
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            self.updateTopView(data ?? [:])
        }
    }
    
    /// 暂停/开始
    private func startOrTopApi(_ result: @escaping (Bool, String?) -> ()) {
        guard let houseId = houseId else {
            showMessage("错误的房源信息")
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.topStopOrStart
        request.dic = ["houseId" : houseId]
        request.start { (data, error) in
            result(data != nil, error)
        }
    }
    
    // 详情
    func listApi(_ page: Int) {
        guard let houseId = houseId else {
            showMessage("错误的房源信息")
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.topDetailList
        request.dic = ["houseId" : houseId]
        request.page = [page, 10]
        request.start { (data, error) in
            self.pageOperation(data: data)
        }
    }
}

extension ShowFirstVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(ShowFirstCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return showHeader
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension ShowFirstVC: ShowFirstHeaderViewDelegate {
    
    func header(_ header: ShowFirstHeaderView, didClickPickerBtn btn: UIButton) {
        guard houses.count > 0 else {
            showMessage("暂无数据，若是网络问题，请待会再试。")
            header.closeAction()
            return
        }
        picker.updateUI(houses, point: getPoint(btn), type: .house)
        picker.show()
    }
    
    //    MAKR: - 充值
    func header(_ header: ShowFirstHeaderView, didClickRechargeBtn btn: UIButton) {
        if let houseId = houseId {
            let vc = ShowFirstRechargeVC(houseId)
            dzy_push(vc)
        }else {
            showMessage("请选择需优显的房源")
        }
    }
}

extension ShowFirstVC: YJFPickerViewDelegate {
    func pickerView(_ pickerView: YJFPickerView, didSelect data: [String : Any], index: Int) {
        updateHouseMsg(data, index: index)
        showHeader.closeAction()
    }
    
    func didDismiss(_ pickerView: YJFPickerView) {
        showHeader.closeAction()
    }
}
