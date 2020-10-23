//
//  LocationPtExpDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationPtExpDetailVC: BaseVC, AttPriceProtocol, ShareSaveImageProtocol {
    /// 分享来源
    var fpp: String?
    
    private let ptExpId: Int
    
    private var ptExpDetail: [String : Any] = [:]
    
    private var comments: [[String : Any]] = []
    
    @IBOutlet weak var collectBtn: UIButton!
    
    @IBOutlet weak var placeHolderView: UIView!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var priceLB: UILabel!
    /// ￥498
    @IBOutlet weak var dpriceLB: UILabel!
    
    init(_ ptExpId: Int) {
        self.ptExpId = ptExpId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.dzy_registerCellNib(LGymEvaluateCell.self)
        ptExpDetailApi()
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
    
//    MARK: - 返回，收藏，分享
    
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        func showShareView(_ url: String) {
            let sview = SharePlatformView.instanceFromNib()
            sview.frame = ScreenBounds
            sview.ptExpUpdateUI(ptExpDetail, url: url)
            sview.initUI(.lbs_exp)
            sview.saveHandler = { [weak self] image in
                self?.showSaveAlert(image)
            }
            UIApplication.shared.keyWindow?.addSubview(sview)
        }
        shareCodeApi { (url) in
            showShareView(url)
        }
    }
    
    @IBAction func collectAction(_ sender: UIButton) {
        collectClubGoodApi(sender.isSelected ? "20" : "10") {
            sender.isSelected = !sender.isSelected
        }
    }
    
//    MARK - 前往评论列表
    private func goEvaluateListAction() {
        guard let cid = ptExpDetail.stringValue("cid") else {
            return
        }
        let dic = [
            "lbsGoodId" : "\(ptExpId)",
            "type" : "20",
        ]
        let vc = LocationEvaluateListVC(dic, cid: cid)
        dzy_push(vc)
    }
    
    //    MARK: - 预约
    @IBAction func reserveAction(_ sender: UIButton) {
        let vc = LPtExpReserveCoachVC(ptExpDetail)
        vc.fpp = fpp
        dzy_push(vc)
    }
    
    //    MARK: - 更新视图
    func updateUI(_ data: [String : Any]) {
        ptExpDetail = data
        comments = data.dicValue("comments")?.arrValue("list") ?? []
        let totalCount = data.dicValue("comments")?
            .dicValue("page")?
            .intValue("totalNum") ?? 0
        evaluateHeader.updateUI(totalCount)
        evaluateFooter.updateUI(totalCount)
        
        collectBtn.isSelected = data.intValue("isCollect") == 1
        
        let price = data.doubleValue("presentPrice") ?? 0
        priceLB.attributedText = attPriceStr(price)
        let dprice = data.doubleValue("originPrice") ?? 0
        dpriceLB.text = "￥\(dprice.decimalStr)"
        titleLB.text = data.stringValue("name")
        infoHeader.initUI(data)
        
        let duration = data.intValue("duration") ?? 0
        let time = data.stringValue("orderTime") ?? ""
        let ser = data.stringValue("provideServices") ?? ""
        let refund = data.intValue("refundTime") ?? 0
        let expObject = data.stringValue("expObject") ?? ""
        let itemsInfo: [(String, String, UIColor)] = [
            ("体验时长", "\(duration)分钟", .white),
            ("体验次数", "1次", .white),
            ("可约时间", dealTheOrderTime(time), YellowMainColor),
            ("提供服务", ser, .white),
            ("退款条件", "到达预约时间前\(refund)小时可退", .white),
            ("体验对象", expObject, .white)
        ]
        noticeFooter.twoLBColorInitUI(itemsInfo, title: "体验须知")
        
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    private func dealTheOrderTime(_ str: String) -> String {
        let arr = str.components(separatedBy: " ")
        guard arr.count == 2 else {
            ToolClass.showToast("可预约时间格式错误", .Failure)
            return ""
        }
        let numArr = arr[0]
            .components(separatedBy: [",", "，"])
            .compactMap({Int($0)})
        var result = ""
        var tempArr: [Int] = []
        numArr.forEach { (num) in
            // 连着的就加入数组
            if let last = tempArr.last,
                (last + 1) == num
            {
                tempArr.append(num)
            // 为空就加入数组
            }else if tempArr.count == 0 {
                tempArr.append(num)
            }else {
                // 讲数组的数据显示出来，并把当前的加入到数组
                var tempStr = ""
                if tempArr.count >= 3 {
                    let start = strWeekDay(tempArr.first ?? 0)
                    let end = strWeekDay(tempArr.last ?? 0)
                    tempStr = "\(start)至\(end)"
                }else if tempArr.count > 0 {
                    tempStr = tempArr
                        .map({strWeekDay($0)})
                        .joined(separator: "，")
                }
                tempArr.removeAll()
                tempArr.append(num)
                if result.count > 0 {
                    result += ("，" + tempStr)
                }else {
                    result += tempStr
                }
            }
        }
        // 判断数组中是否还有数据
        if tempArr.count > 0 {
            var tempStr = ""
            if tempArr.count >= 3 {
                let start = strWeekDay(tempArr.first ?? 0)
                let end = strWeekDay(tempArr.last ?? 0)
                tempStr = "\(start)至\(end)"
            }else {
                tempStr = tempArr
                    .map({strWeekDay($0)})
                    .joined(separator: "，")
            }
            if result.count > 0 {
                result += ("，" + tempStr)
            }else {
                result += tempStr
            }
        }
        return result + " " + arr[1]
    }
    
    private func strWeekDay(_ intValue: Int) -> String {
        switch intValue {
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        default:
            return "周日"
        }
    }
    
//    MARK: - Api
    private func ptExpDetailApi() {
        let request = BaseRequest()
        request.url = BaseURL.PtExpDetail
        request.dic = ["ptExpId" : "\(ptExpId)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("ptExpInfo") {
                self.updateUI(data)
            }
        }
    }
    
    private func collectClubGoodApi(_ type: String, complete: @escaping ()->()) {
        let request = BaseRequest()
        request.url = BaseURL.CollectClubGood
        request.dic = [
            "lbsGoodId" : "\(ptExpId)",
            "lbsGoodType" : "20",
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
            "type" : "11",
            "goodsId" : "\(ptExpId)",
            "title" : ptExpDetail.stringValue("name") ?? ""
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
    private lazy var infoHeader: LocationPtExpDetailHeaderView = {
        let view = LocationPtExpDetailHeaderView.initFromNib()
        return view
    }()
    
    private lazy var noticeFooter = LocationPublicInfoListView.initFromNib()
    
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
}

extension LocationPtExpDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : comments.count
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
        if section == 0 {
            return infoHeader
        }else {
            return comments.count == 0 ? nil : evaluateHeader
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 680
        }else {
            return comments.count == 0 ? 0.1 : 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 250.0
        }else {
            return comments.count == 0 ? 0.1 : 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return noticeFooter
        }else {
            return comments.count == 0 ? nil : evaluateFooter
        }
    }
}

extension LocationPtExpDetailVC: UIScrollViewDelegate {
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
