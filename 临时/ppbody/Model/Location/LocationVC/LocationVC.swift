//
//  LocationVC.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum LocationSearchType: Int {
    case near = 0
    case new
    case priceUp
    case priceDown
    
    func strKey() -> String {
        switch self {
        case .near:
            return "near"
        case .new:
            return "new"
        case .priceUp:
            return "price_up"
        case .priceDown:
            return "price_down"
        }
    }
    
    func strValue() -> String {
        switch self {
        case .near:
            return "离我最近"
        case .new:
            return "最新发布"
        case .priceUp:
            return "价格最低"
        case .priceDown:
            return "价格最高"
        }
    }
}

class LocationVC: BaseVC, BaseRequestProtocol, ObserverVCProtocol, ActivityTimeProtocol {
    
    var observers: [[Any?]] = []
    
    var re_listView: UIScrollView {
        return tableView
    }

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topView: UIView!
    
    private var cityCode: String {
        return LocationManager.locationManager.cityCode ?? ""
    }
    /// 所有的城市
    private var cityList: [[String : Any]] = []
    /// 排序方式
    private var sortType: LocationSearchType = .near
    /// 区域相关的筛选
    private var regionDic: [String : String] = [:]
    
    private var lmanager = CLLocationManager()
    
    private var isBanner = false
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBanner = checkActivityDate()
        listAddHeader()
        lmanager.delegate = self
        topView.addSubview(topHeader)
        topHeader.snp.makeConstraints { (make) in
            make.edges.equalTo(topView).inset(UIEdgeInsets.zero)
        }
        tableView.dzy_registerCellNib(LocationGymCell.self)
        cityListApi()
        
        if !checkIsOpenServices() {
            let alert = dzy_msgAlert("提示", msg: "为正常使用附近相关功能，请前往手机设置界面开启定位功能")
            present(alert, animated: true, completion: nil)
        }
        
        registObservers([
            Config.Notify_RefreshLocationCity
        ]) { [weak self] (_) in
            self?.checkCityCode()
        }
    }
    
//    MARK: - 初始化城市信息
    private func initCityInfo(_ cityCode: String) {
        if let city = cityList
            .first(where: {$0.stringValue("code") == cityCode})?
            .stringValue("city")
        {
            topHeader.updateCity(city)
        }else {
            ToolClass.showToast("您所在地区，暂无健身房数据", .Failure)
        }
    }
    
    private func checkCityCode() {
        #if targetEnvironment(simulator)
        LocationManager.locationManager.cityCode = "027"
        #endif
        if let cityCode = LocationManager.locationManager.cityCode {
            initCityInfo(cityCode)
            regionListApi()
            listApi(1)
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.checkCityCode()
            }
        }
    }
    
//    MARK: - 前往双12活动界面
    private func goT12ListAction() {
        guard LocationManager.locationManager.cityCode != nil else {
            ToolClass.showToast("获取定位中，请稍后", .Failure)
            return
        }
        let vc = LocationActivityVC()
        dzy_push(vc)
    }
    
//    MARK: - 检查是否有定位权限
    private func checkIsOpenServices() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return CLLocationManager.locationServicesEnabled() &&
            (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
//    MARK: - 初始化筛选数据
    private func initSortData(_ data: [String : Any]) {
        var regions = data.arrValue("regions") ?? []
        var metros  = data.arrValue("metros") ?? []
        
        let regionHandler: ((Int, [String : Any]) -> [String : Any]) = { (index, origin) in
            var value = origin
            value[SelectedKey] = false
            if var list = value.arrValue("list") {
                list.insert([
                    "name" : "全部",
                    SelectedKey : false,
                    "index" : index // 这个只是为了判断点的那个子类的全部
                ], at: 0)
                list = list.map { (sorigin) -> [String : Any] in
                    var svalue = sorigin
                    svalue[SelectedKey] = false
                    return svalue
                }
                value["list"] = list
            }
            return value
        }
        let metroHandler: (([String : Any]) -> [String : Any]) = { origin in
            var value = origin
            value[SelectedKey] = false
            if let list = value.arrValue("list") {
                value["list"] = list.map { (sorigin) -> [String : Any] in
                    var svalue = sorigin
                    svalue[SelectedKey] = false
                    return svalue
                }
            }
            return value
        }
        // 地铁和商圈不一样，地铁没有 "全部"
        regions = regions.enumerated().map(regionHandler)
        metros = metros.map(metroHandler)
        regions.insert([
            "name" : "全部",
            SelectedKey : true
        ], at: 0)
        tbFilterView.updateUI(regions,
                              metros: metros)
    }
    
    //    MARK: - API
    /// 所有城市
    private func cityListApi() {
        let request = BaseRequest()
        request.url = BaseURL.CityList
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.cityList = data?.arrValue("list") ?? []
            self.checkCityCode()
        }
    }
    /// 筛选数据
    private func regionListApi() {
        let request = BaseRequest()
        request.url = BaseURL.RegionList
        request.dic = ["cityCode" : cityCode]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.initSortData(data)
            }
        }
    }
    /// 健身房列表
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.ClubList
        var dic: [String : String] = [
            "cityCode" : cityCode,
            "latitude" : LocationManager.locationManager.latitude,
            "longitude" : LocationManager.locationManager.longitude,
            "sortStr" : sortType.strKey()
        ]
        dic.merge(regionDic) { (current, _) -> String in current}
        request.dic = dic
        request.page = [page, 20]
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var topHeader: LocationTopView = {
        let view = LocationTopView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var tbFilterView: LocationTwoTBFilterView = {
        let view = LocationTwoTBFilterView.initFromNib()
        view.initUI()
        view.delegate = self
        return view
    }()
    
    private lazy var sortFilterView: LocationSortFilterView = {
        let view = LocationSortFilterView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var header: LocationBannerHeaderView = {
        let header = LocationBannerHeaderView.initFromNib()
        header.handler = { [weak self] in
            self?.goT12ListAction()
        }
        return header
    }()
}

extension LocationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LocationGymCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isBanner ? 105 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return isBanner ? header : nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cid = dataArr[indexPath.row].stringValue("cid") {
            let vc = LocationGymVC(cid)
            dzy_push(vc)
        }else {
            ToolClass.showToast("无效的健身房信息", .Failure)
        }
    }
}

extension LocationVC: LocationTopViewDelegate {
    func topView(_ topView: LocationTopView, shouldBeginEditing tf: UITextField) {
        let dic: [String : String] = [
            "cityCode" : cityCode,
            "latitude" : LocationManager.locationManager.latitude,
            "longitude" : LocationManager.locationManager.longitude,
            "sortStr" : "near"//sortType.strKey()
        ]
        let vc = LocationSearchVC(dic)
        dzy_push(vc)
    }
    
    func topView(_ topView: LocationTopView, didClickMapBtn btn: UIButton) {
        guard LocationManager.locationManager.cityCode != nil else {
            ToolClass.showToast("定位尚未完成，请稍后", .Failure)
            return
        }
        let vc = LocationCityVC(cityList)
        dzy_push(vc)
    }
    
    func topView(_ topView: LocationTopView,
                 didClickNearbyBtn btn: UIButton) {
        if sortFilterView.isShow {
            sortFilterView.remove()
        }
        if tbFilterView.isShow {
            tbFilterView.dismiss()
        }else {
            let y = view.safeAreaInsets.top + 90
            tbFilterView.show(in: view, y: y)
        }
    }
    
    func topView(_ topView: LocationTopView,
                 didClickSortBtn btn: UIButton) {
        if tbFilterView.isShow {
            tbFilterView.remove()
        }
        if sortFilterView.isShow {
            sortFilterView.dismiss()
        }else {
            let y = view.safeAreaInsets.top + 90
            sortFilterView.show(in: view, y: y)
        }
    }
}

extension LocationVC: LocationSortFilterViewDelegate {
    func sortView(_ sortView: LocationSortFilterView, didClickBtn btn: UIButton) {
        guard let sortType = LocationSearchType(rawValue: btn.tag) else {return}
        self.sortType = sortType
        topHeader.sortLBUpdate(sortType.strValue())
        listApi(1)
    }
    
    func sortView(_ sortView: LocationSortFilterView,
                  willRemoveFromSuperView view: UIView?)
    {
        topHeader.sortViewUpdate(false)
    }
}

extension LocationVC: LocationTwoTBFilterViewDelegate {
    
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    didSelectedRegion regionId: Int,
                    regionName: String)
    {
        regionDic = ["regionId" : "\(regionId)"]
        listApi(1)
        topHeader.regionLBUpdate(regionName)
    }
    
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    didSelectedMetro latitude: Double,
                    longitude: Double,
                    metroName: String)
    {
        regionDic = [
            "latitudeLoc" : "\(latitude)",
            "longitudeLoc" : "\(longitude)"
        ]
        listApi(1)
        topHeader.regionLBUpdate(metroName)
    }
    
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    willRemoveFromSuperView view: UIView?)
    {
        topHeader.nearbyViewUpdate(false)
    }
    
    func didCleanFilterKey(_ twoTbFView: LocationTwoTBFilterView) {
        regionDic = [:]
        listApi(1)
        topHeader.regionLBUpdate("附近")
    }
}

extension LocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways ||
            status == .authorizedWhenInUse
        {
            LocationManager.locationManager.reGeocodeAction()
            LocationManager.locationManager.startLocationTime()
        }
    }
}
