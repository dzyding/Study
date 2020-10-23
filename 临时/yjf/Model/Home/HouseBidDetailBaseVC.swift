//
//  HouseBidDetailBaseVC.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

//swiftlint:disable type_body_length file_length
class HouseBidDetailBaseVC: BasePageVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    /// 卖家报价数量
    private let sellerPriceCount = PublicConfig
        .sysConfigIntValue(.house_sellPriceNum) ?? 2
    
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var bottomBg: UIView!
    
    @IBOutlet private weak var tableViewBottomLC: NSLayoutConstraint!
    /// 卖家报价
    private var sellList: [[String : Any]] = []
    /// 买家报价
    private var buyList: [[String : Any]] = []
    /// 卖家是否缴纳保证金
    private var sellerDeposit: Bool = false
    ///
    private var house: [String : Any] = [:]
    
    var identity: Identity = .buyer {
        didSet {
            // 详情页设置了 identity 以后再加载数据
            listApi(1)
        }
    }
    
    private let houseId: Int
    
    private var observer: Any?
    
    private var orderMsg: [String : Any]?
    
    private var detailVC: HouseDetailBaseVC? {
        return parent?.children.first as? HouseDetailBaseVC
    }
    
    private var isDeal: Bool {
        if let vc = parent as? HouseDetailVC {
            return vc.isDeal
        }else {
            return false
        }
    }
    
    private var isUndo: Bool {
        if let vc = parent as? HouseDetailVC {
            return vc.isUndo
        }else {
            return false
        }
    }
    
    init(_ houseId: Int) {
        self.houseId = houseId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        listAddHeader(false)
        observerFunc()
    }
    
    private func observerFunc() {
        [
            PublicConfig.Notice_AddPriceSuccess,
            PublicConfig.Notice_UndoPriceSuccess
        ].forEach { (name) in
            observer = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: nil
            ) { [weak self] (_) in
                self?.listApi(1)
            }
        }
    }
    
    private func initSubViews() {
        tableView.dzy_registerCellNib(HouseBidDetailSellCell.self)
        tableView.dzy_registerCellNib(HouseBidDetailBuyCell.self)
    }
    
    private func updateUI(_ data: [String : Any]) {
        tableView.srf_endRefreshing()
        guard let page = data["page"] as? [String : Any] else {return}
        var listData = data.arrValue("list") ?? []
        if identity == .seller {
            (0..<listData.count).forEach { (index) in
                listData[index].updateValue(false, forKey: Public_isSelected)
            }
        }
        self.page = page
        if currentPage == 1 {
            buyList.removeAll()
        }
        if currentPage! < totalPage! {
            tableView.srf_canLoadMore(true)
        }else {
            tableView.srf_canLoadMore(false)
        }
        sellerDeposit = data.intValue("sellCashType") == 1
        sellList = data.arrValue("houseSell") ?? []
        buyList.append(contentsOf: listData)
        tableView.reloadData()
        
        if currentPage == 1 { //由于没有下啦刷新，相当于只执行一次
            if isDeal,
                let record = data.dicValue("userBuyHouseRecord") {
                orderMsg = record
            }
            buyHeader.updateNum(page.intValue("totalNum") ?? 0)
            initBottomView(data)
        }
    }
    
    //    MARK: - 收藏按钮
    func updateHouseMsg(_ data: [String : Any]) {
        house = data.dicValue("house") ?? [:]
        biddedBottomView.setType(.bid,
                                 identity: identity,
                                 data: data,
                                 isDeal: isDeal)
        normalBottomView.updateUI(data)
    }
    
    //    MARK: - 收藏按钮的状态
    func updateFavBtn(_ isSelected: Bool) {
        biddedBottomView.updateFavBtn(isSelected)
        normalBottomView.updateFavBtn(isSelected)
    }
    
    //    MARK: - 初始化 bottomView
    private func initBottomView(_ data: [String : Any]) {
        if isDeal || isUndo{
            tableViewBottomLC.constant = 0
            return
        }
        if identity == .buyer {
            let dic = data.dicValue("isBuy")
            if (dic?.count ?? 0) > 0 {
                // 已经竞买
                if normalBottomView.superview != nil {
                    normalBottomView.removeFromSuperview()
                }
                if biddedBottomView.superview == nil {
                    bottomBg.addSubview(biddedBottomView)
                    biddedBottomView.snp.makeConstraints { (make) in
                        make.edges.equalTo(bottomBg)
                            .inset(UIEdgeInsets.zero)
                    }
                }
            }else {
                // 尚未竞买
                if biddedBottomView.superview != nil {
                    biddedBottomView.removeFromSuperview()
                }
                if normalBottomView.superview == nil {
                    bottomBg.addSubview(normalBottomView)
                    normalBottomView.snp.makeConstraints { (make) in
                        make.edges.equalTo(bottomBg)
                            .inset(UIEdgeInsets.zero)
                    }
                }
            }
        }else {
            tableViewBottomLC.constant = 0
        }
    }
    
    //    MARK: - 竞价或者成交前的检查
    private func checkDealResult(
        _ data: [String : Any]?,
        error: String?,
        isDeal: Bool,
        bidMsg: [String : Any]?,
        dealMsg: [String : Any]?
    ) {
        if error == EspecialError && isDeal { // status = 4 只有成交的时候需要判断
            let isPay = data?.dicValue("data")?.intValue("isPay") ?? 0
            if isPay == 1 && identity == .buyer {
                let vc = PayBuyDepositVC(.notice("请先缴纳交易保证金"))
                dzy_push(vc)
            }else if isPay == 2 && identity == .seller {
                let vc = PaySellDepositVC(.notice("请先缴纳交易保证金"))
                dzy_push(vc)
            }else {
                let msg = data?.stringValue("msg") ?? ""
                showMessage(msg)
            }
        }else {
            var isBook = false
            if error == EspecialError {
                isBook = data?.dicValue("data")?.intValue("isBook") == 1
            }else {
                isBook = data?.intValue("isBook") == 1
            }
            if isDeal {
                dealNextAction(dealMsg ?? [:], isBook: isBook)
            }else {
                bidNextAction(bidMsg, isBooK: isBook)
            }
        }
    }
    
    //    MARK: - 检查身份
    private func checkIdentity(_ complete: @escaping ()->()) {
        if identity == .seller && IDENTITY == .buyer {
            let alert = dzy_normalAlert("提示", msg: "进行该操作，需要切换到卖家身份", sureClick: { (_) in
                IDENTITY = .seller
                PublicFunc.changeIdentityApi(20)
                complete()
            }, cancelClick: nil)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }else if identity == .buyer && IDENTITY == .seller {
            let alert = dzy_normalAlert("提示", msg: "进行该操作，需要切换到买家身份", sureClick: { (_) in
                IDENTITY = .buyer
                PublicFunc.changeIdentityApi(10)
                complete()
            }, cancelClick: nil)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }else {
            complete()
        }
    }
    
    //    MARK: - 前往报价界面
    private func bidAction(_ data: [String : Any]? = nil) {
        checkIdentity { [unowned self] in
            self.dealCheckApi(nil, isDeal: false, bidMsg: data)
        }
    }
    
    private func bidNextAction(_ data: [String : Any]?, isBooK: Bool) {
        guard let houseId = house.intValue("id") else {return}
        let bidvc = BidVC(house)
        bidvc.data = data
        switch identity {
        case .buyer:
            if isBooK {
                dzy_push(bidvc)
            }else {
                let handler: ([String : Any]?) -> () = { [weak self] data in
                    ZKProgressHUD.dismiss()
                    let restrictBuy = data?
                        .dicValue("cityConfig")?
                        .stringValue("restrictBuy") ?? "N"
                    if restrictBuy == "Y",
                        self?.house.stringValue("purpose") == "住宅"
                    {
                        let vc = DealAffirmVC(houseId)
                        vc.bidVC = bidvc
                        self?.dzy_push(vc)
                    }else {
                        self?.dzy_push(bidvc)
                    }
                }
                ZKProgressHUD.show()
                PublicConfig.updateCityConfig(handler)
            }
        case .seller:
            dzy_push(bidvc)
        }
    }
    
    //    MARK: - 前往成交界面
    private func dealAction(_ data: [String : Any]) {
        guard let totalId = data.intValue("id") else {return}
        checkIdentity { [unowned self] in
            self.dealCheckApi(totalId, isDeal: true, dealMsg: data)
        }
    }
    
    private func dealNextAction(_ data: [String : Any], isBook: Bool) {
        let vc = DealVC(house, data: data, isBook: isBook)
        dzy_push(vc)
    }
    
    //    MARK: api
    func listApi(_ page: Int) {
        let num = PublicConfig.sysConfigIntValue(.house_buyPriceNum) ?? 10
        let request = BaseRequest()
        request.url = BaseURL.bidDetail
        request.dic = [
            "houseId" : houseId,
            "city" : RegionManager.city()
        ]
        request.page = [page, num]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.updateUI(data ?? [:])
        }
    }
    
    /// 收藏
    private func collectApi() {
        let request = BaseRequest()
        request.url = BaseURL.collectHouse
        request.dic = ["houseId" : houseId]
        request.isUser = true
        request.start { (_, _) in
            
        }
    }
    
    /// 成交前的检查
    private func dealCheckApi(
        _ totalId: Int?,
        isDeal: Bool,
        bidMsg: [String : Any]? = nil,
        dealMsg: [String : Any]? = nil
    ) {
        var dic: [String : Any] = [
            "houseId" : houseId
        ]
        if let totalId = totalId {
            dic["totalId"] = totalId
        }
        let request = BaseRequest()
        request.url = BaseURL.dealCheck
        request.dic = dic
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, error) in
            ZKProgressHUD.dismiss()
            guard data != nil else {return}
            self.checkDealResult(
                data,
                error: error,
                isDeal: isDeal,
                bidMsg: bidMsg,
                dealMsg: dealMsg
            )
        }
    }
    
    //    MARK: - 懒加载
    /// 竞卖报价 / 卖方报价
    lazy var sellHeader: HouseBidDetailSellHeader = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50.0)
        let header = HouseBidDetailSellHeader(frame: frame)
        return header
    }()
    
    /// 空分割线
    lazy var emptyFooter: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10))
        footer.backgroundColor = dzy_HexColor(0xF5F5F5)
        return footer
    }()
    
    /// 添加报价的底部
    lazy var sellFooter: HouseBidDetailAddSellerPriceView = {
        let footer = HouseBidDetailAddSellerPriceView
                .initFromNib(HouseBidDetailAddSellerPriceView.self)
        footer.delegate = self
        return footer
    }()
    
    /// 竞买头
    lazy var buyHeader: HouseBidDetailBuyHeader = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50.0)
        let header = HouseBidDetailBuyHeader(frame: frame)
        return header
    }()
    
    /// 底部视图 (已经竞买)
    lazy var biddedBottomView: HouseDetailBottomView = {
        let bottom = HouseDetailBottomView
            .initFromNib(HouseDetailBottomView.self)
        bottom.delegate = self
        bottom.layer.shadowColor = UIColor.gray.cgColor
        bottom.layer.shadowRadius = 3
        bottom.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottom.layer.shadowOpacity = 0.2
        bottom.isUserInteractionEnabled = !(isDeal || isUndo)
        return bottom
    }()
    
    /// 底部视图 (未竞买)
    lazy var normalBottomView: HouseBidDetailBuyBottomView = {
        let bottom = HouseBidDetailBuyBottomView
                    .initFromNib(HouseBidDetailBuyBottomView.self)
        bottom.delegate = self
        bottom.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 70.0)
        bottom.layer.shadowColor = UIColor.gray.cgColor
        bottom.layer.shadowRadius = 3
        bottom.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottom.layer.shadowOpacity = 0.2
        bottom.isUserInteractionEnabled = !(isDeal || isUndo)
        return bottom
    }()
}

extension HouseBidDetailBaseVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sellCount = min(sellList.count, sellerPriceCount)
        return section == 0 ? sellCount : buyList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 90 : 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseBidDetailSellCell.self)
            cell?.delegate = self
            cell?.updateUI(
                identity,
                data: sellList[indexPath.row],
                isDeposit: sellerDeposit,
                orderMsg: orderMsg
            )
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseBidDetailBuyCell.self)
            cell?.updateUI(
                indexPath,
                identity: identity,
                data: buyList[indexPath.row],
                orderMsg: orderMsg
            )
            cell?.delegate = self
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return sellHeader
        }else {
            return buyHeader
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if identity == .buyer {
                return 10
            }else {
                return (sellList.count < sellerPriceCount && !(isDeal || isUndo)) ? 110 : 10
            }
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if identity == .buyer {
                return emptyFooter
            }else {
                let count = sellList.count
                if count < sellerPriceCount && !(isDeal || isUndo) {
                    sellFooter.updateUI(count == 0)
                    return sellFooter
                }else {
                    return emptyFooter
                }
            }
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDeal || isUndo {return}
        if identity == .seller && indexPath.section == 1 {
            (0..<buyList.count).forEach { (index) in
                buyList[index].updateValue(false, forKey: Public_isSelected)
            }
            buyList[indexPath.row].updateValue(true, forKey: Public_isSelected)
            tableView.reloadData()
        }
    }
}

extension HouseBidDetailBaseVC: HouseDetailBottomViewDelegate, HouseBidDetailBuyBottomViewDelegate {
    /// 收藏
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectFaviBtn btn: UIButton) {
        collectApi()
        detailVC?.updateFaviBtn(btn.isSelected)
    }
    
    // MARK: - 买家撤销报价
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectLeftBtn btn: UIButton)
    {
        if let id = buyList
            .filter({$0.intValue("userId") == DataManager.getUserId()})
            .first?
            .intValue("id")
        {
            let dic = ["idList" : ToolClass.toJSONString(dict: [id])]
            checkIdentity { [weak self] in
                DataManager.saveUndoMsg(dic)
                let vc = CertificationVC()
                self?.dzy_push(vc)
            }
        }
    }
    
    /// 修改报价
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectRightBtn btn: UIButton) {
        let data = buyList
            .filter({$0.intValue("userId") == DataManager.getUserId()})
            .first
        bidAction(data)
    }
    
    /// 收藏
    func bidBottomView(_ bottomView: HouseBidDetailBuyBottomView, didSelectFaviBtn btn: UIButton) {
        collectApi()
        detailVC?.updateFaviBtn(btn.isSelected)
    }
    
    /// 竞买 出价 (买方)
    func bidBottomView(_ bottomView: HouseBidDetailBuyBottomView, didSelectBidBtn btn: UIButton) {
        bidAction()
    }
}

extension HouseBidDetailBaseVC: HouseBidDetailSellCellDelegate {
    /// 成交(买方)
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectDealBtn btn: UIButton, data: [String : Any]) {
        dealAction(data)
    }
    
    /// 修改报价(卖方)
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectEditBtn btn: UIButton, data: [String : Any]) {
        bidAction(data)
    }
    
    //MARK: - 卖家撤销报价
    func sellCell(_ sellCell: HouseBidDetailSellCell, didSelectDeleteBtn btn: UIButton, data: [String : Any]) {
        if let id = data.intValue("id") {
            let dic = [
                "sellId" : id,
                "houseId" : houseId
            ]
            checkIdentity { [weak self] in
                DataManager.saveUndoMsg(dic)
                let vc = CertificationVC()
                self?.dzy_push(vc)
            }
        }
    }
}

extension HouseBidDetailBaseVC: HouseBidDetailBuyCellDelegate {
    /// 成交(卖方)
    func buyCell(_ buyCell: HouseBidDetailBuyCell, didSelectSureBtn btn: UIButton, data: [String : Any]) {
        dealAction(data)
    }
}

extension HouseBidDetailBaseVC: HouseBidDetailAddSellerPriceViewDelegate {
    func pirceView(_ priceView: HouseBidDetailAddSellerPriceView, didSelectAddPriceBtn btn: UIButton) {
        bidAction()
    }
}
