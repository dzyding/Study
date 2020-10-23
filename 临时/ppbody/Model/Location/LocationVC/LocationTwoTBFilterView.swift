//
//  LocationTwoTBFilterView.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LocationTwoTBFilterViewDelegate: class {
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    didSelectedRegion regionId: Int,
                    regionName: String)
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    didSelectedMetro latitude: Double,
                    longitude: Double,
                    metroName: String)
    func twoTbFView(_ twoTbFView: LocationTwoTBFilterView,
                    willRemoveFromSuperView view: UIView?)
    func didCleanFilterKey(_ twoTbFView: LocationTwoTBFilterView)
}

class LocationTwoTBFilterView: UIView, InitFromNibEnable, ShowInViewProtocol {
    
    weak var delegate: LocationTwoTBFilterViewDelegate?
    
    var isShow: Bool = false {
        willSet {
            if !newValue {
                delegate?.twoTbFView(self,
                                     willRemoveFromSuperView: nil)
            }
        }
    }
    
    var originFrame = CGRect(x: 0, y: 0,
                             width: ScreenWidth, height: 375.0)
    
    @IBOutlet weak var leftTableView: UITableView!
    
    @IBOutlet weak var rightTableView: UITableView!
    
    private var currentIndex = 0
    /// 选中的第二个数据
    private var sSecondMsg: [String : Any] = [:]
    
    private var leftDatas: [[String : Any]] {
        get {
            return currentIndex == 0 ? regions : metros
        }
        set {
            if currentIndex == 0 {
                regions = newValue
            }else {
                metros = newValue
            }
        }
    }
    
    private var rightDatas: [[String : Any]] {
        get {
            return leftDatas
                .first(where: {$0.boolValue(SelectedKey) == true})?
                .arrValue("list") ?? []
        }
        set {
            if let index = leftDatas.firstIndex(where: {$0.boolValue(SelectedKey) == true})
            {
                leftDatas[index]["list"] = newValue
            }
        }
    }
    
    private var regions: [[String : Any]] = []
    
    private var metros: [[String : Any]] = []
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        scale()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        original()
    }
    
//    MARK: - 初始化、刷新UI
    func initUI() {
        layer.masksToBounds = true
        addSubview(btnsView)
        [leftTableView, rightTableView].forEach { (tb) in
            tb?.delegate = self
            tb?.dataSource = self
            tb?.dzy_registerCellNib(LocationTwoTBFilterCell.self)
        }
    }
    
    func updateUI(_ regions: [[String : Any]],
                  metros: [[String : Any]])
    {
        self.regions = regions
        self.metros = metros
        leftTableView.reloadData()
        rightTableView.reloadData()
    }
    
//    MARK: - 切换类型
    private func selectType(_ index: Int) {
        currentIndex = index
        leftTableView.reloadData()
        rightTableView.reloadData()
    }
    
//    MARK: - 检查两个数据是否为同一个
    private func checkTwoDataIsSame(_ left: [String : Any],
                                    right: [String : Any]) -> Bool
    {
        if left.stringValue("name") == "全部" {
            return (left.stringValue("name") == right.stringValue("name")) &&
            (left.intValue("index") == right.intValue("index"))
        }else {
            return (left.intValue("id") == right.intValue("id")) &&
            (left.stringValue("name") == right.stringValue("name"))
        }
    }
    
//    MARK: - 将另一边的所有选中改成未选中
    private func updateOtherSideData() {
        let handler: (([String : Any]) -> [String : Any]) = { origin in
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
        if currentIndex == 0 {
            metros = metros.map(handler)
        }else {
            regions = regions.map(handler)
        }
    }
    
//    MARK: - 懒加载
    private lazy var btnsView: ScrollBtnView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 45.0)
        let view = ScrollBtnView(.scale, frame: frame) { [weak self] (index) in
            self?.selectType(index)
        }
        view.btns = ["商圈", "地铁"]
        view.font = dzy_Font(14)
        view.selectedFont = dzy_Font(14)
        view.normalColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.6)
        view.selectedColor = .white
        view.backgroundColor = BackgroundColor
        view.lineColor = YellowMainColor
        view.lineToBottom = 0
        view.updateUI()
        return view
    }()
}

extension LocationTwoTBFilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == leftTableView ? leftDatas.count : rightDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datas = tableView == leftTableView ? leftDatas : rightDatas
        let cell = tableView
            .dzy_dequeueReusableCell(LocationTwoTBFilterCell.self)
        cell?.updateUI(datas[indexPath.row],
                       isRight: tableView == rightTableView)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == rightTableView {
            dismiss()
            rightDatas = rightDatas.map({
                var temp = $0
                temp[SelectedKey] = false
                return temp
            })
            rightDatas[indexPath.row][SelectedKey] = true
            sSecondMsg = rightDatas[indexPath.row]
            
            if currentIndex == 0 {
                if sSecondMsg.stringValue("name") == "全部" {
                    if let reigon = regions
                        .first(where: {$0.boolValue(SelectedKey) == true}),
                        let id = reigon.intValue("id"),
                        let name = reigon.stringValue("name")
                    {
                        delegate?.twoTbFView(self,
                                             didSelectedRegion: id,
                                             regionName: name)
                    }
                }else {
                    if let id = sSecondMsg.intValue("id"),
                        let name = sSecondMsg.stringValue("name")
                    {
                        delegate?.twoTbFView(self,
                                             didSelectedRegion: id,
                                             regionName: name)
                    }
                }
            }else {
                if let latitude = sSecondMsg.doubleValue("latitude"),
                    let longitude = sSecondMsg.doubleValue("longitude"),
                    let name = sSecondMsg.stringValue("name")
                {
                    delegate?.twoTbFView(self,
                                         didSelectedMetro: latitude,
                                         longitude: longitude,
                                         metroName: name)
                }
            }
        }else {
            if leftDatas[indexPath.row].stringValue("name") == "全部" {
                sSecondMsg = [:]
                delegate?.didCleanFilterKey(self)
                dismiss()
            }
            leftDatas = leftDatas.map({
                var temp = $0
                temp[SelectedKey] = false
                if let list = temp.arrValue("list") {
                    temp["list"] = list.map { (value) -> [String : Any] in
                        var stemp = value
                        stemp[SelectedKey] = checkTwoDataIsSame(stemp, right: sSecondMsg)
                        return stemp
                    }
                }
                return temp
            })
            leftDatas[indexPath.row][SelectedKey] = true
        }
        updateOtherSideData()
        leftTableView.reloadData()
        rightTableView.reloadData()
    }
}
