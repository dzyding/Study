//
//  HouseDetailBaseVC.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import MapKit

enum HouseDetailType: Int {
    case info = 0   // 房源信息
    case map        // 房源导航
    case nearby     // 房源备忘
}

class HouseDetailBaseVC: BaseVC, JumpHouseDetailProtocol, CheckLockDestroyProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var bottomBg: UIView!
    
    private var data: [String : Any] = [:]
    /// 推荐房源列表
    private var recommendList: [[String : Any]] = []
    
    private var type: HouseDetailType = .info
    
    private var identity: Identity = .buyer
    
    private let houseId: Int
    /// 房源定位
    private var houseLocation = CLLocationCoordinate2D()
    /// 百度定位
    private var baiduLocation: CLLocationCoordinate2D {
        return dzy_gdToBaidu(houseLocation)
    }
    /// 当前定位
    private var currentLocation: DzyLLocationModel? = nil
    /// 备忘录
    private var remark: String?
    
    private var bidDetailVC: HouseBidDetailBaseVC? {
        return parent?.children.last as? HouseBidDetailBaseVC
    }
    
    private var isDeal: Bool {
        if let vc = parent as? HouseDetailVC {
            return vc.isDeal
        }else {
            return false
        }
    }
    
    private var timer: Timer? = nil
    
    init(_ houseId: Int) {
        self.houseId = houseId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        addFooterMarkApi()
        dzy_log("销毁")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        detailApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer(timeInterval: 1, repeats: true, block: timeAction)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    private func initSubViews() {
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
        tableView.dzy_registerCellNib(HouseListNormalCell.self)
        
        bottomBg.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.edges.equalTo(bottomBg).inset(UIEdgeInsets.zero)
        }
        tableView.isHidden = true
    }
    
    //    MARK: - 获取当前定位
    private func loadCurrentLocation() {
        if locManager.checkIsOpenServices() {
            locManager.start()
        }
    }
    
    // 判断距离
    func checkDistanceToTheDoor(_ model: DzyLLocationModel) -> Bool {
        let distance = DzyLocationManager.distanceBetweenTwoPoint(
            model.latitude,
            lon1: model.longitude,
            lat2: houseLocation.latitude,
            lon2: houseLocation.longitude)
        let sysValue = PublicConfig
            .sysConfigDoubleValue(.lockDistance) ?? 99999
        return distance <= sysValue
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
    
    //    MARK: - 刷新 ui
    func updateUI(_ data: [String : Any]) {
        self.data = data
        let house = data.dicValue("house") ?? [:]
        let type: Identity = house.intValue("userId") == DataManager.getUserId() ? .seller : .buyer
        identity = type
        
        // 判断门锁状态
        if isLockCanUse(house) {
            // 门锁可以使用，尝试获取定位
            loadCurrentLocation()
        }
        
        bidDetailVC?.identity = type
        tableView.isHidden = false
        bidDetailVC?.updateHouseMsg(data)
        houseLocation = CLLocationCoordinate2D(
            latitude: house.doubleValue("latitude") ?? 0,
            longitude: house.doubleValue("longitude") ?? 0
        )
        let ambitus = data.stringValue("ambitus") ?? ""
        nearbyView.updateUI(ambitus)
        remark = data.dicValue("houseRemark")?.stringValue("remark")
        editView.updateUI(remark ?? "")
        topView.updateUI(data, identity: identity)
        bottomView.setType(.house,
                           identity: identity,
                           data: data,
                           isDeal: isDeal)
        mapView.updateUI(houseLocation)
        infoView.updateUI(data, isDeal: isDeal, identity: identity)
        recommendList = data.dicValue("recommendList")?
            .arrValue("list") ?? []
        tableView.reloadData()
    }
    
    //    MARK: - 收藏按钮
    func updateFaviBtn(_ isSelected: Bool) {
        bottomView.updateFavBtn(isSelected)
    }
    
    //    MARK: - api
    /// 关注
    private func attentionApi() {
        let request = BaseRequest()
        request.url = BaseURL.attentionHouse
        request.dic = ["houseId" : houseId]
        request.isUser = true
        request.start { (_, _) in
            
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
    
    /// 详情
    private func detailApi() {
        let request = BaseRequest()
        request.url = BaseURL.houseDetail
        request.dic = [
            "houseId" : houseId
        ]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.updateUI(data ?? [:])
        }
    }
    
    /// 添加记录
    private func addFooterMarkApi() {
        let request = BaseRequest()
        request.url = BaseURL.addFootMark
        request.dic = [
            "houseId" : houseId,
            "remark"  : remark ?? ""
        ]
        request.isUser = true
        request.start { (_, _) in
            
        }
    }
    
    //    MARK: - 懒加载
    /// 顶部的滚动视图和房源名字
    lazy var topView: HouseDetailTopView = {
        let top = HouseDetailTopView.initFromNib(HouseDetailTopView.self)
        top.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 335)
        top.gzBtn.isUserInteractionEnabled = !isDeal
        top.delegate = self
        return top
    }()
    
    /// 房源信息
    lazy var infoView: HouseDetailInfoView = {
        let info = HouseDetailInfoView
            .initFromNib(HouseDetailInfoView.self)
        info.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 240)
        return info
    }()
    
    /// 周边
    lazy var nearbyView: HouseDetailNearbyView = {
        let view = HouseDetailNearbyView.initFromNib(HouseDetailNearbyView.self)
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 500.0)
        return view
    }()
    
    /// 备忘录
    lazy var editView: HouseDetailEditView = {
        let edit = HouseDetailEditView.initFromNib(HouseDetailEditView.self)
        edit.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 255)
        edit.isUserInteractionEnabled = !isDeal
        edit.delegate = self
        return edit
    }()
    
    /// 导航
    lazy var mapView: HouseDetailMapView = {
        let map = HouseDetailMapView.initFromNib(HouseDetailMapView.self)
        map.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300.0)
        map.delegate = self
        map.initMapView()
        return map
    }()
    
    /// 底部的收藏，报告故障等
    lazy var bottomView: HouseDetailBottomView = {
        let bottom = HouseDetailBottomView
            .initFromNib(HouseDetailBottomView.self)
        bottom.setType(.house,
                       identity: identity,
                       data: [:],
                       isDeal: isDeal)
        bottom.delegate = self
        bottom.layer.shadowColor = UIColor.gray.cgColor
        bottom.layer.shadowRadius = 3
        bottom.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottom.layer.shadowOpacity = 0.2
        return bottom
    }()
    
    private lazy var locManager: DzyLocationManager = {
        let manager = DzyLocationManager.default
        manager.initStep(.tenMeters, times: .once)
        manager.locationHandler = { [weak self] model in
            self?.currentLocation = model
        }
        manager.changeHandler = { [weak self] in
            self?.loadCurrentLocation()
        }
        return manager
    }()
}

extension HouseDetailBaseVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch identity {
        case .buyer where type == .info: // 买方，并且是详情界面
            return 2 //(ad - 信息/导航) (备忘 推荐 -)  //[头 cell 尾]
        default: // 卖方
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch identity {
        case .buyer where type == .info && section == 1:  // 买方的推荐列表
            return recommendList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 335
        case 1 where type == .info:
            return 255
        default:
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return topView
        case 1 where type == .info:
            return editView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0 where type == .info:
            return 240
        case 0 where type == .map:
            let height = ScreenHeight - 335 - NaviH - 70 - TabRH
            return height
        case 0 where type == .nearby:
            return nearbyView.height
        default:
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0 where type == .info:
            return infoView
        case 0 where type == .map:
            return mapView
        case 0 where type == .nearby:
            return nearbyView
        default:
            return nil
        }
    }
    
    // 下面这几个接口不用区分买方，卖方
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let house = recommendList[indexPath.row]
        return house.isOrderSuccess() ? 89 : 97
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let house = recommendList[indexPath.row]
        if house.isOrderSuccess() {
            let cell = tableView.dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.updateUI(house)
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalCell.self)
            cell?.delegate = self
            cell?.updateUI(house)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goHouseDetail(false, house: recommendList[indexPath.row])
    }
}

extension HouseDetailBaseVC: HouseListNormalCellDelegate {
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {}
    
    func normalCell(_ normalCell: HouseListNormalCell, didClickBidBtnWithHouse house: [String : Any]) {
        goHouseDetail(true, house: house)
    }
}

//MARK: - 关注，切换显示的 type
extension HouseDetailBaseVC: HouseDetailTopViewDelegate {
    func topView(_ topView: HouseDetailTopView, didSelectGzBtn btn: UIButton) {
        attentionApi()
    }
    
    func topView(_ topView: HouseDetailTopView, didSelectType type: Int) {
        if let type = HouseDetailType.init(rawValue: type) {
            self.type = type
            tableView.reloadData()
        }
    }
}

//MARK: - 收藏 报告门锁故障 看房
extension HouseDetailBaseVC: HouseDetailBottomViewDelegate {
    
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectFaviBtn btn: UIButton) {
        collectApi()
        bidDetailVC?.updateFavBtn(btn.isSelected)
    }
    
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectLeftBtn btn: UIButton) {
        if !locManager.checkIsOpenServices() {
            let alert = dzy_msgAlert("提示", msg: "系统检测您关闭了手机的定位功能，若想使用门锁相关功能请开启定位授权。")
            present(alert, animated: true, completion: nil)
        }else if currentLocation == nil {
            ToolClass.showToast("定位获取中，请稍后", .Failure)
        }else {
            guard let current = currentLocation else {return}
            if checkDistanceToTheDoor(current) {
                let vc = ReportLockDestroyVC(houseId, type: .detail)
                dzy_push(vc)
            }else {
                ToolClass.showToast("离门锁太远，无法提交故障报告", .Failure)
            }
        }
    }
    
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectRightBtn btn: UIButton) {
        let vc = WatchHouseVC()
        vc.houseId = self.houseId
        self.dzy_push(vc)
    }
}

//MARK: - 前往地图导航
extension HouseDetailBaseVC: HouseDetailMapViewDelegate {
    func mapView(_ mapView: HouseDetailMapView, didClickNaviBtn btn: UIButton) {
        let house = data.dicValue("house")
        let name = (house?.stringValue("community") ?? "") + (house?.stringValue("roomNum") ?? "")
        
        let textColor = MainColor
        let alert = UIAlertController(title: nil, message: "前往指定应用进行导航", preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .light
        }
        let apple = UIAlertAction(title: "Apple 地图", style: .default) { [weak self] (_) in
            self?.appleMapAction(name)
        }
        apple.setTextColor(textColor)
        let baidu = UIAlertAction(title: "百度地图", style: .default) { [weak self] (_) in
            guard let sSelf = self,
                let bdurl = URL(string: "baidumap://"),
                UIApplication.shared.canOpenURL(bdurl)
            else {
                ToolClass.showToast("您尚未安装百度地图", .Failure)
                return
            }
            String(format: "baidumap://map/direction?origin={{我的位置}}&destination=name:%@|latlng:%lf,%lf&coord_type=bd09ll&mode=driving&src=ios.YJF.YJFUser", name, sSelf.baiduLocation.latitude, sSelf.baiduLocation.longitude)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap({
                URL(string: $0)
            })
            .flatMap({
                UIApplication.shared.open($0)
            })
        }
        baidu.setTextColor(textColor)
        let gaode = UIAlertAction(title: "高德地图", style: .default) { [weak self] (_) in
            guard let sSelf = self,
                let bdurl = URL(string: "iosamap://"),
                UIApplication.shared.canOpenURL(bdurl)
            else {
                ToolClass.showToast("您尚未安装高德地图", .Failure)
                return
            }
            String(format: "iosamap://path?sourceApplication=ios.YJF.YJFUser&sid=&slat=&slon=&sname=&did=&dlat=%lf&dlon=%lf&dname=%@&dev=0&t=0", sSelf.houseLocation.latitude, sSelf.houseLocation.longitude, name)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap({
                URL(string: $0)
            })
            .flatMap({
                UIApplication.shared.open($0)
            })
        }
        gaode.setTextColor(textColor)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancel.setTextColor(textColor)
        alert.addAction(apple)
        alert.addAction(baidu)
        alert.addAction(gaode)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)

    }
    
    private func appleMapAction(_ name: String) {
        let current = MKMapItem.forCurrentLocation()
        let end = MKMapItem(placemark: MKPlacemark(coordinate: houseLocation))
        end.name = name
        MKMapItem.openMaps(with: [current, end], launchOptions: [
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey : true
            ])
    }
}

//MARK: - 更新备注
extension HouseDetailBaseVC: HouseDetailEditViewDelegate {
    func editView(_ editView: HouseDetailEditView, didClickSureBtn btn: UIButton) {
        remark = editView.showLB.text
    }
}
