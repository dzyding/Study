//
//  WatchHouseVC.swift
//  YJF
//
//  Created by edz on 2019/5/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import CoreBluetooth
import DzyImagePicker
import ZKProgressHUD

public let DzyQuqipKey = "report"

private enum OpenMsg: String {
    /// 提示开启蓝牙
    case goSetting = "需开启蓝牙进行开门操作，是否前往？"
    /// 开锁中
    case opening = "蓝牙开锁中，请稍后"
    /// 不支持蓝牙
    case btDisable = "蓝牙无法使用，即将尝试密码开锁，获取定位中"
    /// 蓝牙开锁失败
    case btFail = "蓝牙开锁失败，即将尝试密码开锁，获取定位中"
}

//swiftlint:disable file_length type_body_length
class WatchHouseVC: BaseVC, CustomBackProtocol, CheckLockDestroyProtocol {
    /// 身份
    private var identity: Identity = .buyer
    /// 门锁的code(包含url的)
    var code: String?
    /// 房源id
    var houseId: Int?
    /// 看房信息(如果已经在看房，会直接传进来)
    var lookInfo: [String : Any]?
    /// 房源信息
    private var house: [String : Any]?
    /// 家具列表
    private var equipList: [[String : Any]] = []
    /// 提交的图片
    private var imgs: [(UIImage?, String?)] = []
    /// 买家当前选择的 row
    private var buyerCurRow: Int = 0
    /// 门锁的编号 (不包含 url 的纯的code)
    private var lockCode: String?
    
    /// 是否展开 cell
    private var sectionOpen = true {
        didSet {
            sectionHeader.updateUI(sectionOpen)
        }
    }
    /// 是否已经开门
    private var isOpen = false
    /// 是否已经尝试蓝牙
    private var isTryBt = false
    /// 尝试蓝牙开锁，是否成功连接
    private var connect = false
    /// 是否已经尝试密码开锁
    private var isTryCode = false
    /// 回显的 remark
    private var remark: String?
    /// 回显的 price
    private var price: Double?
    
    /// 显示滚动价格的 timer
    private var timer: Timer? = nil
    
    ///
    @IBOutlet weak var tableView: UITableView!
    /// 倒计时界面的高度
    private var timeHeight: CGFloat = 128.0
    
    private var observer: Any?
    
    var isFromHomeRgiht: Bool = false
    
    deinit {
        DataManager.saveIsInHouse(false)
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "看房"
        tableView.isHidden = true
        view.backgroundColor = dzy_HexColor(0xF5F5F5)
        tableView.backgroundColor = dzy_HexColor(0xF5F5F5)
        tableView.dzy_registerCellNib(WatchHouseBuyerCell.self)
        LockManager.delegate = self
        dzy_removeChildVCs([QRCodeVC.self])
        initUI()
        
        observer = NotificationCenter.default.addObserver(
            forName: PublicConfig.Notice_PayBuyDepositSuccess,
            object: nil,
            queue: .main) { [weak self] (_) in
                self?.initUI()
        }
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
    
    private func initUI() {
        if let log = lookInfo?.dicValue("lockOpenLog"),
            let houseId = log.intValue("houseId"),
            let time = log.stringValue("startTime")
        {
            initLookedMsg()
            sellerTimeOutView.updateUI(lookInfo ?? [:])
            getDetailFromIdApi(houseId, time: time)
        }else if let code = code {
            getDetailFromCodeApi(code)
        }else if let houseId = houseId {
            getDetailFromIdApi(houseId)
        }
    }
    
    //    MARK: - 滚动的 timerAction
    private func timeAction(_ timer: Timer) {
        let total = Int(Date().timeIntervalSince1970)
        infoView.updatePriceAction(total)
    }
    
    //    MARK: - 如果有历史记录，回显
    private func initLookedMsg() {
        let dic = lookInfo?.dicValue("userLookHouse") ?? [:]
        if let imgs = dic["imgs"] as? [String],
            imgs.count > 0
        {
            self.imgs = imgs.map({ (url) -> (UIImage?, String?) in
                return (nil, url)
            })
        }
        remark = dic.stringValue("remark")
        price  = dic.doubleValue("price")
        if let list = lookInfo?.arrValue("userLookEquip") ?? lookInfo?.arrValue("list")
        {
            equipList = list
        }
    }
    
    //    MARK: - 蓝牙开锁
    private func openWithBlueTooth() {
        guard let lockCode = lockCode else {
            showMessage("无法获取门锁code")
            return
        }
        lockPopView.updateSourceView(btWaitView)
        lockPopView.show()
        btWaitView.updateUI(OpenMsg.opening.rawValue)
        isTryBt = true
        connect = false
        LockManager.connect(lockCode)
        
        // 超过30秒如果还没成功，则密码开锁
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.connect == false {
                LockManager.disConnect()
                self.btWaitView.updateUI(OpenMsg.btFail.rawValue)
                self.locationFunc(true)
            }
        }
    }
    
    //    MARK: - 开始计时
    private func beginLookTimer(_ time: String) {
        DataManager.saveIsInHouse(true)
        navigationItem.hidesBackButton = true
        isOpen = true
        timeView.beginTimer(time)
    }
    
    //    MARK: - 获取详情以后的处理
    //swiftlint:disable:next function_body_length cyclomatic_complexity
    private func getDetailSuccess(_ data: [String : Any]?,
                                  error: String?,
                                  time: String? = nil)
    {
        var msg: String?
        var tempList = equipList // 卖家回显，确认选择状态
        if error == EspecialError && data?.intValue("status") == 5 {
            // status == 5 未缴纳买方保证金
            let memo = "为了顺利执行看房操作，请先缴纳看房押金"
            let vc = PayBuyDepositVC(.notice(memo))
            dzy_push(vc)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                vc.dzy_removeChildVCs([WatchHouseVC.self])
            }
            // 都设置为 nil 则不会执行之后的代码
            msg = nil
            house = nil
        }else if error == EspecialError && data?.intValue("status") == 7 {
            // status == 7 补缴看房押金
            let vc = DepositVC(.buyer)
            dzy_push(vc)
            // 都设置为 nil 则不会执行之后的代码
            msg = nil
            house = nil
        }else if error == EspecialError {
            // status == 4 的各种报错
            msg = data?.stringValue("msg")
            house = data?.dicValue("data")?.dicValue("house")
            tempList = data?.dicValue("data")?.arrValue("list") ?? []
            if lookInfo == nil { // 新开启的看房才需要
                equipList = tempList
            }
        }else if let error = error {
            msg = error
        }else {
            house = data?.dicValue("house")
            houseId = house?.intValue("id")
            lockCode = data?.stringValue("lockCode")
            tempList = data?.arrValue("list") ?? []
            data?.stringValue("secretKey").flatMap({
                LockManager.update($0)
            })
        }
        if msg == nil,
            house != nil
        {
            if house?.intValue("lockStatus") == 25 {
                msg = "当前房源还未安装智能门锁，暂不可进行看房"
            }else if !isLockCanUse(house ?? [:]) {
                msg = "门锁故障，暂时无法自助看房"
            }
        }
        if let msg = msg {
            let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .default) { [weak self] (_) in
                self?.dzy_pop()
            }
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }else if let house = house {
            identity = house.intValue("userId") == DataManager.getUserId() ? .seller : .buyer
            lookInfo.flatMap({
                timeView.initConfig($0, identity: identity)
            })
            switch identity {
            case .buyer:
                // 默认展开，提交折叠
                sectionOpen = lookInfo == nil ? true : false
            case .seller:
                // 默认折叠，提交折叠
                sectionOpen = false
                if lookInfo != nil {
                    sellerEditDisable()
                }
            }
            sectionFooter.initUI(identity, remark: remark, price: price)
            tableView.isHidden = false
            infoView.updateUI(house)
            if identity == .seller {
                if lookInfo == nil {
                    equipList = tempList
                    (0..<equipList.count).forEach { (index) in
                        equipList[index][Public_isSelected] = false
                    }
                }else {
                    // 这里是通过 equipList(已报错的) 来给实际数据进行赋值
                    equipList.forEach { (equip) in
                        if let index = tempList.firstIndex(where:{
                            $0.intValue("id") == equip.intValue("equipId")
                        }) {
                            tempList[index][Public_isSelected] = true
                        }
                    }
                    equipList = tempList
                }
                sellerCell.updateUI(equipList)
            }else {
                if lookInfo == nil { // 只有没有旧数据的时候，才需要赋值
                    equipList = tempList.map({
                        var temp = $0
                        temp[DzyQuqipKey] = "外观无损"
                        return temp
                    })
                }
            }
            if let time = time {
                beginLookTimer(time)
            }else {
                dzy_log(btManager.state)
            }
        }
        tableView.reloadData()
    }
    
    //    MARK: - seller 更新时间
    private func sellerUpdateTime(_ data: [String : Any]) {
        timeHeight = 128.0
        guard let time = data.stringValue("nowDate") else {return}
        timeView.resetMsg(time)
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    //    MARK: - 卖家提交报告以后不能修改
    private func sellerEditDisable() {
        sellerCell.isUserInteractionEnabled = false
        sectionFooter.isUserInteractionEnabled = false
    }
    
    //    MARK: - 前往设置界面
    private func goSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
    //    MARK: - 定位
    private func locationFunc(_ showPwd: Bool) {
        let manager = DzyLocationManager.default
        manager.initStep(.tenMeters, times: .once)
        manager.locationHandler = { [weak self] model in
            if let model = model {
                self?.locationSuccess(model, showPwd: showPwd)
            }
        }
        manager.changeHandler = { [weak self] in
            self?.locationFunc(showPwd)
        }
        if manager.checkIsOpenServices() {
            manager.start()
        }else {
            lockPopView.hide()
            let alert = dzy_msgAlert("提示", msg: "系统检测您关闭了手机的定位功能，若想使用门锁相关功能请开启定位授权。")
            present(alert, animated: true, completion: nil)
        }
    }
    
    // 定位成功
    private func locationSuccess(_ model: DzyLLocationModel, showPwd: Bool) {
        if showPwd {
            guard checkDistanceToTheDoor(model) else {
                lockPopView.hide()
                let alert = dzy_msgAlert("提示", msg: "离门锁太远，无法获取密码")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
        let handler: (String?) -> () = { [weak self] pwdCode in
            if let pwdCode = pwdCode {
                if showPwd {
                    self?.showPwd(pwdCode, isBegin: true)
                }else {
                    self?.updateAddressApi(model)
                }
            }else {
                self?.lockPopView.hide()
                let alert = dzy_msgAlert("提示", msg: "获取密码失败")
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        getLockCodeApi(handler)
    }
    
    // 判断距离
    func checkDistanceToTheDoor(_ model: DzyLLocationModel) -> Bool {
        if let latitude = house?.doubleValue("latitude"),
            let longitude = house?.doubleValue("longitude")
        {
            let distance = DzyLocationManager.distanceBetweenTwoPoint(
                model.latitude,
                lon1: model.longitude,
                lat2: latitude,
                lon2: longitude)
            let sysValue = PublicConfig
                .sysConfigDoubleValue(.lockDistance) ?? 99999
            return distance <= sysValue
        }else {
            return true
        }
    }
    
    // 显示开锁密码
    private func showPwd(_ pwd: String, isBegin: Bool) {
        isTryCode = true
        pwdView.updatePwd(pwd)
        lockPopView.updateSourceView(pwdView)
        if !lockPopView.isShow {
            lockPopView.show()
        }
        if isBegin {
            beginFunc(true)
        }
    }
    
//    MARK: - 刷新或者显示密码视图
     private func updateOrShowPwdView() {
        let handler: (String?) -> () = { [weak self] pwdCode in
            if let pwdCode = pwdCode {
                self?.showPwd(pwdCode, isBegin: false)
            }else {
                let alert = dzy_msgAlert("提示", msg: "获取密码失败")
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        getLockCodeApi(handler)
    }
    
//    MARK: - 开始计时
    private func beginFunc(_ isPwdOpen: Bool) {
        // 只有 lookInfo 为 nil 时才是第一次开门
        guard lookInfo == nil else {
            if !isPwdOpen {
                lockPopView.updateSourceView(successView)
            }
            return
        }
        let complete: ([String : Any]) -> () = {[unowned self] data in
            let timeStr = data.dicValue("lockOpen")?.stringValue("startTime") ?? ""
            self.timeView.initConfig(data, identity: self.identity)
            self.sellerTimeOutView.updateUI(data)
            self.beginLookTimer(timeStr)
            self.tableView.reloadData()
            if !isPwdOpen {
                self.lockPopView.updateSourceView(self.successView)
            }
        }
        beginLookHouseApi(complete)
    }
    
    //    MARK: - 上传图片
    private func changeImgsToUrl(_ complete: @escaping ([String])->()) {
        var result = [String](repeating: " ", count: imgs.count)
        let group = DispatchGroup()
        let imageSize = PublicConfig.sysConfigIntValue(.imageSize) ?? 200
        func updateImageToUrl(_ image: UIImage, index: Int) {
            group.enter()
            let data = ToolClass.resetSizeOfImageData(
                source_image: image, maxSize: imageSize
            )
            PublicFunc.bgUploadApi(data, success: { (imgUrl) in
                let url = imgUrl ?? ""
                result[index] = url
                group.leave()
            })
        }
        imgs.enumerated().forEach { (index, object) in
            if let image = object.0 {
                updateImageToUrl(image, index: index)
            }
        }
        group.notify(queue: DispatchQueue.main) {
            complete(result)
        }
    }
    
    //    MARK: - 生成买家看房报告
    func initBuyerMsg(_ imgUrls: [String]) {
        guard let houseId = houseId,
            let openInfo = lookInfo?.dicValue("lockOpen") ?? lookInfo?.dicValue("lockOpenLog"),
            let openId = openInfo.intValue("id"),
            let start = openInfo.stringValue("startTime")
        else {
            showMessage("数据错误")
            return
        }
        let elist = equipList.compactMap { (dic) -> [String : Any]? in
            guard let name = dic.stringValue("name"),
                let equipId = dic.intValue("id"),
                let report = dic.stringValue(DzyQuqipKey)
                else {
                    return nil
            }
            return [
                "name" : name,
                "equipId" : equipId,
                "report" : report
            ]
        }
        guard elist.count == equipList.count else {
            showMessage("请选择每个家具的状态")
            return
        }
        let dic: [String : Any] = [
            "houseId" : houseId,
            "lockOpenLogId" : openId,
            "start" : start,
            "imgs" : ToolClass.toJSONString(dict: imgUrls),
            "equipList" : ToolClass.toJSONString(dict: elist),
            "remark" : sectionFooter.getRemark()
        ]
        buyerLookMsgApi(dic)
    }
    
    //    MARK: - 生成卖家损毁报告
    func initSellerMsg(_ imgUrls: [String]) {
        guard let houseId = houseId,
            let openInfo = lookInfo?.dicValue("lockOpen") ?? lookInfo?.dicValue("lockOpenLog"),
            let openId = openInfo.intValue("id"),
            let start = openInfo.stringValue("startTime")
            else {
                showMessage("数据错误")
                return
        }
        let elist = equipList.compactMap { (dic) -> [String : Any]? in
            guard dic.boolValue(Public_isSelected) == true,
                let name = dic.stringValue("name"),
                let equipId = dic.intValue("id")
            else {
                return nil
            }
            return [
                "name" : name,
                "equipId" : equipId
            ]
        }
        var dic: [String : Any] = [
            "houseId" : houseId,
            "lockOpenLogId" : openId,
            "start" : start
        ]
        if elist.count > 0 {
            dic["equipList"] = ToolClass.toJSONString(dict: elist)
            dic["imgs"]      = ToolClass.toJSONString(dict: imgUrls)
            dic["remark"] = sectionFooter.getRemark()
            dic["price"]  = sectionFooter.getPrice()
        }
        sellerLookMsgApi(dic)
    }
    
    //    MARK: - api
    private func getDetailFromCodeApi(_ code: String) {
        var dic: [String : String] = ["lockCode" : code]
        if isFromHomeRgiht {
            dic["type"] = "2"
            isFromHomeRgiht = false
        }
        let request = BaseRequest()
        request.url = BaseURL.houseDetailFromCode
        request.dic = dic
        request.isUser = true
        request.dzy_start(false) { [weak self] (data, error) in
            self?.getDetailSuccess(data, error: error)
        }
    }
    
    private func getDetailFromIdApi(_ houseId: Int, time: String? = nil) {
        let request = BaseRequest()
        request.url = BaseURL.houseDetailFromId
        request.dic = ["houseId" : houseId]
        request.isUser = true
        request.dzy_start(false) { [weak self] (data, error) in
            self?.getDetailSuccess(data, error: error, time: time)
        }
    }
    
    // 获取开锁密码
    private func getLockCodeApi(_ complete: @escaping (String?) -> ()) {
        guard let lockCode = lockCode else {
            showMessage("门锁号错误")
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.lockPwd
        request.dic = ["deviceCode" : lockCode]
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start { (data, _) in
            ZKProgressHUD.dismiss()
            complete(data?.stringValue("lockPassword"))
        }
    }
    
    // 开锁成功开始计时
    private func beginLookHouseApi(_ complete: @escaping ([String : Any])->()) {
        guard let houseId = houseId else {return}
        let request = BaseRequest()
        request.url = BaseURL.beginLookHouse
        request.dic = ["houseId" : houseId]
        request.isUser = true
        request.dzy_start { (data, _) in
            if let data = data {
                self.lookInfo = data
                complete(data)
            }else {
                self.lockPopView.hide()
                self.showMessage("开始看房失败")
            }
        }
    }
    
    // 关闭看房
    private func closeLookHouseApi() {
        guard let houseId = houseId, let lockCode = lockCode else {return}
        let request = BaseRequest()
        request.url = BaseURL.closeLookHouse
        request.dic = [
            "houseId" : houseId,
            "lockCode" : lockCode
        ]
        request.isUser = true
        ZKProgressHUD.show()
        request.dzy_start(false) { (data, msg) in
            ZKProgressHUD.dismiss()
            if msg == EspecialError, data?.intValue("status") == 6 {
                self.showMessage("看房已经被结束")
                self.dzy_pop()
            }else if data != nil {
                self.showMessage("结束看房成功")
                self.dzy_pop()
            }else {
                let alert = dzy_msgAlert("提示", msg: msg ?? "结束看房失败")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // 买方看房报告
    private func buyerLookMsgApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.buyerLookMsg
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.showMessage("生成看房报告成功")
                self.sectionOpen = false
                self.tableView.reloadData()
            }
        }
    }
    
    // 卖方损毁报告
    private func sellerLookMsgApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.sellerLookMsg
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.showMessage("生成损毁报告成功")
                self.sellerEditDisable()
                self.sectionOpen = false
                self.tableView.reloadData()
            }
        }
    }
    
    // 超时前两分钟更新定位
    private func updateAddressApi(_ model: DzyLLocationModel) {
        guard let houseId = houseId, let lockCode = lockCode else {
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.updateLookAddress
        request.dic = [
            "houseId" : houseId,
            "lockCode" : lockCode,
            "longitude" : model.longitude,
            "latitude"  : model.latitude
        ]
        request.isUser = true
        request.start { (_, _) in
            
        }
    }
    
    // 卖家超时重新计时
    private func sellerUpdateTimeApi() {
        guard let houseId = houseId else {return}
        let request = BaseRequest()
        request.url = BaseURL.sellerUpdateTime
        request.dic = ["houseId" : houseId]
        request.isUser = true
        request.dzy_start { [weak self] (data, error) in
            if data?.intValue("status") == 8,
                error == EspecialError
            {
                self?.showMessage("看房已经被结束")
                self?.dzy_pop()
            }else if let data = data {
                self?.sellerUpdateTime(data)
            }else {
                self?.showMessage("重新计时失败")
            }
        }
    }
    
    /// 判断是否正在看房
    private func checkIsInHouseApi() {
        let request = BaseRequest()
        request.url = BaseURL.checkIsInHouse
        request.isUser = true
        request.start { [weak self] (data, _) in
            guard let data = data, data.count > 0 else {return}
            self?.popView.hide()
            self?.lockPopView.hide()
            self?.dzy_popRoot()
        }
    }
    
    //    MARK: - 懒加载
    /// 顶部的信息界面
    lazy var infoView: WatchHouseInfoView = {
        let info = WatchHouseInfoView.initFromNib(WatchHouseInfoView.self)
        return info
    }()
    
    /// 倒计时
    lazy var timeView: WatchHouseTimeView = {
        let time = WatchHouseTimeView.initFromNib(WatchHouseTimeView.self)
        time.delegate = self
        return time
    }()
    
    /// 房屋状况 / 损坏报告   头部
    lazy var sectionHeader: WatchHouseSectionHeaderView = {
        let header = WatchHouseSectionHeaderView
                    .initFromNib(WatchHouseSectionHeaderView.self)
        header.delegate = self
        return header
    }()
    
    /// 填写损失信息、上传图片的 footer
    lazy var sectionFooter: WatchHouseFooterView = {
        let footer = WatchHouseFooterView
                    .initFromNib(WatchHouseFooterView.self)
        footer.delegate = self
        return footer
    }()
    
    /// 卖方报告损失的 cell
    lazy var sellerCell: WatchHouseSellerCell = {
        let cell = WatchHouseSellerCell
            .initFromNib(WatchHouseSellerCell.self)
        cell.delegate = self
        return cell
    }()
    
    /// 最下面的提示 和 结束看房
    lazy var noticeView: WatchHouseNoticeView = {
        let notice = WatchHouseNoticeView
            .initFromNib(WatchHouseNoticeView.self)
        notice.delegate = self
        return notice
    }()
    
    /// pop
    private lazy var sheetView: ActionSheetView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200.0)
        let sheet = ActionSheetView(frame: frame)
        sheet.delegate = self
        return sheet
    }()
    
    /// 选择家具状态
    private lazy var popView: DzyPopView = {
        let view = DzyPopView(.POP_bottom)
        view.bgDismissHandler = { [weak self] in
            self?.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        return view
    }()
    
    private lazy var btManager: CBCentralManager = {
        let manager = CBCentralManager(delegate: self, queue: .main, options: [
            CBCentralManagerOptionShowPowerAlertKey : false
        ])
        return manager
    }()
    
    /// 蓝牙的引导视图
    private lazy var btGuideView = BlueToothGuideView.initFromNib()
    
    /// 开锁的等待视图
    private lazy var btWaitView = BlueToothOpenView.initFromNib(BlueToothOpenView.self)
    
    /// 开锁成功
    private lazy var successView = BlueToothOpenSuccessView
        .initFromNib(BlueToothOpenSuccessView.self)
    
    private lazy var lockPopView: DzyPopView = {
        let popView = DzyPopView(.POP_center_above, viewBlock: btWaitView)
        popView.isBgCanClick = false
        return popView
    }()
    
    /// 显示密码的view
    private lazy var pwdView: LockPwdView = {
        let view = LockPwdView.initFromNib(LockPwdView.self)
        view.delegate = self
        return view
    }()
    
    /// 卖家超时的警告
    private lazy var sellerTimeOutView: WatchHouseSellerTimeOutView = {
        let view = WatchHouseSellerTimeOutView.initFromNib()
        view.delegate = self
        return view
    }()
}

extension WatchHouseVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isOpen ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOpen && section == 1 && sectionOpen {
            return identity == .seller ? 1 : equipList.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch identity {
        case .buyer:
            return 53.0
        case .seller:
            return 95.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch identity {
        case .buyer:
            let cell = tableView
                .dzy_dequeueReusableCell(WatchHouseBuyerCell.self)
            cell?.updateUI(equipList[indexPath.row],
                           row: indexPath.row)
            cell?.delegate = self
            return cell!
        case .seller:
            return sellerCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 91
        case 1:
            return 54
        case 2:
            return 250
        default:
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return infoView
        case 1:
            return sectionHeader
        case 2:
            return noticeView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0 where isOpen:
            return timeHeight
        case 1 where sectionOpen:
            return sectionFooter.height
        default:
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0 where isOpen:
            return timeView
        case 1 where sectionOpen:
            sectionFooter.updateUI(imgs)
            return sectionFooter
        default:
            return nil
        }
    }
}

//MARK: - 重新开锁 提示 警告
extension WatchHouseVC: WatchHouseTimeViewDelegate {
    // 重新开锁
    func timeView(_ timeView: WatchHouseTimeView, reopenWithBtn btn: UIButton) {
        if isTryCode {
            updateOrShowPwdView()
        }else {
            openWithBlueTooth()
        }
    }
    // 提示
    func timeView(_ timeView: WatchHouseTimeView, promptWithTime time: String, height: CGFloat) {
        reloadTimeView(height)
    }
    // 警告
    func timeView(_ timeView: WatchHouseTimeView, warningWithTime time: String, height: CGFloat) {
        reloadTimeView(height)
    }
    // 最大时限
    func timeView(_ timeView: WatchHouseTimeView, maxWithTime time: String, height: CGFloat) {
        if identity == .seller {
            lockPopView.updateSourceView(sellerTimeOutView)
            lockPopView.show()
        }
    }
    // 定位
    func timeView(_ timeView: WatchHouseTimeView, uploadLocationWithTime time: String) {
        locationFunc(false)
    }
    
    // 超时以后每过一分钟确认一下是否还在
    func timeView(_ timeView: WatchHouseTimeView, sellerCheckIsInWithTime time: String) {
        checkIsInHouseApi()
    }
    
    private func reloadTimeView(_ height: CGFloat) {
        timeHeight = height
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
}

//MARK: - 卖家重新计时的警告
extension WatchHouseVC: WatchHouseSellerTimeOutViewDelegate {
    func timeOutView(_ timeOutView: WatchHouseSellerTimeOutView, didClickBtn btn: UIButton) {
        sellerUpdateTimeApi()
        lockPopView.hide()
    }
}

//MARK: - 是否展开报告
extension WatchHouseVC: WatchHouseSectionHeaderViewDelegate {
    // 房屋状况 / 损坏报告  是否展开
    func header(_ header: WatchHouseSectionHeaderView, openAction open: Bool) {
        sectionOpen = open
        tableView.reloadData()
    }
}

//MARK: - 买方选择房屋状况
extension WatchHouseVC: WatchHouseBuyerCellDelegate, ActionSheetViewDelegate {
    func sheetView(_ sheetView: ActionSheetView, didClickCancelBtn btn: UIButton) {
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func sheetView(_ sheetView: ActionSheetView, didSelectString str: String) {
        equipList[buyerCurRow][DzyQuqipKey] = str
        popView.hide()
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func buyerCell(_ buyerCell: WatchHouseBuyerCell, didSelectOpenBtn btn: UIButton, on row: Int) {
        buyerCurRow = row
        sheetView.updateUI(["外观无损", "没看见", "明显损毁"])
        popView.updateSourceView(sheetView)
        popView.show()
    }
}

//MARK: - 卖方提交房屋报告
extension WatchHouseVC: WatchHouseSellerCellDelegate {
    func sellerCell(_ sellerCell: WatchHouseSellerCell, didSelectEquip row: Int) {
        if let old = equipList[row].boolValue(Public_isSelected) {
            equipList[row][Public_isSelected] = !old
        }
    }
}

//MARK: - 结束看房
extension WatchHouseVC: WatchHouseNoticeViewDelegate {
    func noticeView(_ noticeView: WatchHouseNoticeView, didSelectEndBtn btn: UIButton) {
        closeLookHouseApi()
    }
}

//MARK: - 获取定位
extension WatchHouseVC: LockManagerDelegate {
    
    func lockManager(_ lockManager: LockManager, didOpenLock lock: String) {
        isTryCode = false
        connect = true
        beginFunc(false)
    }
    
    func connectSuccess(_ lockManager: LockManager) {
        LockManager.unlock()
    }
    
    func lockManager(_ lockManager: LockManager, updateMsg msg: String) {
        btWaitView.updateUI(msg)
        dzy_log("update  -----  \(msg)")
    }
    
    func lockManager(_ lockManager: LockManager, openFailed msg: String) {
        dzy_log("fail  -----  \(msg)")
        btWaitView.updateUI(OpenMsg.btFail.rawValue)
        if !isTryCode {
            locationFunc(true)
        }else {
            lockPopView.hide()
        }
    }
}

//MARK: - 蓝牙状态更改
extension WatchHouseVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if !isTryBt {
                openWithBlueTooth()
            }
        case .poweredOff:
            lockPopView.updateSourceView(btGuideView)
            lockPopView.show()
        case .unsupported, .unauthorized: // 不支持和未授权
            lockPopView.updateSourceView(btWaitView)
            lockPopView.show()
            btWaitView.updateUI(OpenMsg.btDisable.rawValue)
            locationFunc(true)
        case .resetting:
            print("重置中")
        case .unknown: //还未设置
            print("123")
        default:
            print("未知的")
        }
    }
}

//MARK: - 密码开门
extension WatchHouseVC: LockPwdViewDelegate {
    func pwdView(_ pwdView: LockPwdView, didClickOepnBtn btn: UIButton) {
        lockPopView.hide()
    }
    
    func pwdView(_ pwdView: LockPwdView, didClickReportBtn btn: UIButton) {
        if let houseId = houseId {
            lockPopView.hide()
            let vc = ReportLockDestroyVC(houseId, type: .watch)
            dzy_push(vc)
        }
    }
    
    func pwdView(_ pwdView: LockPwdView, didClickUpdateBtn btn: UIButton) {
        updateOrShowPwdView()
    }
}

//MARK: - 上传图片相关
extension WatchHouseVC: WatchHouseFooterViewDelegate, DzyImagePickerVCDelegate {
    
    func didClickBuyerMsgBtn(in footerView: WatchHouseFooterView, with btn: UIButton) {
        view.endEditing(true)
        if imgs.count > 0 {
            ZKProgressHUD.show()
            changeImgsToUrl { [weak self] (result) in
                ZKProgressHUD.dismiss()
                self?.initBuyerMsg(result)
            }
        }else {
            initBuyerMsg([])
        }
    }
    
    func didClickSellerMsgBtn(in footerView: WatchHouseFooterView, with btn: UIButton) {
        view.endEditing(true)
        if imgs.count > 0 {
            ZKProgressHUD.show()
            changeImgsToUrl { [weak self] (result) in
                ZKProgressHUD.dismiss()
                self?.initSellerMsg(result)
            }
        }else {
            initSellerMsg([])
        }
    }

    func didClickAddImageCell(in footerView: WatchHouseFooterView) {
        let count = footerView.maxNum - imgs.count
        let picker = DzyImagePickerVC(.origin(.several(count)))
        picker.delegate = self
        let navi = BaseNavVC(rootViewController: picker)
        present(navi, animated: true, completion: nil)
    }
    
    func didClickShowImageCell(in footerView: WatchHouseFooterView, with row: Int) {
        if let image = imgs[row].0 {
            let showView = DzyShowImageView(.image(image))
            showView.show()
        }else if let url = imgs[row].1 {
            let showView = DzyShowImageView(.one(url))
            showView.show()
        }
    }
    
    func didClickDelBtn(in footerView: WatchHouseFooterView, with row: Int) {
        imgs.remove(at: row)
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func imagePicker(_ picker: DzyImagePickerVC?, getImages imgs: [UIImage]) {
        self.imgs += imgs.map({ (image) -> (UIImage?, String?) in
            return (image, nil)
        })
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func imagePicker(_ picker: DzyImagePickerVC?, getCropImage image: UIImage) {}
    
    func imagePicker(_ picker: DzyImagePickerVC?, getOriginImage image: UIImage) {}
    
    func selectedFinshAndBeginDownload(_ picker: DzyImagePickerVC?) {}
}
