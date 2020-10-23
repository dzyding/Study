//
//  AddHouseBaseVC.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum AddHouseVCType {
    case add
    case edit
}

class AddHouseBaseVC: ScrollBtnVC {
    
    let type: AddHouseVCType
    
    override var btnsViewHeight: CGFloat {
        return 52
    }
    
    override var normalFont: UIFont {
        return dzy_FontBlod(13)
    }
    
    override var selectedFont: UIFont {
        return dzy_FontBlod(15)
    }
    
    override var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    override var selectedColor: UIColor {
        return Font_Dark
    }
    
    override var leftPadding: CGFloat {
        return 20.0
    }
    
    override var rightPadding: CGFloat {
        return 20.0
    }
    
    override var lineToBottom: CGFloat {
        return 12.0
    }
    
    override var bottomHeight: CGFloat {
        switch type {
        case .add:
            return IS_IPHONEX ? 66.0 : 100.0
        case .edit:
            return IS_IPHONEX ? 126.0 : 160.0
        }
        
    }
    
    override var titles: [String] {
        return ["房源信息", "房源证件照", "家具电器清单"]
    }
    /// 市id
    var cityId: Int?
    /// 房源 id (重新发布的时候需要)
    var houseId: Int?
    
    init(_ cityId: Int?, type: AddHouseVCType = .add) {
        self.type = type
        self.cityId = cityId
        super.init(.topTop)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getVCs() -> [UIViewController] {
        return [
            AddHouseInfoVC(cityId, isEdited: houseId != nil),
            AddHousePhotoVC(),
            AddHouseFurnitureVC()
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = type == .add ? "添加房源" : "修改房源"
        view.backgroundColor = .white
        updateVCs()
        setBottomView()
        if let houseId = houseId {
            houseDetailApi(houseId)
        }
        // 从实名认证的界面过来的
        if let index = navigationController?
            .viewControllers
            .firstIndex(where: {$0 is EditMyInfoVC})
        {
            navigationController?.viewControllers.remove(at: index)
        }
    }
    
    //    MARK: - 撤销的重新提交时，初始化视图
    private func initUI(_ data: [String : Any]) {
        if let infoVC = children[0] as? AddHouseInfoVC {
            infoVC.initUI(data)
        }
        
        if let photoVC = children[1] as? AddHousePhotoVC,
            let cert = data.dicValue("houseCert")
        {
            photoVC.initUI(cert)
        }
        
        if let fvc = children[2] as? AddHouseFurnitureVC,
            let equipList = data.arrValue("equipList")
        {
            fvc.initUI(equipList)
        }
    }
    
    //    MARK: - 取消
    @objc private func cancelAction() {
        dzy_pop()
    }
    
    //    MARK: - 确定
    @objc private func sureAction() {
        var dic: [String : Any] = [:]
        if let houseId = houseId {
            dic.updateValue(houseId, forKey: "id")
        }
        guard checkInfoVC(&dic) else {return}
        guard checkPhotoVC(&dic) else {return}
        guard checkFurnitureVC(&dic) else {return}
        let city = RegionManager.city()
        dic.updateValue(city, forKey: "city")
        DataManager.staffMsg().flatMap({
            dic.merge($0, uniquingKeysWith: {$1})
        })
        switch type {
        case .add:
            let vc = SellerQualificationVC(dic)
            dzy_push(vc)
        case .edit:
            let vc = ImageVerifyVC(dic)
            dzy_push(vc)
        }
        
    }
    
    //    MARK: - 获取 infoVC 的数据
    //swiftlint:disable:next function_body_length cyclomatic_complexity
    private func checkInfoVC(_ dic: inout [String : Any]) -> Bool {
        guard let infoVC = children[0] as? AddHouseInfoVC,
            let header = infoVC.infoHeader
        else {return false}
        let region = header.regionLBInput.getText()
        guard region.count > 0, let regionId = infoVC.regionId else {
            showMessage("请选择行政区")
            return false
        }
        let district = header.districtLBInput.getText()
        guard district.count > 0, let districtId = infoVC.districtId else {
            showMessage("请选择片区")
            return false
        }
        // 区+片区
        let str = region + "-" + district
        dic.updateValue(str, forKey: "region")
        dic.updateValue(regionId, forKey: "regionId")
        dic.updateValue(districtId, forKey: "districtId")
        let community = header.communityTFInput.getText()
        guard community.count > 0 else {
            showMessage("请选择或输入小区")
            return false
        }
        dic.updateValue(community, forKey: "community")
        if community == infoVC.community?.stringValue("name"),
            let cid = infoVC.communityId
        {
            dic.updateValue(cid, forKey: "communityId")
        }
        guard let houseNumStr = header.houseIDView.getStr(),
            houseNumStr.count > 0
        else {
            showMessage("请填写门牌号")
            return false
        }
        dic.updateValue(houseNumStr, forKey: "roomNum")
        // 户型
        if let layout = header.layoutView.getStr() {
            dic.updateValue(layout, forKey: "layout")
        }
        // 面积
        if let area = header.areaTF.text, area.count > 0 {
            dic.updateValue(area, forKey: "area")
        }
        // 所在楼层
        if let currentFloor = header.currentFloorTF.text,
            currentFloor.count > 0
        {
            dic.updateValue(currentFloor, forKey: "floor")
        }
        // 楼层总数
        if let totalFloor = header.totalFloorTF.text,
            totalFloor.count > 0
        {
            dic.updateValue(totalFloor, forKey: "totalFloor")
        }
        
        // 电梯数量
        var lift = header.liftLBInput.getText()
        if lift.count > 0 {
            //删除掉 "部" 字
            lift.removeLast()
            dic.updateValue(lift, forKey: "lift")
        }

        // 装修类型
        let decorate = header.decorateLBInput.getText()
        if decorate.count > 0 {
            dic.updateValue(decorate, forKey: "renovation")
        }
        
        // 朝向
        let toward = header.towardLBInput.getText()
        if toward.count > 0 {
            dic.updateValue(toward, forKey: "orientation")
        }

        // 建成时间
        let buildTime = infoVC.buildTime
        if buildTime.count > 0 {
            dic.updateValue(buildTime, forKey: "year")
        }

        // 产权类型
        let property = header.propertyLBInput.getText()
        if property.count > 0 {
            dic.updateValue(property, forKey: "property")
        }

        // 设计用途
        let use = header.useLBInput.getText()
        if use.count > 0 {
            dic.updateValue(use, forKey: "purpose")
        }
        
        // 户型图片
        if let styleImage = infoVC.styleImg {
            dic.updateValue(styleImage, forKey: "cover")
        }

        // 房屋照片
        if infoVC.houseImgs.count > infoVC.maxNum {
            showMessage("最多允许上传\(infoVC.maxNum)张图片，请删除过多的图片。")
            return false
        }
        
        if infoVC.houseImgs.count > 0 {
            dic.updateValue(infoVC.houseImgs, forKey: "userImgs")
        }
        
        // 定位
        if let location = infoVC.location {
            dic.updateValue(location.latitude, forKey: "latitude")
            dic.updateValue(location.longitude, forKey: "longitude")
        }
        return true
    }
    
    //    MARK: - 获取 photoVC 的数据
    private func checkPhotoVC(_ dic: inout [String : Any]) -> Bool {
        guard let photoVC = children[1] as? AddHousePhotoVC else {return false}
        // 房产证照片
        let ownerCers = photoVC.imgs[0].filter({$0 != nil})
        if ownerCers.count > 0 {
            dic.updateValue(ownerCers, forKey: "propertyCert")
        }
        
        // 房主身份证照片正面
        if let ownerIdLeft = photoVC.imgs[1][0] {
            dic.updateValue(ownerIdLeft, forKey: "ownerIdP")
        }

        // 房主身份证照片背面
        if let ownerIdRight = photoVC.imgs[1][1] {
            dic.updateValue(ownerIdRight, forKey: "ownerIdN")
        }
        
        if photoVC.type == .agent {
            // 卖房委托书
            if let agentCer = photoVC.imgs[2][0] {
                dic.updateValue(agentCer, forKey: "auth")
            }

            // 卖方身份证照片正面
            if let agentIdLeft = photoVC.imgs[3][0] {
                dic.updateValue(agentIdLeft, forKey: "agentIdP")
            }
            
            // 卖方身份证照片背面
            if let agentIdRight = photoVC.imgs[3][1] {
                dic.updateValue(agentIdRight, forKey: "agentIdN")
            }
        }
        return true
    }
    
    //    MARK: - 获取家具数据
    private func checkFurnitureVC(_ dic: inout [String : Any]) -> Bool {
        guard let furnitureVC = children[2] as? AddHouseFurnitureVC else {return false}
        // 家具
        if furnitureVC.datas.count > 0 {
            let datas = furnitureVC.datas.map({$0.0})
            let equipAll = ToolClass.toJSONString(dict: datas)
            dic.updateValue(equipAll, forKey: "equipAll")
        }
        return true
    }
    
    //    MARK: - UI
    private func setBottomView() {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle(type == .add ? "添加房源" : "保存修改", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.backgroundColor = MainColor
        sureBtn.titleLabel?.font = dzy_FontBlod(16)
        sureBtn.layer.cornerRadius = 3
        sureBtn.layer.masksToBounds = true
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        bottomView.addSubview(sureBtn)
        
        let height = type == .add ? 100.0 : 160.0
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(height)
        }
        
        let sureBottom = type == .add ? -40 : -100
        sureBtn.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(49)
            make.bottom.equalTo(sureBottom)
        }
        
        if type == .edit {
            let cancelBtn = UIButton(type: .custom)
            cancelBtn.setTitle("放弃修改", for: .normal)
            cancelBtn.setTitleColor(MainColor, for: .normal)
            cancelBtn.backgroundColor = .white
            cancelBtn.titleLabel?.font = dzy_FontBlod(16)
            cancelBtn.layer.cornerRadius = 3
            cancelBtn.layer.masksToBounds = true
            cancelBtn.layer.borderWidth = 1
            cancelBtn.layer.borderColor = MainColor.cgColor
            cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            bottomView.addSubview(cancelBtn)
            
            cancelBtn.snp.makeConstraints { (make) in
                make.left.right.height.equalTo(sureBtn)
                make.bottom.equalTo(-40)
            }
        }
    }
    
    //    MARK: - api
    private func houseDetailApi(_ houseId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.releaseUndoDetail
        request.dic = ["houseId" : houseId]
        request.dzy_start { [weak self] (data, _) in
            self?.initUI(data ?? [:])
        }
    }
}
