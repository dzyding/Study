//
//  LocationCityVC.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import SCIndexView

class LocationCityVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    /// 城市 keys
    private var cityKeys: [String] = []
    /// 热门城市
    private var hotList: [[String : Any]] = []
    /// 所有的城市
    private var citys: [String : [[String : Any]]] = [:]
    /// 当前城市
    private var currentCity: [String : Any] = [:]
    
    init(_ cityList: [[String : Any]]) {
        super.init(nibName: nil, bundle: nil)
        self.initDatas(cityList)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择城市"
        let height = header.updateUI(hotList, current: currentCity)
        header.frame = CGRect(x: 0, y: 0,
                              width: ScreenWidth, height: height)
        tableView.tableHeaderView = header
        header.snp.makeConstraints { (make) in
            make.top.left.equalTo(tableView)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(height)
        }
        
        tableView
            .dzy_registerHeaderFooterClass(LocationCityAbcHeader.self)
        tableView.dzy_registerCellNib(LocationCityCell.self)
        
        let configuration = SCIndexViewConfiguration(indexViewStyle: .default)
        configuration?.indicatorBackgroundColor = YellowMainColor
        configuration?.indicatorTextColor = BackgroundColor
        configuration?.indexItemTextColor = Text1Color
        configuration?.indexItemSelectedBackgroundColor = YellowMainColor
        configuration?.indexItemSelectedTextColor = BackgroundColor
        tableView.sc_indexViewConfiguration = configuration
        tableView.sc_indexViewDataSource = cityKeys
    }
    
    private func selectedCityAction(_ city: [String : Any]) {
        guard let cityCode = city.stringValue("code") else {
            ToolClass.showToast("城市数据错误", .Failure)
            return
        }
        LocationManager.locationManager.cityCode = cityCode
        NotificationCenter.default.post(
            name: Config.Notify_RefreshLocationCity,
            object: nil)
        dzy_pop()
    }
    
//    MARK: - 初始化
    private func initDatas(_ cityList: [[String : Any]]) {
        cityList.forEach { (city) in
            if let cityCode = city.stringValue("code"),
                let isHot = city.intValue("hot"),
                let letter = city.stringValue("letter")
            {
                if cityKeys.contains(letter) {
                    var temp = citys[letter]
                    temp?.append(city)
                    citys[letter] = temp
                }else {
                    cityKeys.append(letter)
                    citys[letter] = [city]
                }
                // 热门城市
                if isHot == 1 {
                    hotList.append(city)
                }
                // 当前城市
                if LocationManager.locationManager.cityCode == cityCode {
                    currentCity = city
                }
            }
        }
        cityKeys.sort()
    }
    
    private lazy var header: LocationCityTBHeaderView = {
        let view = LocationCityTBHeaderView.initFromNib()
        view.handler = { [weak self] city in
            self?.selectedCityAction(city)
        }
        return view
    }()
}

extension LocationCityVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cityKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = cityKeys[section]
        let arr = citys[key] ?? []
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = cityKeys[indexPath.section]
        let arr = citys[key] ?? []
        let cell = tableView.dzy_dequeueReusableCell(LocationCityCell.self)
        cell?.updateUI(arr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = cityKeys[section]
        let header = tableView
            .dzy_dequeueReusableHeaderFooter(LocationCityAbcHeader.self)
        header.updateUI(key)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = cityKeys[indexPath.section]
        let arr = citys[key] ?? []
        selectedCityAction(arr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
