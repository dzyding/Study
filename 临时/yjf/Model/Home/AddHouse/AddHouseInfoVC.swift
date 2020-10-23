//
//  AddHouseInfoVC.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD
import DzyImagePicker

//swiftlint:disable file_length
class AddHouseInfoVC: BaseVC {
    /// 获取最大图片数量
    let maxNum = PublicConfig.sysConfigIntValue(.addHouse_imageNum) ?? 10
    
    private let isEdited: Bool

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let lrPadding: CGFloat = 18.0
    
    private let inPadding: CGFloat = 5.0
    /// 户型图片
    var styleImg: (UIImage?, String?)?
    /// 所有的照片
    var houseImgs: [(UIImage?, String?)] = []
    /// 当前选中的cell
    private var currentIndex: IndexPath?
    ///当前输入框
    private weak var currentInput: HouseInfoInput?
    
    private var cityId: Int?
    private var city: String?
    /// 行政区
    var regionId: Int?
    private var regionDatas: [[String : Any]] = []
    /// 片区
    var districtId: Int?
    private var districtDatas: [[String : Any]] = []
    /// 小区
    var communityId: Int?
    var community: [String : Any]?
    private var communityDatas: [[String : Any]] = []
    
    /// 建成时间
    var buildTime: String = ""
    /// 定位
    var location: CLLocationCoordinate2D?
    /// 头部的信息视图
    var infoHeader: AddHouseInfoHeaderView?
    
    var type: AddHouseVCType {
        return (parent as? AddHouseBaseVC)?.type ?? .add
    }
    
    init(_ cityId: Int?, isEdited: Bool) {
        self.cityId = cityId
        self.isEdited = isEdited
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dzy_registerCellFromNib(AddImageCell.self)
        collectionView.dzy_registerHeaderFromNib(AddHouseInfoHeaderView.self)
        collectionView.dzy_registerHeaderFromNib(AddHousePhotoHeader.self)
        if !isEdited {
            regisonList(.region, isFirst: true)
        }
    }
    
    //    MARK: - 根据接口的 style 来设置门牌号的格式
    func updateHouseIdView(_ style: String?, ph: String?) {
        infoHeader?.updateHouseId(style, ph: ph)
    }
    
    func updateLocationMsg(_ location: CLLocationCoordinate2D) {
        self.location = location
        infoHeader?.mapBtn.isSelected = true
    }
    
    //    MARK: - 撤销的重新提交时，初始化视图
    //swiftlint:disable:next function_body_length
    func initUI(_ data: [String : Any]) {
        guard let header = infoHeader else {return}
        let house = data.dicValue("house") ?? [:]
        let regionDic  = data.dicValue("pRegion") ?? [:]
        let districtDic = data.dicValue("region") ?? [:]
        let communityDic = data.dicValue("community") ?? [:]
        
        // 获取城市，行政区，片区，小区 信息
        city = regionDic.stringValue("city")
        cityId = regionDic.intValue("pId")
        regionId = regionDic.intValue("id")
        regionDatas = RegionManager.list(cityId ?? 0)
        districtId = districtDic.intValue("id")
        districtDatas = RegionManager.list(regionId ?? 0)
        community = communityDic
        communityId = communityDic.intValue("id")
        communityDatas = RegionManager.list(districtId ?? 0)
        header.regionLBInput.setText(regionDic.stringValue("name"))
        header.districtLBInput.setText(districtDic.stringValue("name"))
        let communityStr = communityDic.stringValue("name")
        header.communityTFInput.setText(communityStr)
        
        // 门牌号
        let roomNum = house.stringValue("roomNum")
        if let house = communityDatas
            .first(where: {$0.stringValue("name") == communityStr})
        {
            let ph = house.stringValue("standard")
            updateHouseIdView(nil, ph: ph)
            header.houseIDView.set(roomNum ?? "")
        }else {
            updateHouseIdView(nil, ph: nil)
            header.houseIDView.set(roomNum ?? "")
        }
        
        // 户型
        let layout = house.stringValue("layout")
        header.layoutView.set(layout ?? "")
        
        // 面积
        header.areaTF.text = "\(house.doubleValue("area"), optStyle: .price)"
        
        // 楼层
        let floor = house.intValue("floor") ?? 0
        let totalFloor = house.intValue("totalFloor") ?? 0
        header.currentFloorTF.text = "\(floor)"
        header.totalFloorTF.text = "\(totalFloor)"
        
        // 电梯
        let lift = house.intValue("lift") ?? 0
        header.liftLBInput.setText("\(lift)部")
        
        // 装修
        let renovation = house.stringValue("renovation")
        header.decorateLBInput.setText(renovation)
        
        // 朝向
        let orientation = house.stringValue("orientation")
        header.towardLBInput.setText(orientation)
        
        // 建成时间
        let year =  house.stringValue("year")
        if let year = year?.components(separatedBy: " ").first,
            year.count > 3
        {
            buildTime = year
            let index = year.index(year.startIndex, offsetBy: 2)
            let yearStr = String(year[index...])
            header.buildtimeLBInput.setText(yearStr)
        }
        
        // 产权
        let property = house.stringValue("property")
        header.propertyLBInput.setText(property)
        
        //  用途
        let purpose = house.stringValue("purpose")
        header.useLBInput.setText(purpose)
        
        // 户型
        if let styleImgUrl = house.stringValue("cover"),
            styleImgUrl.count > 0
        {
            styleImg = (nil, styleImgUrl)
        }
        
        let imgs = (house["imgs"] as? [String]) ?? []
        let userImgs = (house["userImgs"] as? [String]) ?? []
        let result = imgs.count > 0 ? imgs : userImgs
        // 房屋照片
        if result.count > 0 {
            (0..<result.count).forEach { (index) in
                let imgUrl = result[index]
                houseImgs.append((nil, imgUrl))
            }
        }
        
        if let latitude = house.doubleValue("latitude"),
            let longitude = house.doubleValue("longitude")
        {
            location = CLLocationCoordinate2D(
                latitude: latitude, longitude: longitude
            )
            header.mapBtn.isSelected = true
        }
        collectionView.reloadData()
    }

    //    MAKR: - 获取数据成功以后
    private func requestRegionListSuccess(_ type: HouseInfoInputType, list: [[String : Any]]) {
        switch type {
        case .region:
            districtDatas = list
            communityDatas = []
        case .district:
            communityDatas = list
        default:
            break
        }
    }
    
    //    MARK: - 获取数据
    private func regisonList(_ type: HouseInfoInputType, isFirst: Bool) {
        guard let pid = isFirst ? cityId : getPid(type) else {return}
        func baseFunc(_ list: [[String : Any]]) {
            if isFirst {
                // 第一次进入当前界面
                regionDatas = list
            }else {
                requestRegionListSuccess(type, list: list)
            }
        }
        // 这个全部数据的接口加载有点慢，如果还没返回，则调用单独的接口
        if RegionManager.isEmpty() {
            let dic = [
                "pid" : pid,
                "type" : type == .district ? 30 : 10
            ]
            regionListApi(dic) { (list) in
                baseFunc(list)
            }
        }else {
            baseFunc(RegionManager.list(pid))
        }
    }
    
    private func regionListApi(
        _ dic: [String : Any], complete: @escaping ([[String : Any]])->()
        ) {
        let request = BaseRequest()
        request.url = BaseURL.regionList
        request.dic = dic
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            guard error == nil else {
                self.showMessage(error!)
                return
            }
            if let list = data?.arrValue("list") {
                complete(list)
            }else {
                self.showMessage("获取地理数据失败")
            }
        }
    }
    
    private func getPid(_ type: HouseInfoInputType) -> Int? {
        switch type {
        case .region:
            return regionId
        case .district:
            return districtId
        default:
            return nil
        }
    }
    
    //    MARK: - 懒加载
    /// pop
    private lazy var sheetView: ActionSheetView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200.0)
        let sheet = ActionSheetView(frame: frame)
        sheet.delegate = self
        return sheet
    }()
    
    /// 日期选择
    private lazy var datePicker: DatePickerView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200.0)
        let picker = DatePickerView(frame: frame)
        picker.delegate = self
        return picker
    }()
    
    private lazy var popView: DzyPopView = {
        let pop = DzyPopView(.POP_bottom)
        pop.bgDismissHandler = { [weak self] in
            self?.currentInput?.closeAcion()
        }
        return pop
    }()
}

extension AddHouseInfoVC:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return houseImgs.count >= maxNum ? houseImgs.count : (houseImgs.count + 1)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (ScreenWidth - 2 * (lrPadding + inPadding)) / 3.0
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(AddImageCell.self, indexPath)
        if indexPath.section == 0 {
            cell?.updateUI(styleImg, indexPath: indexPath)
        }else {
            if indexPath.row >= houseImgs.count {
                cell?.updateUI(nil, indexPath: indexPath)
            }else {
                cell?.updateUI(
                    houseImgs[indexPath.row], indexPath: indexPath
                )
            }
        }
        cell?.delegate = self
        return cell!
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 {
            return CGSize(width: ScreenWidth, height: type == .edit ? 560 : 620)
        }else {
            return CGSize(width: ScreenWidth, height: 54.0)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView
                .dzy_dequeueHeader(AddHouseInfoHeaderView.self, indexPath)
            infoHeader = header
            infoHeader?.priceView.isHidden = type == .edit
            header?.delegate = self
            return header!
        }else {
            let header = collectionView
                .dzy_dequeueHeader(AddHousePhotoHeader.self, indexPath)
            header?.updateUI(maxNum)
            return header!
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: lrPadding, bottom: 0, right: lrPadding)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return inPadding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return inPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath
        if indexPath.section == 0 {
            if let img = styleImg?.0 {
                let view = DzyShowImageView(.image(img))
                view.show()
            }else if let url = styleImg?.1 {
                let view = DzyShowImageView(.one(url))
                view.show()
            }else {
                let picker = DzyImagePickerVC(.origin(.single))
                picker.delegate = self
                let vc = BaseNavVC(rootViewController: picker)
                present(vc, animated: true, completion: nil)
            }
        }else {
            if indexPath.row == houseImgs.count {
                let max = maxNum - houseImgs.count
                let picker = DzyImagePickerVC(.origin(.several(max)))
                picker.delegate = self
                let vc = BaseNavVC(rootViewController: picker)
                present(vc, animated: true, completion: nil)
            }else {
                if let img = houseImgs[indexPath.row].0 {
                    let view = DzyShowImageView(.image(img))
                    view.show()
                }else if let url = houseImgs[indexPath.row].1 {
                    let view = DzyShowImageView(.one(url))
                    view.show()
                }
            }
        }
    }
}

//MARK: -
extension AddHouseInfoVC: DzyImagePickerVCDelegate {
    func imagePicker(_ picker: DzyImagePickerVC?, getOriginImage image: UIImage) {
        styleImg = (image, nil)
        collectionView.reloadData()
    }
    
    func selectedFinshAndBeginDownload(_ picker: DzyImagePickerVC?) {
        
    }
    
    func imagePicker(_ picker: DzyImagePickerVC?, getImages imgs: [UIImage]) {
        imgs.forEach { (image) in
            houseImgs.append((image, nil))
        }
        collectionView.reloadData()
    }
    
    func imagePicker(_ picker: DzyImagePickerVC?, getCropImage image: UIImage) {}
}

//MARK - DatePickerViewDelegate
extension AddHouseInfoVC: DatePickerViewDelegate {
    func datePicker(_ datePicker: DatePickerView, didClickCancelBtn btn: UIButton) {
        currentInput?.closeAcion()
    }
    
    func datePicker(_ datePicker: DatePickerView, didSelectDateString str: String) {
        popView.hide()
        buildTime = str
        let result = str[str.index(str.startIndex, offsetBy: 2)...]
        currentInput?.setText(String(result))
    }
}

//MARK: - AddHouseInfoHeaderViewDelegate
extension AddHouseInfoVC: AddHouseInfoHeaderViewDelegate {
    
    func infoView(_ infoView: AddHouseInfoHeaderView, didEndEditing textField: UITextField) {
        let name = textField.text
        if let community = communityDatas
            .first(where: {$0.stringValue("name") == name}),
            let ph = community.stringValue("standard")
        {
            self.community = community
            updateHouseIdView(nil, ph: ph)
        }else {
            community = nil
            updateHouseIdView(nil, ph: nil)
        }
    }
    
    func infoView(_ infoView: AddHouseInfoHeaderView, didClickMapBtn btn: UIButton) {
        let vc = MapVC()
        vc.infoVC = self
        if let community = community,
            let latitude = community.doubleValue("latitude"),
            let longitude = community.doubleValue("longitude")
        {
            vc.current = CLLocationCoordinate2D(
                latitude: latitude, longitude: longitude
            )
        }
        dzy_push(vc)
    }
    
    //swiftlint:disable:next cyclomatic_complexity function_body_length
    func infoView(
        _ infoView: AddHouseInfoHeaderView,
        didSelectInput input: HouseInfoInput
    ) {
        guard let type = HouseInfoInputType(rawValue: input.tag) else {return}
        currentInput = input
        if type == .buildtime {
            popView.updateSourceView(datePicker)
            popView.show()
            return
        }
        switch type {
        case .region:
            sheetView.updateUI(
                regionDatas.compactMap({$0.stringValue("name")})
            )
        case .district:
            if infoView.regionLBInput.getText().count == 0 {
                infoView.districtLBInput.closeAcion()
                showMessage("请先选择行政区")
                return
            }else {
                sheetView.updateUI(
                    districtDatas.compactMap({$0.stringValue("name")})
                )
            }
        case .community:
            if infoView.districtLBInput.getText().count == 0 {
                infoView.communityTFInput.closeAcion()
                showMessage("请先选择片区")
                return
            }else {
                sheetView.updateUI(
                    communityDatas.compactMap({$0.stringValue("name")})
                )
            }
        case .lift:
            sheetView.updateUI((0...10).map({"\($0)部"}))
        case .decorate:
            sheetView.updateUI(["精装", "平装", "简装", "毛坯"])
        case .toward:
            sheetView.updateUI(["东", "南", "西", "北", "东南", "东北", "西南", "西北", "东西", "南北"])
        case .property:
            sheetView.updateUI(["完全产权", "小产权"])
        case .use:
            sheetView.updateUI(["住宅", "非住宅"])
        default:
            break
        }
        if sheetView.checkEmpty() {
            currentInput?.closeAcion()
            showMessage("暂无数据")
        }else {
            popView.updateSourceView(sheetView)
            popView.show()
        }
    }
}

//MARK: - ActionSheetViewDelegate
extension AddHouseInfoVC: ActionSheetViewDelegate {

    func sheetView(_ sheetView: ActionSheetView, didClickCancelBtn btn: UIButton) {
        currentInput?.closeAcion()
    }
    
    func sheetView(_ sheetView: ActionSheetView, didSelectString str: String) {
        popView.hide()
        currentInput?.setText(str)
        guard let tag = currentInput?.tag,
            let type = HouseInfoInputType(rawValue: tag)
            else {return}
        switch type {
        case .region:
            regionId = regionDatas
                .filter({$0.stringValue("name") == str})
                .first?.intValue("id")
            regisonList(type, isFirst: false)
            infoHeader?.districtLBInput.setText(nil)
            infoHeader?.communityTFInput.setText(nil)
        case .district:
            districtId = districtDatas
                .filter({$0.stringValue("name") == str})
                .first?.intValue("id")
            regisonList(type, isFirst: false)
            infoHeader?.communityTFInput.setText(nil)
        case .community:
            if let community = communityDatas
                .filter({$0.stringValue("name") == str}).first,
                let cid = community.intValue("id")
            {
                self.community = community
                communityId = cid
                // 手动输入
                if let ph = community.stringValue("doorNumEg") {
                    updateHouseIdView(nil, ph: "例如：" + ph)
                }else {
                    updateHouseIdView(
                        nil,
                        ph: community.stringValue("standard")
                    )
                }
            }
        default:
            break
        }
    }
}

//MARK: - AddImageCellDelegate
extension AddHouseInfoVC: AddImageCellDelegate {
    func imageCell(_ imageCell: AddImageCell, didClickDelBtn btn: UIButton) {
        if let index = imageCell.indexPath {
            if index.section == 0 {
                styleImg = nil
            }else {
                houseImgs.remove(at: index.row)
            }
            collectionView.reloadData()
        }
    }
}
