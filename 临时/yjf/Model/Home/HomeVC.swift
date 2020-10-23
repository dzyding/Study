//
//  HomeVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

//swiftlint:disable file_length type_body_length
class HomeVC: BasePageVC, BaseRequestProtocol, TrainNextJumpProtocol, JumpHouseDetailProtocol, CzzdJumpProtocol, ObserverVCProtocol
{
    var re_listView: UIScrollView {
        return tableView
    }
    
    var observers: [[Any?]] = []
    
    private let tableHeaderH: CGFloat = 300.0
    
    private let sectionHeaderH: CGFloat = 45.0
    /// 顶部的假 naviBar 背景占位图
    @IBOutlet weak var topBgView: UIView!
    /// 顶部的假 naviBar 高度
    @IBOutlet weak var topViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    /// 添加房源
    @IBOutlet weak var addHouseBtn: UIButton!
    /// 提示视图 （保证金）
    @IBOutlet weak var memoView: UIView!
    /// 提示内容
    @IBOutlet weak var memoLB: UILabel!
    
    /// 是否 present 到了流程培训界面
    private var isPresentTrain = false
    /// 当前城市
    private var city = DataManager.user()?.stringValue("city") ?? RegionManager.city()
    
    private var bannerList: [[String : Any]] = []
    
    private var timer: Timer? = nil
    
    // ***** 筛选相关
    /// 地区
    var district: String?
    /// 居室
    var roomNum: [String]?
    /// 面积
    var area: (Int, Int)?
    var areaStr: String?
    /// 价格
    var price: (Int, Int)?
    var priceStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIsInHouseApi()
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(HouseListNormalCell.self)
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
        setTopView()
        listAddHeader()
        listApi(1)
        addOberverFunc()
        initUser()
        bannerListApi()
        cityListApi()
        // 存储当前的 host，再下次登录的时候判断是否相同
        DataManager.saveHost(HostManager.default.host)
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isPresentTrain {
            checkTarinNextJump()
            isPresentTrain = false
        }
        checkIdentity()
        tableHeader.updateQrBtn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIsPush()
        timer = Timer(timeInterval: 1, repeats: true, block: timeAction)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    private func setTopView() {
        topViewHeightLC.constant = IS_IPHONEX ? 88 : 64
        topBgView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.edges.equalTo(topBgView).inset(UIEdgeInsets.zero)
        }
    }
    
    //    MARK: - 检查是否是从 push 进入
    private func checkIsPush() {
        if DataManager.isPush(),
            let tabvc = parent as? BaseTabbarVC
        {
            if tabvc.tabBar.items?.first?.title == "易间房" {
                tabvc.tabBar.items?.first?.title = "首页"
            }
            tabvc.selectedIndex = 1
            DataManager.saveIsPush(false)
        }
    }
    
    //    MARK: - 检查是否正在看房
    private func checkIsInHouse(_ data: [String : Any]) {
        let vc = WatchHouseVC()
        vc.lookInfo = data
        dzy_push(vc)
    }
    
    //    MARK: - 各种操作成功的监听
    private func addOberverFunc() {
        registObservers([
            PublicConfig.Notice_AddPriceSuccess,
            PublicConfig.Notice_BuySuccess,
            PublicConfig.Notice_UndoPriceSuccess
        ]) { [weak self] in
                self?.listApi(1)
        }
        
        registObservers([
            PublicConfig.Notice_ChangeCitySuccess
        ]) { [weak self] in
            PublicFunc.updateUserDetail { (_, _, _) in}
            self?.checkCityFunc()
        }
        
        registObservers([
            PublicConfig.Notice_InitCitySuccess
        ]) { [weak self] in
            self?.initUser()
        }
    }
    
    //    MARK: - 更新用户信息
    private func initUser() {
        PublicFunc.updateUserDetail { [weak self] (user, _, _) in
            self?.updateUserMsg(user)
        }
    }
    
    //    MAKR: - 更改城市
    private func checkCityFunc() {
        if city != RegionManager.city() {
            districtView.initUI(.district)
            city = RegionManager.city()
            topView.updateCity(city)
            RegionManager.clear()
            allRegionApi()
            evaluateConfigApi()
            listApi(1)
        }
    }
    
    // 初始化城市信息
    private func initCityFunc() {
        let user = DataManager.user()
        if let city = user?.stringValue("city"),
            let cityId = user?.intValue("cityId")
        {
            RegionManager.save(city, cityId: cityId)
            if self.city != city {
                listApi(1)
            }
            self.city = city
            topView.updateCity(city)
            allRegionApi()
            evaluateConfigApi()
            PublicConfig.updateSysConfig()
        }
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
    
    //    MARK: - 更新身份(初次进入根据在线的身份进行判断)
    private func updateUserMsg(_ user: [String : Any]?) {
        let city = user?.stringValue("city") ?? ""
        if city.isEmpty {
            let vc = CityPickerVC(.home_init)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            return
        }
        
        let type = user?.intValue("type") ?? 10
        if IDENTITY.rawValue != type {
            let index = type == 10 ? 0 : 1
            topView.changeIdentity(index)
            IDENTITY = Identity(rawValue: type) ?? .buyer
        }
        initCityFunc()
        checkTarinNextJump()
        checkDeposit()
    }
    
    // 检查身份 (每次到当前界面的时候进行判断)
    private func checkIdentity() {
        let type = topView.getIdentity()
        if IDENTITY.rawValue != type {
            // 这里type是当前身份，index 对应目标身份，所以是反过来的
            let index = type == 10 ? 1 : 0
            topView.changeIdentity(index)
        }
        checkDeposit()
    }

    //    MARK: - 前往搜索界面
    func goSearchVC(_ textField: UITextField) {
        let key = textField.text ?? ""
        if key.count > 0 {
            let vc = SearchVC(key)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 前往扫码界面
    private func goQrVC(_ isBanner: Bool) {
        let handler: ((String)->()) = { [weak self] str in
            self?.qrSuccess(str, isBanner: isBanner)
        }
        let vc = QRCodeVC(handler)
        dzy_push(vc)
    }
    
    private func qrSuccess(_ str: String, isBanner: Bool) {
        if str.hasPrefix("http") {
            //https://lock.ejfun.com/open/ejf-jc-bp01/C486CCCCF7445DA7
            let vc = WatchHouseVC()
            vc.code = str
            if !isBanner {
                vc.isFromHomeRgiht = true
            }
            dzy_push(vc)
        }else {
            let json = ToolClass
                .getDictionaryFromJSONString(jsonString: str)
            var type = ""
            if let intType = json.intValue("type") {
                type = "\(intType)"
            }else if let strType = json.stringValue("type") {
                type = strType
            }
            saveStaffMsg(json)
            czzdAction(type)
        }
    }
    
    private func saveStaffMsg(_ json: [String : Any]) {
        var staffMsg: [String : Any] = [:]
        guard let staffCode = json.stringValue("code") else {
            return
        }
        staffMsg["staffCode"] = staffCode
        if let remark = json.stringValue("remark"),
            remark.count > 0
        {
            staffMsg["remark"] = remark
        }else {
            staffMsg["remark"] = "地推"
        }
        DataManager.saveStaffMsg(staffMsg)
    }

    //    MARK: - 添加房源
    @IBAction func addHouseAction(_ sender: UIButton) {
        let vc = AddHouseBaseVC(RegionManager.cityId())
        dzy_push(vc)
    }
    
    //    MARK: - 缴纳保证金
    @IBAction func depositAction(_ sender: UIButton) {
        switch IDENTITY {
        case .buyer:
            let vc = PayBuyDepositVC(.normal)
            dzy_push(vc)
        case .seller:
            let vc = PaySellDepositVC(.normal)
            dzy_push(vc)
        }
    }
    
    private func checkDeposit() {
        if IDENTITY == .buyer {
            memoLB.text = "为方便您顺利买房，请尽快缴纳保证金"
            PublicFunc.checkPayOrTrain(.buyDeposit) { (result, _) in
                self.memoView.isHidden = result
            }
        }else {
            //为方便您顺利卖房，请你尽快发布房源
            memoLB.text = "为方便您顺利卖房，请尽快缴纳保证金"
            PublicFunc.checkPayOrTrain(.sellDeposit) { (result, _) in
                self.memoView.isHidden = result
            }
        }
    }
    
    //    MARK: - 各种懒加载
    /// 顶部的假 naviBar 内容
    private lazy var topView: HomeTopView = {
        let view = HomeTopView.initFromNib(HomeTopView.self)
        view.delegate = self
        return view
    }()
    /// section 1 的header
    private lazy var tableHeader: HomeTableHeaderView = {
        let view = HomeTableHeaderView
            .initFromNib(HomeTableHeaderView.self)
        view.delegate = self
        view.setUI(.buyer)
        return view
    }()
    /// section 2 的header
    private lazy var sectionHeader: HomeSectionHeader = {
        let header = HomeSectionHeader.initFromNib(HomeSectionHeader.self)
        header.delegate = self
        return header
    }()
    /// 用来显示排序逻辑帅选的界面
    lazy var popView: HomePopView = {
        let h = sectionHeaderH + topViewHeightLC.constant
        var frame = view.bounds
        frame.origin.y = h
        frame.size.height -= h
        
        let popView = HomePopView(frame: frame)
        popView.delegate = self
        return popView
    }()
    /// 区域的筛选界面
    private lazy var districtView: TwoTableFilterView = {
        let dView = TwoTableFilterView
            .initFromNib(TwoTableFilterView.self)
        dView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 292.0)
        dView.delegate = self
        return dView
    }()
    /// 户型的筛选界面
    private lazy var houseTypeView: CollectionFilterView = {
        let hView = CollectionFilterView
            .initFromNib(CollectionFilterView.self)
        hView.updateUI(.houseType)
        hView.delegate = self
        return hView
    }()
    /// 面积的筛选界面
    private lazy var areaView: CollectionFilterView = {
        let aView = CollectionFilterView
            .initFromNib(CollectionFilterView.self)
        aView.updateUI(.area)
        aView.delegate = self
        return aView
    }()
    /// 价格的筛选界面
    private lazy var priceView: CollectionFilterView = {
        let pView = CollectionFilterView
            .initFromNib(CollectionFilterView.self)
        pView.updateUI(.price)
        pView.delegate = self
        return pView
    }()
    
    private lazy var emptyView: HomeEmptyView = {
        return HomeEmptyView.initFromNib(HomeEmptyView.self)
    }()
    
    //    MARK: - api
    /// 房源列表
    func listApi(_ page: Int) {
        var dic: [String : Any] = [
            "topNum" : 3,
            "city" : city
        ]
        if let district = district {
            dic.updateValue(district, forKey: "region")
        }
        if let roomNum = roomNum {
            dic.updateValue(
                ToolClass.toJSONString(dict: roomNum),
                forKey: "roomNum"
            )
        }
        if let area = area {
            dic.updateValue(area.0, forKey: "minArea")
            dic.updateValue(area.1, forKey: "maxArea")
        }
        if let price = price {
            dic.updateValue(price.0, forKey: "minPrice")
            dic.updateValue(price.1, forKey: "maxPrice")
        }
        let request = BaseRequest()
        request.url = BaseURL.houseList
        if dic.count > 0 {
            request.dic  = dic
        }
        request.page = [page, 10]
        if page == 1 {ZKProgressHUD.show()}
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            self.pageOperation(data: data, isReload: page == 1 ? false : true)
            if page == 1 { // 只有在第一页的时候需要判断一下是否存在优显
                if let relist = data?
                    .dicValue("reHouseList")?
                    .arrValue("list"),
                    relist.count > 0
                {
                    self.dataArr.insert(contentsOf: relist, at: 0)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    /// banner
    private func bannerListApi() {
        let request = BaseRequest()
        request.url = BaseURL.bannerList
        request.page = [1, 10]
        request.dzy_start { [weak self] (data, _) in
            let list = data?.arrValue("list") ?? []
            self?.bannerList = list
            self?.tableHeader.updateBanner(list)
        }
    }
    
    /// 行政区、片区、小区
    private func allRegionApi() {
        let request = BaseRequest()
        request.url = BaseURL.allRegion
        request.dic = ["city" : city]
        request.start { (data, _) in
            let list = data?.arrValue("list") ?? []
            RegionManager.setDatas(list)
        }
    }
    
    /// 评价的配置项
    private func evaluateConfigApi() {
        let request = BaseRequest()
        request.url = BaseURL.evaluateConfig
        request.dic = ["city" : city]
        request.start { (data, _) in
            let list = data?.arrValue("list") ?? []
            var dic: [String : Any] = [:]
            for task in list {
                if let number = task.stringValue("number") {
                    dic[number] = task
                }
            }
            DataManager.saveEvaluateConfig(dic)
        }
    }
    
    /// 判断是否正在看房
    private func checkIsInHouseApi() {
        let request = BaseRequest()
        request.url = BaseURL.checkIsInHouse
        request.isUser = true
        request.start { (data, _) in
            if let data = data,
                data.count > 0
            {
                self.checkIsInHouse(data)
            }
        }
    }
    
    /// 所有城市
    private func cityListApi() {
        let request = BaseRequest()
        request.url = BaseURL.cityList
        request.dzy_start { (data, _) in
            let cityList = data?.arrValue("regionList") ?? []
            self.topView.updateUI(cityList.count <= 1)
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        if data.isOrderSuccess() { // 交易完成的 (处于签约到具结之间)
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.updateUI(data)
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalCell.self)
            cell?.delegate = self
            cell?.updateUI(data)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return tableHeader
        }else {
            return sectionHeader
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? tableHeaderH : sectionHeaderH
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataArr[indexPath.row]
        return data.isOrderSuccess() ? 89 : 97
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 && dataArr.isEmpty {
            return 180
        }else {
            return 0.1
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && dataArr.isEmpty {
            return emptyView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goHouseDetail(false, house: dataArr[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        if scrollView.dzy_ofy >= tableHeaderH {
            topView.change(false)
        }else {
            topView.change(true)
        }
    }
}

//MARK: - 各种功能快捷入口、地图找房、搜索
extension HomeVC: HomeTableHeaderViewDelegate {
    func header(_ headerView: HomeTableHeaderView, didSelectFun type: Int) {
        guard let fType = FunType(rawValue: type) else {return}
        switch fType {
        case .myBuy:
            let vc = MyBidBaseVC()
            dzy_push(vc)
        case .loans,
             .buyCompute,
             .sellCompute:
            let vc = CalculatorVC(fType)
            dzy_push(vc)
        case .howLook:
            let vc = BuyStepVC(.push)
            dzy_push(vc)
        case .howRelease:
            let vc = SellStepVC(.push)
            dzy_push(vc)
        default:
            break
        }
    }
    
    func header(_ headerView: HomeTableHeaderView, didSelectMapBtn btn: UIButton) {
        let vc = MapSearchVC()
        dzy_push(vc)
    }
    
    func header(_ headerView: HomeTableHeaderView, didSearchWithTF textField: UITextField) {
        goSearchVC(textField)
        textField.text = nil
    }
    
    func header(_ headerView: HomeTableHeaderView, didSelectQrBtn btn: UIButton) {
        goQrVC(true)
    }
    
    func header(_ headerView: HomeTableHeaderView, didSelectAdView page: Int) {
        guard page <= bannerList.count && bannerList.isEmpty == false else {return}
        let data = bannerList[page]
        guard let type = data.intValue("type"),
            let value = data.stringValue("value")
        else {return}
        switch type {
        case 10:
            guard let houseId = data.intValue("houseId") else {break}
            let vc = HouseDetailVC(houseId)
            dzy_push(vc)
        case 20:
            let vc = PlayVideoVC(value)
            dzy_push(vc)
        case 30:
            let vc = WkWebVC(.banner(url: value))
            dzy_push(vc)
        case 40:
            let vc = MapSearchVC()
            dzy_push(vc)
        default:
            break
        }
    }
}

//MARK: - 我要竞价
extension HomeVC: HouseListNormalCellDelegate {
    func normalCell(
        _ normalCell: HouseListNormalCell,
        didClickBidBtnWithHouse house: [String : Any]
    ) {
        goHouseDetail(true, house: house)
    }
    
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {
        
    }
}

//MARK: - 各种筛选
extension HomeVC: HomeSectionHeaderDelegate {
    func header(header: HomeSectionHeader, didSelect type: String) {
        guard let type = FilterType(rawValue: type) else {return}
        switch type {
        case .area:
            popView.updateSourceView(areaView)
        case .price:
            popView.updateSourceView(priceView)
        case .houseType:
            popView.updateSourceView(houseTypeView)
        case .district:
            if RegionManager.isEmpty() {
                showMessage("市区数据加载中，请稍后")
                checkSectionHeader()
                return
            }else {
                if districtView.isEmpty() {
                    districtView.initUI(.district)
                }
                popView.updateSourceView(districtView)
            }
        default:
            break
        }
        let point = CGPoint(x: 0, y: tableHeaderH)
        tableView.setContentOffset(point, animated: false)
        tableView.isScrollEnabled = false
        
        if header.showType == type {
            popView.dismiss()
            checkSectionHeader()
            header.showType = nil
        }else {
            popView.show(view)
            checkSectionHeader(type.getIndex())
            header.showType = type
        }
    }
}

//MARK: - 选择城市、切换身份、扫码、地图找房、搜索
extension HomeVC: HomeTopViewDelegate {
    func topView(_ topView: HomeTopView, didSelectCityBtn btn: UIButton) {
        let vc = CityPickerVC(.home)
        dzy_push(vc)
    }
    
    func topView(_ topView: HomeTopView, didChangeType typeInt: Int) {
        IDENTITY = typeInt == 0 ? .buyer : .seller
        checkDeposit()
        tableHeader.setUI(IDENTITY)
        addHouseBtn.isHidden = IDENTITY == .buyer
        let type = IDENTITY == .buyer ? 10 : 20
        PublicFunc.changeIdentityApi(type)
        
        // 如果有优先需要跳转的，则不进行判断
        guard DataManager.trainNextJump() == TrainNextJumpType.none else {return}
        let checktype: UserAllType = type == 10 ? .buyTrain : .sellTrain
        PublicFunc.checkPayOrTrain(checktype) { [weak self] (result, _) in
            if !result {
                self?.isPresentTrain = true
                let vc = type == 10 ? BuyStepVC(.changeType) : SellStepVC(.changeType)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func topView(_ topView: HomeTopView, didSelectQrCodeBtn btn: UIButton) {
        goQrVC(false)
    }
    
    func topView(_ topView: HomeTopView, didSelectMapBtn btn: UIButton) {
        let vc = MapSearchVC()
        dzy_push(vc)
    }
    
    func topView(_ topView: HomeTopView, didSearchWithTF textField: UITextField) {
        goSearchVC(textField)
        textField.text = nil
    }
}

extension HomeVC: HomePopViewDelegate {
    func popViewDidDismiss(_ popView: HomePopView) {
        popBgClickDismiss()
        tableView.isScrollEnabled = true
    }
}

//MARK: - 区域筛选
extension HomeVC: Searchable, TwoTableFilterViewDelegate, CollectionFilterViewDelegate {
    
    var header: HomeSectionHeader {
        return sectionHeader
    }
    
    func apiFunc() {
        listApi(1)
    }
    
    func homeAndSearchReset() {
        districtView.reset()
        houseTypeView.reset()
        areaView.reset()
        priceView.reset()
    }
    
    func ttView(_ ttView: TwoTableFilterView,
        didClickSureBtnWith fStr: String?,
        sStr: String?
    ) {
        selectDistrict(sStr == nil ? fStr : sStr)
    }
    
    func ttView(_ ttView: TwoTableFilterView, didClickClearBtn btn: UIButton) {
        reset()
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickSureBtnWithStrings strings: [String]?) {
        selectRoomNum(strings)
    }
    
    func cfView(
        _ cfView: CollectionFilterView,
        didClickSureBtnWithValue value: (Int, Int)?,
        showText str: String?,
        type: String)
    {
        selectAreaAndPrice(value, str: str, type: type)
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickClearBtn btn: UIButton) {
        reset()
    }
}
