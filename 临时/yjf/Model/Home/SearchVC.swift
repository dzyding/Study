//
//  SearchVC.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class SearchVC: BasePageVC, BaseRequestProtocol, JumpHouseDetailProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private var key: String
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topBgView: UIView!
    
    @IBOutlet weak var emptyView: UIView!
    
    private var timer: Timer? = nil
    // ***** 筛选
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
    
    init(_ key: String) {
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(HouseListNormalCell.self)
        tableView.dzy_registerCellNib(HouseListSuccessCell.self)
        setTitleView()
        setHeaderView()
        listAddHeader()
        listApi(1)
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
        tableView.visibleCells.forEach { (cell) in
            if let cell = cell as? HouseListNormalCell {
                cell.updatePriceAction(total)
            }
        }
    }
    
    func setHeaderView() {
        topBgView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.edges.equalTo(topBgView).inset(UIEdgeInsets.zero)
        }
    }
    
    func setTitleView() {
        navigationItem.titleView = titleView
        titleView.addSubview(inputTF)
        inputTF.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.bottom.right.equalTo(0)
        }
    }
    
    @objc private func editingChange(_ tf: UITextField) {
        key = tf.text ?? ""
    }
    
    @objc private func editingEnd(_ tf: UITextField) {
        key = tf.text ?? ""
        listApi(1)
    }
    
    //    MARK: - 懒加载
    private lazy var titleView: SearchTitleView = {
        let tView = SearchTitleView(
            frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 35.0)
        )
        tView.backgroundColor = dzy_HexColor(0xF5F5F5)
        tView.layer.cornerRadius = 3
        tView.layer.masksToBounds = true
        return tView
    }()
    
    lazy var inputTF: UITextField = {
        let tf = UITextField()
        tf.text = key
        tf.font = dzy_Font(13)
        tf.textColor = Font_Dark
        tf.clearButtonMode = .whileEditing
        tf.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
        tf.addTarget(self, action: #selector(editingChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(editingEnd(_:)), for: .editingDidEnd)
        return tf
    }()
    
    lazy var headerView: HomeSectionHeader = {
        let header = HomeSectionHeader.initFromNib(HomeSectionHeader.self)
        header.delegate = self
        return header
    }()
    /// 用来显示排序逻辑帅选的界面
    lazy var popView: HomePopView = {
        var frame = view.bounds
        frame.origin.y = 45
        frame.size.height -= 45
        let popView = HomePopView(frame: frame)
        popView.delegate = self
        return popView
    }()
    /// 区域的筛选界面
    private lazy var districtView: TwoTableFilterView = {
        let dView = TwoTableFilterView.initFromNib(TwoTableFilterView.self)
        dView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 292.0)
        dView.delegate = self
        return dView
    }()
    /// 户型的筛选界面
    private lazy var houseTypeView: CollectionFilterView = {
        let hView = CollectionFilterView.initFromNib(CollectionFilterView.self)
        hView.updateUI(.houseType)
        hView.delegate = self
        return hView
    }()
    /// 面积的筛选界面
    private lazy var areaView: CollectionFilterView = {
        let aView = CollectionFilterView.initFromNib(CollectionFilterView.self)
        aView.updateUI(.area)
        aView.delegate = self
        return aView
    }()
    /// 价格的筛选界面
    private lazy var priceView: CollectionFilterView = {
        let pView = CollectionFilterView.initFromNib(CollectionFilterView.self)
        pView.updateUI(.price)
        pView.delegate = self
        return pView
    }()
    
    /// 房源列表
    func listApi(_ page: Int) {
        var dic: [String : Any] = ["topNum" : 3]
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
        if key.count > 0 {
            dic.updateValue(key, forKey: "key")
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
                if let relist = data?.dicValue("reHouseList")?.arrValue("list"),
                    relist.count > 0
                {
                    self.dataArr.insert(contentsOf: relist, at: 0)
                }
                self.tableView.reloadData()
            }
            self.emptyView.isHidden = self.dataArr.count > 0
        }
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataArr[indexPath.row]
        return data.isOrderSuccess() ? 89 : 97
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        if data.isOrderSuccess() {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListSuccessCell.self)
            cell?.updateUI(data)
            return cell!
        }else {
            let cell = tableView
                .dzy_dequeueReusableCell(HouseListNormalCell.self)
            cell?.updateUI(data)
            cell?.delegate = self
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goHouseDetail(false, house: dataArr[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension SearchVC: HomeSectionHeaderDelegate {
    func header(header: HomeSectionHeader, didSelect type: String) {
        guard let type = FilterType(rawValue: type) else {return}
        tableView.setContentOffset(.zero, animated: false)
        tableView.isScrollEnabled = false
        
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

extension SearchVC: HomePopViewDelegate {
    func popViewDidDismiss(_ popView: HomePopView) {
        popBgClickDismiss()
        tableView.isScrollEnabled = true
    }
}

extension SearchVC: Searchable, CollectionFilterViewDelegate, TwoTableFilterViewDelegate
{
    var header: HomeSectionHeader {
        return headerView
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
    
    func cfView(
        _ cfView: CollectionFilterView,
        didClickSureBtnWithValue value: (Int, Int)?,
        showText str: String?,
        type: String
    ) {
        selectAreaAndPrice(value, str: str, type: type)
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickSureBtnWithStrings strings: [String]?) {
        selectRoomNum(strings)
    }
    
    func cfView(_ cfView: CollectionFilterView, didClickClearBtn btn: UIButton) {
        reset()
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
}

//MARK: - 我要竞价
extension SearchVC: HouseListNormalCellDelegate {
    func normalCell(
        _ normalCell: HouseListNormalCell,
        didClickBidBtnWithHouse house: [String : Any]
    ) {
        goHouseDetail(true, house: house)
    }
    
    func normalCell(_ normalCell: HouseListNormalCell, didSelect row: Int) {
        
    }
}

private class SearchTitleView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: ScreenWidth, height: 35.0)
    }
}
