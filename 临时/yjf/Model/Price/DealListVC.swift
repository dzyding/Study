//
//  DealListVC.swift
//  YJF
//
//  Created by edz on 2019/7/2.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class DealListVC: BasePageVC, BaseRequestProtocol, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var inputTF: UITextField!
    /// 占位图
    @IBOutlet weak var headerPhView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    /// 地区
    private var district: String?
    /// 居室
    private var roomNum: [String]?
    /// 面积
    private var area: (Int, Int)?
    /// 面积显示的字符串
    private var areaStr: String?
    /// 筛选字符串
    private var filterStr: String?
    /// 排序字符串
    private var orderStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        observerFunc()
        listAddHeader()
        listApi(1)
    }
    
    deinit {
        dzy_log("销毁")
        deinitObservers()
    }
    
    private func setUI() {
        inputTF.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
        inputTF.delegate = self
        headerPhView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.edges.equalTo(headerPhView).inset(UIEdgeInsets.zero)
        }
        
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
    }
    
    private func observerFunc() {
        registObservers(
            [PublicConfig.Notice_ChangeCitySuccess]
        ) { [weak self] in
            self?.districtView.initUI(.district)
            self?.listApi(1)
        }
    }
    
    //    MARK: - api
    func listApi(_ page: Int) {
        let city = RegionManager.city()
        var dic: [String : Any] = ["city" : city]
        if let key = inputTF.text, key.count > 0 {
            dic["key"] = key
        }
        if let area = area {
            dic["minArea"] = area.0
            dic["maxArea"] = area.1
        }
        if let district = district {
            dic["region"] = district
        }
        if let roomNum = roomNum {
            dic["roomNum"] = ToolClass.toJSONString(dict: roomNum)
        }
        if let floor = filterView.floorMsg {
            dic["minFloorNum"] = floor.0
            dic["maxFloorNum"] = floor.1
        }
        if let time = filterView.timeMsg {
            dic["start"] = time.0
            dic["end"]   = time.1
        }
        if let sprice = filterView.sPriceMsg {
            dic["minUnitPrice"] = sprice.0
            dic["maxUnitPrice"] = sprice.1
        }
        if let tprice = filterView.tPriceMsg {
            dic["minPrice"] = tprice.0
            dic["maxPrice"] = tprice.1
        }
        if let type = orderView.dealMsgInfo() {
            dic["type"] = type
        }
        let request = BaseRequest()
        request.url = BaseURL.dealList
        request.dic = dic
        request.page = [page, 10]
        if page == 1 {ZKProgressHUD.show()}
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            self.pageOperation(data: data)
        }
    }

    //    MARK: - 懒加载
    private lazy var headerView: DealFilterHeaderView = {
        let header = DealFilterHeaderView.initFromNib(DealFilterHeaderView.self)
        header.delegate = self
        return header
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
    /// 筛选的界面
    private lazy var filterView: DealFilterView = {
        let h:CGFloat = 50 + 44
        var frame = view.bounds
        frame.size.height -= h
        
        let view = DealFilterView.initFromNib(DealFilterView.self)
        view.frame = frame
        view.initUI()
        view.delegate = self
        return view
    }()
    /// 排序的界面
    private lazy var orderView: TwoTableFilterView = {
        let view = TwoTableFilterView
            .initFromNib(TwoTableFilterView.self)
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 292.0)
        view.initUI(.order)
        view.delegate = self
        return view
    }()
    /// 用来显示排序逻辑帅选的界面
    lazy var popView: HomePopView = {
        let h:CGFloat = 50 + 44
        var frame = view.bounds
        frame.origin.y = h
        frame.size.height -= h
        
        let popView = HomePopView(frame: frame)
        popView.delegate = self
        return popView
    }()
}

extension DealListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(HouseListSuccessCell.self)
        let data = dataArr[indexPath.row]
        cell?.updateUI(data.dicValue("house") ?? [:])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let houseId = dataArr[indexPath.row]
            .dicValue("house")?
            .intValue("id")
        {
            let vc = HouseDetailVC(houseId)
            vc.isDeal = true
            dzy_push(vc)
        }
        
    }
}

extension DealListVC: DealFilterHeaderViewDelegate {
    
    func filterHeader(_ filterHeader: DealFilterHeaderView, didSelectOrderBtn btn: UIButton) {
        popView.updateSourceView(orderView)
        filterBaseFun(.order)
    }
    
    func filterHeader(_ filterHeader: DealFilterHeaderView, didSelect type: String) {
        guard let type = FilterType(rawValue: type) else {return}
        switch type {
        case .area:
            popView.updateSourceView(areaView)
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
        case .filter:
            filterView.frame = popView.bounds
            popView.updateSourceView(filterView)
        default:
            break
        }
        filterBaseFun(type)
    }
    
    private func filterBaseFun(_ type: FilterType) {
        tableView.isScrollEnabled = false
        if headerView.showType == type {
            popView.dismiss()
            checkSectionHeader()
            headerView.showType = nil
        }else {
            popView.show(view)
            checkSectionHeader(type.getIndex())
            headerView.showType = type
        }
    }
    
    private func checkSectionHeader(_ except: Int = 99) {
        func getTilte(_ index: Int) -> String? {
            switch index {
            case 0:
                return district
            case 1:
                return roomNum?.joined(separator: "-")
            case 2:
                return areaStr
            case 3:
                return filterStr
            default:
                return orderStr
            }
        }
        (0..<5).forEach { (index) in
            if except != index {
                headerView.setTilte(index, title: getTilte(index))
            }
        }
    }
}

extension DealListVC: HomePopViewDelegate {
    func popViewDidDismiss(_ popView: HomePopView) {
        headerView.showType = nil
        checkSectionHeader()
        tableView.isScrollEnabled = true
    }
    
    func reset() {
        popView.dismiss()
        districtView.reset()
        district = nil
        headerView.setTilte(0, title: nil)
        
        houseTypeView.reset()
        roomNum = nil
        headerView.setTilte(1, title: nil)
        
        areaView.reset()
        area = nil
        areaStr = nil
        headerView.setTilte(2, title: nil)
        
        filterView.reset()
        filterStr = nil
        headerView.setTilte(3, title: nil)
        
        orderView.reset()
        orderStr = nil
        headerView.setTilte(4, title: nil)
        
        listApi(1)
    }
}

extension DealListVC: CollectionFilterViewDelegate {
    
    func cfView(_ cfView: CollectionFilterView,
        didClickSureBtnWithValue value: (Int, Int)?,
        showText str: String?,
        type: String
    ) {
        popView.dismiss()
        let old = area
        area = value
        areaStr = str
        headerView.setTilte(2, title: str)
        if !(old?.0 == value?.0 && old?.1 == value?.1) {
            listApi(1)
        }
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickSureBtnWithStrings strings: [String]?) {
        popView.dismiss()
        let old = self.roomNum
        self.roomNum = strings
        headerView.setTilte(1, title: strings?.joined(separator: "-"))
        if old != roomNum {
            listApi(1)
        }
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickClearBtn btn: UIButton) {
        reset()
    }
}

extension DealListVC: TwoTableFilterViewDelegate {
    func ttView(_ ttView: TwoTableFilterView,
        didClickSureBtnWith fStr: String?,
        sStr: String?
    ) {
        popView.dismiss()
        if ttView == districtView {
            let old = district
            district = sStr == nil ? fStr : sStr
            headerView.setTilte(0, title: district)
            if old != district {
                listApi(1)
            }
        }else {
            let old = orderStr
            if let fStr = fStr,
                let sStr = sStr
            {
                orderStr = fStr + sStr
            }else {
                orderStr = nil
            }
            headerView.setTilte(4, title: orderStr)
            if old != orderStr {
                listApi(1)
            }
        }
    }
    
    func ttView(_ ttView: TwoTableFilterView, didClickClearBtn btn: UIButton) {
        reset()
    }
}

extension DealListVC: DealFilterViewDelegate {
    func filterView(_ filterView: DealFilterView, didClickSureBtn btn: UIButton, count: Int) {
        popView.dismiss()
        filterStr = count == 0 ? nil : "筛选"
        headerView.setTilte(3, title: filterStr)
        listApi(1)
    }
    
    func filterView(_ filterView: DealFilterView, didClickClearBtn btn: UIButton) {
        reset()
    }
}

extension DealListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        listApi(1)
    }
}
