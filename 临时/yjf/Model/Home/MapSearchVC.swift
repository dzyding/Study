//
//  MapSearchVC.swift
//  YJF
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import AMapFoundationKit
import ZKProgressHUD

enum ListLocation {
    case none   // 尚未添加到父视图
    case hidden // 隐藏状态
    case up     // 全屏显示
    case down   // 在下面显示
}

enum MapZoomLv: Double {
    case city = 8.2        // 小区
    case region = 10.2     // 行政区
    case area = 13.0       // 片区
    case community = 16.5  // 小区
    
    func hierarchy() -> Int {
        switch self {
        case .city:
            return 1
        case .region:
            return 2
        case .area:
            return 3
        case .community:
            return 4
        }
    }
}

//swiftlint:disable type_body_length file_length
class MapSearchVC: BasePageVC, BaseRequestProtocol, JumpHouseDetailProtocol {
    
    var re_listView: UIScrollView {
        return tableView ?? UIScrollView()
    }
    // 武汉的经纬度
    private var whlocation = CLLocationCoordinate2D(
        latitude: 30.560631242738516, longitude: 114.28408966100172
    )
    private weak var tableView: UITableView?
    // listView 的初始 frame
    private let originFrame = CGRect(
        x: 0,
        y: ScreenHeight,
        width: ScreenWidth,
        height: 270.0
    )
    // 当前状态
    private var listType: ListLocation = .none {
        didSet {
            changeTypeAnimate(oldValue)
        }
    }
    
    private var timer: Timer? = nil
    
    //swifltlint:disable:next vertical_whitespace
    // ***** 地图相关信息 *****
    
    private let lock = NSLock()
    
    private lazy var radius: Int = {
        let sPoint = CGPoint(x: 0, y: 0)
        let ePoint = CGPoint(x: mapView.dzy_w / 2.0, y: mapView.dzy_h / 2.0)
        let sLoc = mapView.convert(sPoint, toCoordinateFrom: mapView)
        let eLoc = mapView.convert(ePoint, toCoordinateFrom: mapView)
        let trans = MAMetersBetweenMapPoints(
            MAMapPointForCoordinate(sLoc),
            MAMapPointForCoordinate(eLoc)
        )
        return Int(trans)
    }()
    private var zoomLv: MapZoomLv = .region
    
    /// 城市的所有 hierarchy-Id
    private var cityIds: Set<String> = []
    /// 城市的所有大头针
    private var cityAnnos: [MAPointAnnotation] = []
    /// 城市的 rect
    private var cityModel = MapSearchModel.zero
    /// 行政区的所有 hierarchy-Id
    private var regionIds: Set<String> = []
    /// 行政区的所有大头针
    private var regionAnnos: [MAPointAnnotation] = []
    /// 行政区的 rect
    private var regionModel = MapSearchModel.zero
    /// 片区的所有 hierarchy-Id
    private var areaIds: Set<String> = []
    /// 片区的大头针
    private var areaAnnos: [MAPointAnnotation] = []
    /// 片区的 rect
    private var areaModel = MapSearchModel.zero
    /// 小区的所有 hierarchy-Id
    private var communityIds: Set<String> = []
    /// 所有的小区数据
    private var communityDatas: [[String : Any]] = []
    /// 小区的所有大头针
    private var communityAnnos: [MAPointAnnotation] = []
    /// 小区的 rect
    private var communityModel = MapSearchModel.zero
    
    /// 当前选中的小区
    private weak var currentCommuntiyView: CommunityAnnotationView?
    /// 当前小区的 id
    private var communityId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "地图找房"
        view.addSubview(mapView)
        view.addSubview(cListView)
        cListView.isHidden = true
        listAddHeader(false)
        searchApi()
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
    
    //    MARK: - 滚动的 timerAction
    private func timeAction(_ timer: Timer) {
        let total = Int(Date().timeIntervalSince1970)
        tableView?.visibleCells.forEach { (cell) in
            if let cell = cell as? HouseListNormalCell {
                cell.updatePriceAction(total)
            }
        }
    }
    
    //    MARK: - 片区、小区
    private func addAreaOrComunityAnnos(_ list: [[String : Any]],
                                        tZoomlv: MapZoomLv)
    {
        lock.lock()
        
        var temp: [MAPointAnnotation] = []
        list.forEach { (data) in
            let id = data.intValue("id") ?? 0
            let hierarchy = data.intValue("hierarchy") ?? 0
            let str = "\(hierarchy)-\(id)"
            if let latitude = data.doubleValue("latitude"),
                let longitude = data.doubleValue("longitude")
            {
                let anno = CustomDataAnnotation()
                anno.coordinate = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )
                anno.data = data
                
                switch tZoomlv {
                case .city:
                    if !cityIds.contains(str) {
                        cityIds.insert(str)
                        cityAnnos.append(anno)
                        temp.append(anno)
                    }
                case .region:
                    if !regionIds.contains(str) {
                        regionIds.insert(str)
                        regionAnnos.append(anno)
                        temp.append(anno)
                    }
                case .area:
                    if !areaIds.contains(str) {
                        areaIds.insert(str)
                        areaAnnos.append(anno)
                        temp.append(anno)
                    }
                case .community:
                    if !communityIds.contains(str) {
                        communityDatas.append(data)
                        communityIds.insert(str)
                        communityAnnos.append(anno)
                        temp.append(anno)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            if temp.count > 0 && tZoomlv == self.zoomLv {
                self.mapView.addAnnotations(temp)
            }
            if self.zoomLv == .community {
                self.cListView.reloadData()
            }
            ZKProgressHUD.dismiss()
        }
        lock.unlock()
    }
    
    private func computeTheCorner() {
        let ltPoint = CGPoint(x: 0, y: 0)
        let rbPoint = CGPoint(x: mapView.dzy_w, y: mapView.dzy_h)
        let ltLoc = mapView.convert(ltPoint, toCoordinateFrom: mapView)
        let rbLoc = mapView.convert(rbPoint, toCoordinateFrom: mapView)
        let model = MapSearchModel(ltLoc, rbLoc: rbLoc)
        switch zoomLv {
        case .city:
            if !cityModel.contain(model) {
                cityModel = cityModel.add(model)
                searchApi()
            }
        case .region:
            if !regionModel.contain(model) {
                regionModel = regionModel.add(model)
                searchApi()
            }
        case .area:
            if !areaModel.contain(model) {
                areaModel = areaModel.add(model)
                searchApi()
            }
        case .community:
            if !communityModel.contain(model) {
                communityModel = communityModel.add(model)
                searchApi()
            }
        }
    }
    
    //    MARK: - 小区的点击事件
    @objc private func communityAction(_ data: [String : Any]) {
        if let latitude = data.doubleValue("latitude"),
            let longitude = data.doubleValue("longitude"),
            let id = data.intValue("id")
        {
            communityId = id
            listApi(1)
            
            mapView.setCenter(
                CLLocationCoordinate2D(
                    latitude: latitude, longitude: longitude
                ),
                animated: true
            )
        }
        
        header.updateNameMsg(data)
        switch listType {
        case .none:
            listView.frame = originFrame
            view.addSubview(listView)
            listType = .down
        case .hidden:
            listType = .down
        default:
            break
        }
    }
    
    // 向上滑动
    @objc private func upSwipeAction() {
        listType = .up
    }
    
    // 向下滑动
    @objc private func downSwipeAction() {
        switch listType {
        case .down:
            listType = .hidden
            if let currentCommuntiyView = currentCommuntiyView {
                mapView.deselectAnnotation(
                    currentCommuntiyView.annotation, animated: false
                )
                self.currentCommuntiyView = nil
            }
        default:
            listType = .down
        }
    }
    
    //    MARK: - 更改状态对应的动画
    func changeTypeAnimate(_ oldValue: ListLocation) {
        if listType == oldValue {return}
        switch listType {
        case .hidden:
            UIView.animate(withDuration: 0.25) {
                self.listView.frame = self.originFrame
            }
        case .down:
            header.zkIV.isHidden = false
            if oldValue == .up {
                let height = originFrame.height
                // 先只进行下移
                var firstFrame = listView.frame
                firstFrame.y = ScreenHeight - height
                // 然后变成正常的 frame
                let secondFrame = CGRect(
                    x: 0,
                    y: ScreenHeight - height,
                    width: ScreenWidth,
                    height: height
                )
                UIView.animate(withDuration: 0.25, animations: {
                    self.listView.frame = firstFrame
                }) { (_) in
                    self.listView.frame = secondFrame
                }
            }else {
                // oldValue = .hidden
                UIView.animate(withDuration: 0.25) {
                    var frame = self.originFrame
                    frame.y = ScreenHeight - frame.height
                    self.listView.frame = frame
                }
            }
        case .up:
            header.zkIV.isHidden = true
            var height: CGFloat = 0
            if #available(iOS 11.0, *) {
                height = view.safeAreaInsets.top
            } else {
                height = view.layoutMargins.top
            }
            let frame = CGRect(
                x: 0,
                y: height,
                width: ScreenWidth,
                height: ScreenHeight - height
            )
            UIView.animate(withDuration: 0.25) {
                self.listView.frame = frame
            }
        case .none:
            break
        }
    }
    
    //    MARK: - 懒加载
    // 地图
    lazy var mapView: MAMapView = {
        let mapView = MAMapView(frame: view.bounds)
        mapView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleHeight,
            UIView.AutoresizingMask.flexibleWidth
        ]
        mapView.setCenter(whlocation, animated: false)
        mapView.isShowsUserLocation = true
        mapView.zoomLevel = MapZoomLv.region.rawValue
        mapView.delegate = self
        return mapView
    }()
    
    // 内容视图
    lazy var listView: UIView = {
        let height: CGFloat = 60.0
        let view = UIView(frame: originFrame)
        let tView = UITableView(frame: .zero, style: .plain)
        tView.backgroundColor = .white
        tView.delegate = self
        tView.dataSource = self
        tView.dzy_registerCellNib(HouseListNormalCell.self)
        tView.dzy_registerCellNib(HouseListSuccessCell.self)
        view.addSubview(tView)
        self.tableView = tView
        
        header.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
        view.addSubview(header)
        
        header.snp.makeConstraints({ (make) in
            make.top.left.right.equalTo(view)
            make.height.equalTo(height)
        })
        
        tView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalTo(view)
            make.top.equalTo(header.snp.bottom)
        })
        return view
    }()
    
    // 头
    lazy var header: MapSearchHeaderView = {
        let hView = MapSearchHeaderView
            .initFromNib(MapSearchHeaderView.self)
        hView.isUserInteractionEnabled = true
        let upSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(upSwipeAction)
        )
        upSwipe.direction = .up
        hView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(downSwipeAction)
        )
        downSwipe.direction = .down
        hView.addGestureRecognizer(downSwipe)
        return hView
    }()
    
    // 小区的列表数据
    private lazy var cListView: UITableView = {
        let width: CGFloat = 70
        let frame = CGRect(x: ScreenWidth - width - 3,
                           y: 150, width: width, height: 300.0)
        let cView = UITableView(frame: frame, style: .plain)
        cView.backgroundColor = .white
        cView.delegate = self
        cView.dataSource = self
        cView.alpha = 0.7
        return cView
    }()
    
    //    MARK: - api
    /// 地图找房的主要接口
    private func searchApi() {
        let center = mapView.centerCoordinate
        let tZoomLv = zoomLv
        let request = BaseRequest()
        request.url = BaseURL.mapSearch
        request.dic = [
            "hierarchy" : tZoomLv.hierarchy(),
            "latitude"  : center.latitude,
            "longitude" : center.longitude,
            "radius"    : tZoomLv == .community ? 2000 : radius
        ]
        request.dzy_start { (data, _) in
            let list = data?.arrValue("list") ?? []
            if tZoomLv == .community && self.communityAnnos.count == 0 {
                ZKProgressHUD.show()
            }
            DispatchQueue.global().async {
                self.addAreaOrComunityAnnos(list, tZoomlv: tZoomLv)
            }
        }
    }
    
    /// 根据小区找房
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.mapHouseList
        request.dic = [
            "communityId" : communityId
        ]
        request.page = [page, 10]
        request.dzy_start { (data, _) in
            self.pageOperation(data: data,
                               isReload: page == 1 ? false : true)
            if page == 1 { // 只有在第一页的时候需要判断一下是否存在优显
                self.header.updateNumMsgUI(data ?? [:])
                if let relist = data?
                    .dicValue("reHouseList")?
                    .arrValue("list"),
                    relist.count > 0
                {
                    self.dataArr.insert(contentsOf: relist, at: 0)
                }
                self.tableView?.reloadData()
            }
        }
    }
}

//MARK: - MAMapViewDelegate
extension MapSearchVC: MAMapViewDelegate {

    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        computeTheCorner()
    }
    
    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool) {
        switch mapView.zoomLevel {
        case (mapView.minZoomLevel..<MapZoomLv.region.rawValue) where zoomLv != .city:
            cListView.isHidden = true
            zoomLv = .city
            mapView.removeAnnotations(regionAnnos)
            mapView.addAnnotations(cityAnnos)
        case (MapZoomLv.region.rawValue..<MapZoomLv.area.rawValue) where zoomLv != .region:
            cListView.isHidden = true
            zoomLv = .region
            mapView.removeAnnotations(cityAnnos)
            mapView.removeAnnotations(areaAnnos)
            mapView.addAnnotations(regionAnnos)
        case (MapZoomLv.area.rawValue..<MapZoomLv.community.rawValue) where zoomLv != .area:
            zoomLv = .area
            mapView.removeAnnotations(regionAnnos)
            mapView.removeAnnotations(communityAnnos)
            mapView.addAnnotations(areaAnnos)
            computeTheCorner()
            
            communityIds.removeAll()
            communityDatas.removeAll()
            communityAnnos.removeAll()
            communityModel = .zero
            cListView.isHidden = true
        case (MapZoomLv.community.rawValue...mapView.maxZoomLevel) where zoomLv != .community:
            if communityDatas.count <= 10 {
                cListView.isHidden = false
                cListView.reloadData()
            }else {
                cListView.isHidden = true
            }
            zoomLv = .community
            mapView.removeAnnotations(areaAnnos)
            mapView.addAnnotations(communityAnnos)
            computeTheCorner()
        default:
            break
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAUserLocation.self) {return nil}
        switch zoomLv {
        case .community:
            let indetifier = "community"
            var annoView = mapView
                .dequeueReusableAnnotationView(withIdentifier: indetifier)
                as? CommunityAnnotationView
            if annoView == nil {
                annoView = CommunityAnnotationView(
                    annotation: annotation, reuseIdentifier: indetifier
                )
            }
            if let anno = annotation as? CustomDataAnnotation,
                let data = anno.data {
                annoView?.updateUI(data)
            }
            annoView?.centerOffset = CGPoint(x: 0, y: -31)
            return annoView
        default:
            let indetifier = "circilar"
            var annoView = mapView
                .dequeueReusableAnnotationView(withIdentifier: indetifier)
                as? CircularAnnotationView
            if annoView == nil {
                annoView = CircularAnnotationView(
                    annotation: annotation, reuseIdentifier: indetifier
                )
            }
            if let anno = annotation as? CustomDataAnnotation,
                let data = anno.data {
                annoView?.updateUI(data)
            }
            return annoView
        }
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        switch zoomLv {
        case .city, .region, .area:
            if let data = (view as? CircularAnnotationView)?.data,
                let latitude = data.doubleValue("latitude"),
                let longitude = data.doubleValue("longitude")
            {
                var value: Double = 0
                switch zoomLv {
                case .city:
                    value = MapZoomLv.region.rawValue
                case .region:
                    value = MapZoomLv.area.rawValue
                case .area:
                    value = MapZoomLv.community.rawValue
                case .community:
                    break
                }
                mapView.setZoomLevel(value, animated: true)
                mapView.setCenter(
                    CLLocationCoordinate2D(
                        latitude: latitude, longitude: longitude
                    ),
                    animated: true
                )
            }
        case .community:
            if let view = view as? CommunityAnnotationView {
                currentCommuntiyView = view
                view.updateImg(true)
                communityAction(view.data)
            }
        }
    }
    
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        switch zoomLv {
        case .community:
            if let view = view as? CommunityAnnotationView {
                view.updateImg(false)
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        if listType == .down {
            listType = .hidden
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MapSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == cListView ? communityDatas.count : dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cListView {
            let name = communityDatas[indexPath.row]
                .stringValue("name")
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.textColor = Font_Dark
            cell.textLabel?.text = name
            cell.textLabel?.font = dzy_Font(10)
            return cell
        }else {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cListView {
            let data = communityDatas[indexPath.row]
            if let latitude = data.doubleValue("latitude"),
                let longitude = data.doubleValue("longitude")
            {
                mapView.setCenter(
                    CLLocationCoordinate2D(
                        latitude: latitude, longitude: longitude
                    ),
                    animated: true
                )
            }
        }else {
            goHouseDetail(false, house: dataArr[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == cListView {
            return 30
        }else {
            let data = dataArr[indexPath.row]
            return data.isOrderSuccess() ? 89 : 97
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView != cListView,
            listType == .up,
            scrollView.dzy_ofy <= -100
        {
            listType = .down
        }
    }
}

class CustomDataAnnotation: MAPointAnnotation {
    var data: [String : Any]?
}

extension MapSearchVC: HouseListNormalCellDelegate {
    func normalCell(_ normalCell: HouseListNormalCell,
                    didClickBidBtnWithHouse house: [String : Any])
    {
        goHouseDetail(true, house: house)
    }
    
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {
        
    }
}
