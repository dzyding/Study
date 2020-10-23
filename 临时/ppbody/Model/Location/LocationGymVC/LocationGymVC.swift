//
//  LocationGymVC.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGymVC: BaseVC {
    
    private let cid: String
    
    private var info: [String : Any] = [:]
    
    private var comments: [[String : Any]] = []
    
    private var gbList: [[String : Any]] = []
    
    private var ptExpList: [[String : Any]] = []
    
    private var recList: [[String : Any]] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectBtn: UIButton!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    /// titleView 上面占位用的
    @IBOutlet weak var placeHolderView: UIView!
    
    init(_ cid: String) {
        self.cid = cid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        clubDetailApi()
        tableView.dzy_registerCellNib(LGymEvaluateCell.self)
        tableView.dzy_registerCellNib(LGymPublicTbCell.self)
        tableView.dzy_registerCellNib(LocationGymCell.self)
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
    
    private func updateUI(_ info: [String : Any]) {
        self.info = info
        collectBtn.isSelected = info.intValue("isCollect") == 1
        titleLB.text = info.stringValue("name")
        
        let total = info.dicValue("comments")?
            .dicValue("page")?
            .intValue("totalNum") ?? 0
        comments = info.dicValue("comments")?.arrValue("list") ?? []
        evaluateHeader.updateUI(total)
        evaluateFooter.updateUI(total)
        let ptList = info.arrValue("ptList") ?? []
        coachView.updateUI(ptList)
        
        header.initUI(info)
        if let groupBuyList = info.arrValue("groupBuyList"),
            !groupBuyList.isEmpty
        {
            self.gbList = groupBuyList
            gbFooter.initUI(.groupBuy, count: groupBuyList.count)
        }
        if let expList = info.arrValue("lbsPTExpList"),
            !expList.isEmpty
        {
            self.ptExpList = expList
            ptExpFooter.initUI(.ptExp, count: expList.count)
        }
        if gbList.isEmpty,
            ptExpList.isEmpty,
            ptList.isEmpty
        {
            let dic: [String: String] = [
                "latitude" : LocationManager.locationManager.latitude,
                "longitude" : LocationManager.locationManager.longitude
            ]
            recommendListApi(dic)
        }else {
            recList = []
        }
        tableView.reloadData()
        tableView.isHidden = false
    }
    
//    MARK: - 更新视图
    private func update(_ section: Int, isOpen: Bool) {
        if isOpen {
            tableView.reloadData()
        }else {
            tableView.reloadSections(IndexSet(integer: section),
                                     with: .none)
            let indexPath = IndexPath(row: 0, section: section)
            tableView.scrollToRow(at: indexPath,
                                  at: .middle,
                                  animated: true)
        }
    }
    
//    MARK: - 地图跳转
    private func mapAction() {
        if let latitude = info.doubleValue("latitude"),
            let longitude = info.doubleValue("longitude"),
            let name = info.stringValue("name")
        {
            let vc = MapVC(name, latitude, lon: longitude)
            dzy_push(vc)
        }
    }

//    MARK: - 返回，分享，收藏
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
    }
    
    @IBAction func favAction(_ sender: UIButton) {
        collectClubApi(sender.isSelected ? "20" : "10") {
            sender.isSelected = !sender.isSelected
        }
    }
    
//    MARK: - 前往评价列表
    private func goEvaluateListAction() {
        guard let cid = info.stringValue("cid") else {
            ToolClass.showToast("错误的健身房信息", .Failure)
            return
        }
        let vc = LocationEvaluateListVC(cid)
        dzy_push(vc)
    }
    
//    MARK: - Api
    private func clubDetailApi() {
        let request = BaseRequest()
        request.url = BaseURL.ClubDetail
        request.setClubId(cid)
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let info = data?.dicValue("clubInfo") {
                self.updateUI(info)
            }
        }
    }
    
    private func collectClubApi(_ type: String, complete: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.CollectClub
        request.dic = ["type" : type]
        request.setClubId(cid)
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
    
    private func recommendListApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClubRecommend
        request.dic = dic
        request.setClubId(cid)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data?.arrValue("list") ?? []
            self.recList = list
            self.tableView.reloadData()
        }
    }
    
//    MARK: - 懒加载
    private lazy var header: LGymInfoView = {
        let infoView = LGymInfoView.initFromNib()
        infoView.delegate = self
        return infoView
    }()
    
    private lazy var gbHeader: LGymPublicHeader = {
        let view = LGymPublicHeader.initFromNib()
        view.updateUI(.groupBuy)
        return view
    }()
    
    private lazy var gbFooter: LGymPublicFooter = {
        let view = LGymPublicFooter.initFromNib()
        view.handler = { [weak self] isOpen in
            self?.update(1, isOpen: isOpen)
        }
        return view
    }()
    
    private lazy var ptExpHeader: LGymPublicHeader = {
        let view = LGymPublicHeader.initFromNib()
        view.updateUI(.ptExp)
        return view
    }()
    
    private lazy var ptExpFooter: LGymPublicFooter = {
        let view = LGymPublicFooter.initFromNib()
        view.handler = { [weak self] isOpen in
            self?.update(2, isOpen: isOpen)
        }
        return view
    }()
    
    private lazy var evaluateHeader: LocationEvaluateHeaderView = {
        let header = LocationEvaluateHeaderView.initFromNib()
        header.handler = { [weak self] in
            self?.goEvaluateListAction()
        }
        return header
    }()
    
    private lazy var evaluateFooter: LocationEvaluateFooterView = {
        let footer = LocationEvaluateFooterView.initFromNib()
        footer.handler = { [weak self] in
            self?.goEvaluateListAction()
        }
        return footer
    }()
    
    private lazy var coachView: LGymCoachView = {
        let view = LGymCoachView.initFromNib()
        view.initUI()
        view.delegate = self
        return view
    }()
    
    private lazy var recHeader = LocationRecHeaderView.initFromNib()
}

extension LocationGymVC: UIScrollViewDelegate {
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

extension LocationGymVC: UITableViewDelegate, UITableViewDataSource {
    
    /*
     1.
     header: 所有的健身房信息 footer: nil
     2.
     header: 团购头 footer: 团购尾
     3.
     header: 体验课头 footer: 体验课尾
     4.
     header: 评论头 footer: 评论尾
     5.
     header: 教练列表 footer: nil
     6.
     header: 为你推荐 footer: nil
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return gbFooter.isOpen ?
                gbList.count : min(2, gbList.count)
        case 2:
            return ptExpFooter.isOpen ?
                ptExpList.count : min(2, ptExpList.count)
        case 3:
            return comments.count
        case 5:
            return recList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            let cell = tableView
                .dzy_dequeueReusableCell(LGymPublicTbCell.self)
            cell?.updateUI(.groupBuy,
                           data: gbList[indexPath.row],
                           row: indexPath.row)
            cell?.btnHandler = nil
            return cell!
        case 2:
            let data = ptExpList[indexPath.row]
            let cell = tableView
                .dzy_dequeueReusableCell(LGymPublicTbCell.self)
            cell?.updateUI(.ptExp,
                           data: data,
                           row: indexPath.row)
            cell?.btnHandler = {
                data.intValue("id").flatMap({ [weak self] id in
                    let vc = LocationPtExpDetailVC(id)
                    self?.dzy_push(vc)
                })
            }
            return cell!
        case 3:
            let cell = tableView
                .dzy_dequeueReusableCell(LGymEvaluateCell.self)
            cell?.updateUI(comments[indexPath.row])
            return cell!
        case 5:
            let cell = tableView
                .dzy_dequeueReusableCell(LocationGymCell.self)
            cell?.updateUI(recList[indexPath.row])
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            gbList[indexPath.row].intValue("id").flatMap({
                let vc = LocationGBDetailVC($0)
                dzy_push(vc)
            })
        case 5:
            recList[indexPath.row].stringValue("cid").flatMap({
                let vc = LocationGymVC($0)
                dzy_push(vc)
            })
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1, 2:
            return 90
        case 3:
            return 300
        case 5:
            return 170
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return header
        case 1:
            return gbList.count == 0 ? nil : gbHeader
        case 2:
            return ptExpList.count == 0 ? nil : ptExpHeader
        case 3:
            return comments.count == 0 ? nil : evaluateHeader
        case 5:
            return recList.count == 0 ? nil : recHeader
        default:
            let ptList = info.arrValue("ptList") ?? []
            return ptList.count == 0 ? nil : coachView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 375
        case 1:
            return gbList.count == 0 ? 0.1 : 65.0
        case 2:
            return ptExpList.count == 0 ? 0.1 : 65.0
        case 3:
            return comments.count == 0 ? 0.1 : 50.0
        case 5:
            return recList.count == 0 ? 0.1 : 65.0
        default:
            let ptList = info.arrValue("ptList") ?? []
            return ptList.count == 0 ? 0.1 : 280
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 1:
            return gbList.count <= 2 ? nil : gbFooter
        case 2:
            return ptExpList.count <= 2 ? nil : ptExpFooter
        case 3:
            return comments.count == 0 ? nil : evaluateFooter
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return gbList.count <= 2 ? 0.1 : 36.0
        case 2:
            return ptExpList.count <= 2 ? 0.1 : 36.0
        case 3:
            return comments.count == 0 ? 0.1 : 50.0
        case 4:
            let ptList = info.arrValue("ptList") ?? []
            return ptList.count == 0 ? 0.1 : 50.0
        default:
            return 0.1
        }
    }
}

extension LocationGymVC: LGymInfoViewDelegate {
    func infoView(_ infoView: LGymInfoView, didSelectImg index: Int) {
        
    }
    
    func infoView(_ infoView: LGymInfoView, didClickMapBtn btn: UIButton) {
        mapAction()
    }
    
    func infoView(_ infoView: LGymInfoView, didClickTel btn: UIButton) {
        guard let tel = info.stringValue("tel") else {return}
        let arr = tel.components(separatedBy: [",", "，", " "])
        guard arr.count > 0 else {
            ToolClass.showToast("无可用手机号", .Failure)
            return
        }
        let textColor = dzy_HexColor(0x333333)
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .light
        }
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        cancelAction.setTextColor(textColor)
        alert.addAction(cancelAction)
        arr.forEach { (code) in
            guard let url = URL(string: "tel:" + code)
                else {return}
            let codeAction = UIAlertAction(
                title: code,
                style:
                .default)
            { (_) in
                UIApplication.shared.open(url)
            }
            codeAction.setTextColor(textColor)
            alert.addAction(codeAction)
        }
        present(alert, animated: true, completion: nil)
    }
}

extension LocationGymVC: LGymCoachViewDelegate {
    func coachView(_ coachView: LGymCoachView,
                   didClickCoach coach: [String : Any]) {
        guard let uid = coach.stringValue("uid") else {return}
        let vc = PersonalPageVC()
        vc.uid = uid
        dzy_push(vc)
    }
}
