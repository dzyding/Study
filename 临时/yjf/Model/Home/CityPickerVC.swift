//
//  CityPickerVC.swift
//  YJF
//
//  Created by edz on 2019/4/26.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

enum ChangeCityType {
    case regist // 注册
    case home       // 首页切换城市
    case home_init  // 首页 在没有城市的情况下，强制要求选择
}

class CityPickerVC: BaseVC {
    // 注册界面传过来的城市数据
    var registCityList: [String : Any]?
    
    private let type: ChangeCityType
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var nearbyCity: [String : Any] = [:]
    
    private var citys = [[[String : Any]]](repeating: [], count: 2)
    
    private var sections: [String] {
        switch type {
        case .home:
            return ["附近城市", "热门城市", "所有城市"]
        case .regist, .home_init:
            return ["热门城市", "所有城市"]
        }
    }
    
    // ***** 定位相关
    /// 定位信息
    private var location: DzyLLocationModel?
    
    private var isOut: Bool = false
    
    init(_ type: ChangeCityType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        apiFunc()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isOut && CLLocationManager.authorizationStatus() != .denied {
            isOut = false
            apiFunc()
        }
    }
    
    private func initUI() {
        collectionView.isHidden = true
        switch type {
        case .regist:
            navigationItem.title = "选择城市"
        default:
            navigationItem.title = "切换城市"
        }
        collectionView
            .dzy_registerCellFromNib(CityPickerCell.self)
        collectionView
            .dzy_registerCellFromNib(CityPickerTopCell.self)
        collectionView
            .dzy_registerCellFromNib(CityPickerHotCell.self)
        collectionView.dzy_registerHeaderFromNib(
            CityPickerTopSectionHeader.self)
    }
    
    private func checkLocationStatus() {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            let alert = dzy_normalAlert(
                "提示",
                msg: "为了获取您当前城市，需要您开启定位功能，是否立即前往？",
                sureClick:
            { [unowned self] (_) in
                self.goSetting()
            }, cancelClick: nil)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func goSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        {
            isOut = true
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
    private func apiFunc() {
        switch type {
        case .home:
            cityListApi()
            checkLocationStatus()
            locationAction()
        case .regist:
            initCitys(registCityList)
        case .home_init:
            cityListApi()
        }
    }
    
    private func changeSuccessFunc() {
        switch type {
        case .home:
            NotificationCenter.default.post(
                name: PublicConfig.Notice_ChangeCitySuccess,
                object: nil, userInfo: nil
            )
            dzy_pop()
        case .home_init:
            NotificationCenter.default.post(
                name: PublicConfig.Notice_InitCitySuccess,
                object: nil, userInfo: nil
            )
            dismiss(animated: true, completion: nil)
        case .regist:
            let vc = SelfTypeVC(.login)
            dzy_push(vc)
        }
    }
    
    // 初始化城市信息
    private func initCitys(_ data: [String : Any]?) {
        let hotList = data?.arrValue("numList") ?? []
        let cityList = data?.arrValue("regionList") ?? []
        citys[0] = hotList
        citys[1] = cityList
        collectionView.isHidden = false
        collectionView.reloadData()
    }
             
    //    MARK: - 定位
    private func locationAction() {
        let location = DzyLocationManager.default
        location.initStep(.kilometer, times: .once)
        location.locationHandler = { [weak self] model in
            if self?.location == nil && model != nil {
                self?.location = model
                self?.nearestCityApi(model!)
            }
        }
        location.start()
    }
    
    private func updateCityMsg(_ data: [String : Any]?, error: String?) {
        if let data = data?.dicValue("region") {
            nearbyCity = data
            collectionView.reloadData()
        }else {
            showMessage(error ?? "获取定位信息失败")
        }
    }
    
    //    MARK: - api
    /// 最近的城市
    private func nearestCityApi(_ location: DzyLLocationModel) {
        let request = BaseRequest()
        request.url = BaseURL.nearestCity
        request.dic = [
            "latitude" : location.latitude,
            "longitude" : location.longitude
        ]
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            self.updateCityMsg(data, error: error)
        }
    }
    
    /// 所有城市
    private func cityListApi() {
        let request = BaseRequest()
        request.url = BaseURL.cityList
        request.dzy_start { (data, _) in
            self.initCitys(data)
        }
    }
    
    /// 切换城市
    private func changeCityApi(_ city: String, cityId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.changeCity
        request.dic = ["city" : city]
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            if data != nil {
                RegionManager.save(city, cityId: cityId)
                self.changeSuccessFunc()
            }
        }
    }
}

extension CityPickerVC:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .home:
            return section == 0 ? 1 : citys[section - 1].count
        case .regist, .home_init:
            return citys[section].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize
    {
        return CGSize(width: ScreenWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize
    {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize
    {
        let width = ScreenWidth / 3.0
        switch indexPath.section {
        case 0:
            return CGSize(width: width, height: 45)
        case 1 where type == .home:
            return CGSize(width: width, height: 45)
        default:
            return CGSize(width: ScreenWidth, height: 47)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        switch section {
        case 1 where type == .home,
             0 where (type == .regist || type == .home_init):
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell
    {
        switch indexPath.section {
        case 0 where type == .home:
            let cell = collectionView
                .dzy_dequeueCell(CityPickerTopCell.self, indexPath)
            cell?.nameLB.text = nearbyCity.stringValue("name")
            return cell!
        case 1 where type == .home,
             0 where (type == .regist || type == .home_init):
            let cell = collectionView
                .dzy_dequeueCell(CityPickerHotCell.self, indexPath)
            let city = citys[0][indexPath.row].stringValue("name")
            cell?.nameLB.text = city
            return cell!
        default:
            let cell = collectionView
                .dzy_dequeueCell(CityPickerCell.self, indexPath)
            let city = citys[1][indexPath.row].stringValue("name")
            cell?.nameLB.text = city
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView
    {
        let header = collectionView.dzy_dequeueHeader(
            CityPickerTopSectionHeader.self,
            indexPath
        )
        header?.nameLB.text = sections[indexPath.section]
        return header!
    }
    
    func collectionView(_ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
        )
    {
        view.layer.zPosition = 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
        ) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        func baseFunc(_ data: [String : Any]) {
            if let city = data.stringValue("name"),
                let cityId = data.intValue("id")
            {
                changeCityApi(city, cityId: cityId)
            }
        }
        switch indexPath.section {
        case 0 where type == .home:
            baseFunc(nearbyCity)
        default:
            let section = type == .home ? (indexPath.section - 1) : indexPath.section
            let data = citys[section][indexPath.row]
            baseFunc(data)
        }
    }
}
