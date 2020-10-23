//
//  LocationGBDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGBDetailVC: BaseVC, AttPriceProtocol, ShareSaveImageProtocol, ActivityTimeProtocol {
    /// 通用的Id
    private let gbId: Int
    /// 来自分享
    var fpp: String?
    /// 收藏按钮
    @IBOutlet weak var collectBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    /// 假 naviBar
    @IBOutlet weak var titleView: UIView!
    /// navaibar 上面的占位图
    @IBOutlet weak var placeHolderView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    /// 团购价
    @IBOutlet weak var groupPriceLB: UILabel!
    /// 总价
    @IBOutlet weak var totalPriceLB: UILabel!
    /// 详细
    private var gbDetail: [String : Any] = [:]
    
    private var comments: [[String : Any]] = []
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    init(_ gbId: Int) {
        self.gbId = gbId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        initUI()
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
    
//    MARK: - 返回，分享，收藏，支付
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        func showShareView(_ url: String) {
            let sview = SharePlatformView.instanceFromNib()
            sview.frame = ScreenBounds
            sview.gbUpdateUI(gbDetail, url: url)
            sview.initUI(.lbs_gb)
            sview.saveHandler = { [weak self] image in
                self?.showSaveAlert(image)
            }
            UIApplication.shared.keyWindow?.addSubview(sview)
        }
        shareCodeApi { (url) in
            showShareView(url)
        }
    }
    
    @IBAction func favAction(_ sender: UIButton) {
        collectClubGoodApi(sender.isSelected ? "20" : "10") {
            sender.isSelected = !sender.isSelected
        }
    }
    
    @IBAction func payAction(_ sender: UIButton) {
        let vc = LocationOrderSubmitVC(gbDetail)
        vc.fpp = fpp
        dzy_push(vc)
    }
    
//    MARK: - 前往评论列表界面
    private func goEvaluateListAction() {
        guard let cid = gbDetail.stringValue("cid") else {
            ToolClass.showToast("数据缺失", .Failure)
            return
        }
        let dic = [
            "lbsGoodId" : "\(gbId)",
            "type" : "10"
        ]
        let vc = LocationEvaluateListVC(dic, cid: cid)
        dzy_push(vc)
    }
    
//    MARK: - 初始化界面，更新界面
    private func initUI() {
        tableView.dzy_registerCellNib(LGymEvaluateCell.self)
        groupBuyDetailApi()
    }
    
    private func updateUI(_ data: [String : Any]) {
        gbDetail = data
        comments = data.dicValue("comments")?.arrValue("list") ?? []
        collectBtn.isSelected = data.intValue("isCollect") == 1
        titleLB.text = data.stringValue("name")
        totalPriceLB.text = "￥\(data.doubleValue("originPrice"), optStyle: .price)"
        if isActivity,
            let aprice = data.doubleValue("activityPrice"),
            aprice > 0
        {
            groupPriceLB.attributedText = attPriceStr(aprice)
        }else {
            let price = data.doubleValue("presentPrice") ?? 0
            groupPriceLB.attributedText = attPriceStr(price)
        }
        
        let totalCount = data.dicValue("comments")?
            .dicValue("page")?
            .intValue("totalNum") ?? 0
        header.updateUI(data)
        footer.updateUI(totalCount)
        tableView.reloadData()
        tableView.isHidden = false
    }
    
//    MARK: - Api
    private func groupBuyDetailApi() {
        let request = BaseRequest()
        request.url = BaseURL.GroupBuyDetail
        request.dic = ["groupBuyId" : "\(gbId)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.updateUI(data?.dicValue("groupBuyInfo") ?? [:])
        }
    }
    
    private func collectClubGoodApi(_ type: String, complete: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.CollectClubGood
        request.dic = [
            "lbsGoodId" : "\(gbId)",
            "lbsGoodType" : "10",
            "type" : type
        ]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                complete()
            }
        }
    }
    
    private func shareCodeApi(_ complete: @escaping (String)->()) {
        let request = BaseRequest()
        request.url = BaseURL.ShareCode
        request.dic = [
            "type" : "10",
            "goodsId" : "\(gbId)",
            "title" : gbDetail.stringValue("name") ?? ""
        ]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let url = data?.stringValue("url") {
                complete(url)
            }else {
                ToolClass.showToast("生成分享指令失败", .Failure)
            }
        }
    }
    
//    MARK: - 懒加载
    private lazy var header: LocationGBDetailHeaderView = {
        let header = LocationGBDetailHeaderView.initFromNib()
        header.handler = { [weak self] in
            self?.goEvaluateListAction()
        }
        return header
    }()
    
    private lazy var footer: LocationEvaluateFooterView = {
        let footer = LocationEvaluateFooterView.initFromNib()
        footer.handler = { [weak self] in
            self?.goEvaluateListAction()
        }
        return footer
    }()
}

extension LocationGBDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LGymEvaluateCell.self)
        cell?.updateUI(comments[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 800
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return comments.count == 0 ? 0.1 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return comments.count == 0 ? nil : footer
    }
}

extension LocationGBDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.dzy_ofy >= 250 {
            titleView.backgroundColor = dzy_HexColor(0x232327)
            titleLB.isHidden = false
            placeHolderView.isHidden = false
        }else {
            titleView.backgroundColor = .clear
            titleLB.isHidden = true
            placeHolderView.isHidden = true
        }
    }
}
