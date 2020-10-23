//
//  MapVC.swift
//  PPBody
//
//  Created by edz on 2018/12/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import AMapFoundationKit
import AMapSearchKit

class MapVC: BaseVC {
    // 地图
    private weak var mapView: MAMapView?
    // 中心的标记
    private weak var markView: MapMarkView?
    
    private weak var tableView: UITableView?
    
    private var datas: [AMapPOI] = []
    /// 是否为点击搜索时的查询
    private var isSearch: Bool = false
    
    private lazy var searchApi: AMapSearchAPI? = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    ///城市
    private var city: String? = RegionManager.city()
    /// 当前坐标点
    var current: CLLocationCoordinate2D?
    
    private weak var textField: UITextField?
    
    weak var infoVC: AddHouseInfoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let current = current {
            mapView?.setCenter(current, animated: false)
        }else {
            userLocation()
        }
        mapView?.setZoomLevel(16.0, animated: false)
        mapView?.delegate = self
    }
    
    //    MARK: - 输入监听
    @objc private func editingAction(_ tf: UITextField) {
        if let text = tf.text, text.count > 1 {
            isSearch = false
            searchCoreFun(text)
        }else {
            hideTableView()
        }
    }
    
    //    MARK: - 搜索
    @objc func searchLocation() {
        guard let address = textField?.text, address.count > 1 else {return}
        isSearch = true
        searchCoreFun(address)
    }
    
    private func searchCoreFun(_ key: String) {
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = key
        request.city = city
        request.types = "商务住宅|地名地址信息"
        request.cityLimit = true
        searchApi?.aMapPOIKeywordsSearch(request)
    }
    
    //    MARK: - 用户定位
    @objc func userLocation() {
        if let user = mapView?.userLocation.coordinate {
            current = user
            mapView?.setCenter(user, animated: true)
        }
    }
    
    //    MARK: - 保存
    @objc func saveAction() {
        guard let current = current else {return}
        infoVC?.updateLocationMsg(current)
        dzy_pop()
    }
    
    //    MARK: - 根据搜索结果进行展示
    private func showSearchResult(_ data: AMapPOI) {
        textField?.text = data.name
        textField?.resignFirstResponder()
        let latitude = data.location.latitude
        let longitude = data.location.longitude
        let location = CLLocationCoordinate2D(
            latitude: Double(latitude),
            longitude: Double(longitude)
        )
        mapView?.setCenter(location, animated: true)
        hideTableView()
    }
    
    //    MARK: - tableView的动画
    private func showTableView() {
        UIView.animate(withDuration: 0.5) {
            self.tableView?.alpha = 1
        }
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: 0.5) {
            self.tableView?.alpha = 0
        }
    }
    
    //    MARK: - UI
    //swiftlint:disable:next function_body_length
    private func setUI() {
        navigationItem.title = "地图定位"
        view.backgroundColor = .white
        
        let textField = UITextField()
        textField.textColor = Font_Dark
        textField.returnKeyType = .done
        textField.font = dzy_Font(14)
        textField.placeholder = "请输入小区名字"
        textField.addTarget(self, action: #selector(editingAction(_:)), for: .editingChanged)
        view.addSubview(textField)
        self.textField = textField
        
        let locationBtn = UIButton(type: .custom)
        locationBtn.setImage(UIImage(named: "map_search"), for: .normal)
        locationBtn.addTarget(self, action: #selector(searchLocation), for: .touchUpInside)
        view.addSubview(locationBtn)
        
        let mapView = MAMapView()
        mapView.isShowsUserLocation = true
        view.addSubview(mapView)
        self.mapView = mapView
        
        let markView = MapMarkView.initFromNib(MapMarkView.self)
        view.addSubview(markView)
        self.markView = markView
        
        let btn = UIButton(type: .custom)
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = MainColor
        btn.titleLabel?.font = dzy_FontBlod(16)
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        view.addSubview(btn)
        
        let user = UIButton(type: .custom)
        user.addTarget(self, action: #selector(userLocation), for: .touchUpInside)
        user.setImage(UIImage(named: "map_userLoc"), for: .normal)
        user.backgroundColor = .white
        user.layer.borderWidth = 1
        user.layer.borderColor = Font_Dark.cgColor
        view.addSubview(user)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.alpha = 0
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.dzy_registerCellClass(MapListCell.self)
        
        locationBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(view.dzyLayout.snp.top)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.height.equalTo(50)
            make.centerY.equalTo(locationBtn)
            make.right.equalTo(locationBtn.snp.left).offset(-10)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(view.dzyLayout.snp.top).offset(50)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mapView)
            make.height.equalTo(175)
        }
        
        markView.snp.makeConstraints { (make) in
            make.centerX.equalTo(mapView)
            make.centerY.equalTo(mapView).offset(-12)
            make.width.equalTo(50)
            make.height.equalTo(60)
        }
        
        btn.snp.makeConstraints { (make) in
            make.bottom.equalTo(mapView).offset(-40)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(49)
        }
        
        user.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.height.equalTo(40)
            make.bottom.equalTo(btn.snp.top).offset(-15)
        }
    }
}

extension MapVC: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        markView?.start()
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        markView?.end()
        current = mapView.region.center
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(
            withLatitude: CGFloat(mapView.region.center.latitude),
            longitude: CGFloat(mapView.region.center.longitude)
        )
        request.requireExtension = true
        searchApi?.aMapReGoecodeSearch(request)
    }
}

extension MapVC: AMapSearchDelegate {
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if isSearch {
            if let data = response.pois.first {
                showSearchResult(data)
            }
        }else {
            if tableView?.alpha == 0 {
                showTableView()
            }
            datas = response.pois ?? []
            tableView?.snp.updateConstraints({ (make) in
                make.height.equalTo(datas.count >= 5 ? 175 : datas.count * 35)
            })
            tableView?.reloadData()
        }
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let data = response.regeocode else {return}
        city = data.addressComponent.city
    }
}

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count > 5 ? 5 : datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MapListCell.self)
        cell?.titleLB.text = datas[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSearchResult(datas[indexPath.row])
    }
}
