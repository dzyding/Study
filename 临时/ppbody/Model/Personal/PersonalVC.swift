//
//  PersonalVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0
import DKImagePickerController

class PersonalVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    /// 二维码
    @IBOutlet weak var btnQr: UIButton!
    /// 消息
    @IBOutlet weak var msgBtn: UIButton!
    /// 女王皇冠
    @IBOutlet weak var queenIV: UIImageView!
    /// 头像
    @IBOutlet weak var headIV: UIImageView!
    /// 认证教练
    @IBOutlet weak var tagBtn: UIButton!
    /// 名字
    @IBOutlet weak var nameLB: UILabel!
    /// 总 stackView
    @IBOutlet weak var stackView: UIStackView!
    /// 显示未读消息数
    @IBOutlet weak var notifyLB: UILabel!
    /// 顶部需要动画的 imgView
    @IBOutlet weak var topIV: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    /// 签名
    @IBOutlet weak var briefLB: UILabel!
    /// 粉丝
    @IBOutlet weak var followNumLB: RelationLabel!
    /// 关注
    @IBOutlet weak var attentionNumLB: RelationLabel!
    /// 会员
    @IBOutlet weak var memberNumLB: RelationLabel!
    /// 个人信息相关子视图的高度
    @IBOutlet weak var msgViewHeightLC: NSLayoutConstraint!
    /// 透明的占位视图
    @IBOutlet weak var clearView: UIView!
    /// 右上角三个按钮的背景图
    @IBOutlet weak var threeBtnBgView: UIView!
    /// 顶部imgView 的高度
    @IBOutlet weak var topIVHeightLC: NSLayoutConstraint!
    
    var functionView = FunctionView.instanceFromNib()
    /// 我的健身房弹出 pop
    lazy var clubPopView: DzyPopView = DzyPopView(.POP_bottom)
    /// 我的健身房弹出 picker
    weak var pickerView: GymPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        topIVHeightLC.constant = ScreenWidth / 3.0 * 2.0
        relationStep()
        setCleatViewTap()
        basicUI()
        notiAddObserver()
//        ifRepresentApi()
        getMyclubApi()
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMessageNotify()
        //用户个人的关系数据
        loadApi()
    }
    
    //    MARK: - 基础 UI
    func basicUI() {
        let user = DataManager.userInfo()
        // 用户昵称
        let head = user!["head"] as! String
        
        // 签名
        if let brief = user?.stringValue("brief"), !brief.isEmpty {
            briefLB.isHidden = false
            briefLB.text = brief
        }else {
            briefLB.isHidden = true
            msgViewHeightLC.constant = 158
        }
        
        // 用户封面
        if let cover = user?.stringValue("cover") {
            topIV.setCoverImageUrl(cover)
        }
        // 头像
        headIV.setCoverImageUrl(head)
        headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ownerPage)))
        nameLB.text = user?.stringValue("nickname")
        
        if DataManager.isCoach() {
            headIV.layer.borderWidth = 2
            headIV.layer.borderColor = YellowMainColor.cgColor
            tagBtn.isHidden = false
        }else {
            headIV.layer.borderWidth = 2
            headIV.layer.borderColor = UIColor.white.cgColor
            tagBtn.isHidden = true
        }
        
        // 我的健身房
        let gymView = MyGymView.initFromNib(MyGymView.self)
        gymView.delegate = self
        stackView.addArrangedSubview(gymView)
        
        // 功能
        stackView.addArrangedSubview(functionView)
        
        /// 订单
        let listFuncView = MyListFuncView.initFromNib()
        if DataManager.isCoach() {
            listFuncView.coachType()
        }
        listFuncView.delegate = self
        stackView.addArrangedSubview(listFuncView)
        
        if isFistCoachTip {
            let tipView = CoachTipView.instanceFromNib()
            tipView.frame = ScreenBounds
            tipView.authAction = { [weak self] () in
                self?.functionView.authCoach()
                tipView.removeFromSuperview()
            }
            UIApplication.shared.keyWindow?.addSubview(tipView)
        }
        view.isHidden = false
    }
    
    //    MARK: - 各种通知注册
    func notiAddObserver() {
        registObservers([
            Config.Notify_MessageForIM
        ], queue: .main) { [weak self] (_) in
            self?.showMessageNotify()
        }
        
        registObservers([
            Config.Notify_ChangeHead
        ], queue: .main) { [weak self] (nofity) in
            let userinfo = nofity.userInfo
            self?.headIV.image = userinfo?["head"] as? UIImage
            self?.nameLB.text = userinfo?["nickname"] as? String
        }
        
        registObservers([
            Config.Notify_ReduceCourse
        ], queue: .main) { [weak self] (noti) in
            self?.scanNoticeHandler(noti.userInfo)
        }
    }
    
    //    MARK: - 获取未读信息
    func showMessageNotify() {
        var noRead = 0
        //获取未读消息
        if let messageNotify = DataManager.messageNotify() {
            let num = ToolClass.isMessageNoRead(messageNotify)
            noRead += num
        }
        let status = RCIMClient.shared().getConnectionStatus()
        if status != RCConnectionStatus.ConnectionStatus_SignUp {
            let unreadMsgCount = RCIMClient.shared()
                .getUnreadCount([
                    RCConversationType.ConversationType_PRIVATE.rawValue
                ])
            if unreadMsgCount == 0 {
                noRead += 0
            }else{
                noRead += Int(unreadMsgCount)
            }
        }
        if noRead > 0 {
            notifyLB.text = noRead > 100 ? "..." : "\(noRead)"
            notifyLB.isHidden = false
        }else{
            notifyLB.isHidden = true
        }
    }
    
    //    MARK: - 设置占位视图的 tap 事件
    func setCleatViewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(checkTopIMAction(_:)))
        clearView.addGestureRecognizer(tap)
    }
    
    //    MARK: - 个人主页
    @objc func ownerPage()
    {
        let vc = PersonalPageVC()
        vc.user = DataManager.userInfo()
        self.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 推广大使
    func ifRepresentApi() {
        let request = BaseRequest()
        request.url = BaseURL.OpenSpread
        request.isUser = true
        request.start { (data, error) in
            if let open = data?.intValue("open"), open == 1,
                let amb = AmbassadorView.initFromNib()
            {
                amb.handler = { [unowned self] in
                    self.ambassadorAction()
                }
                self.stackView.insertArrangedSubview(amb, at: 1)
            }
            self.view.isHidden = false
        }
    }
    
    func ambassadorAction() {
        let vc = MessageWebView(.amb)
        dzy_push(vc)
    }
    
    //    MARK: - 我的健身房
    func getMyclubApi() {
        let request = BaseRequest()
        request.url = BaseURL.MyClub
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.setClubPopView(data)
            }
        }
    }
    
    func setClubPopView(_ data: [String : Any]) {
        let clubs = data.arrValue("list") ?? []
        pickerView = nil
        guard clubs.count > 0 else {return}
        if let picker = GymPickerView.initFromNib(clubs, type: .gym) {
            clubPopView.updateSourceView(picker)
            picker.delegate = self
            self.pickerView = picker
        }
    }
    
    //    MARK: - 更换图片
    @objc func checkTopIMAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: tap.view)
        let rect = headIV.superview?.convert(headIV.frame, to: clearView)
        if rect?.contains(point) == true {
            ownerPage()
        }else {
            guard let image = topIV?.image else {return}
            let type = DzyShowImageType.updateOne(image) { [unowned self] in
                //弹出相册
                self.showImagePickerWithAssetType(
                    .allPhotos,
                    allowMultipleType: false,
                    sourceType: .photo,
                    allowsLandscape: true,
                    singleSelect: true
                )
            }
            let vc = DzyShowImageView(type)
            vc.show()
        }
    }
    
    //    MARK: - 扫一扫
    @IBAction func scanAction(_ sender: UIButton) {
        let vc = QRScanCodeVC()
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")
                
        vc.scanStyle = style
//        vc.scanResultDelegate = self
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 二维码
    @IBAction func btnQrClick(_ sender: Any) {
        let vc = QRCodeCreateVC()
        vc.logoDic = ["head": headIV.image ?? "", "name": nameLB.text!]
        self.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 刷新用户封面
    func updateCoverApi(_ url: String) {
        let request = BaseRequest()
        request.url = BaseURL.UpdateCover
        request.isUser = true
        request.dic = ["cover" : url]
        request.start { (data, error) in
            if let error = error {
                ToolClass.showToast(error, .Failure)
            }
        }
    }
    
    //    MARK: - 粉丝，关注，学员
    func loadApi() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.RelationData
        request.start { [unowned self] (data, error) in
            guard error == nil,
                let relation = data?["relation"] as? [String : Any]
            else
            {
                //执行错误信息
//                ToolClass.showToast(error!, .Failure)
                return
            }
            self.followNumLB.text = "\(relation.intValue("followNum") ?? 0)" + "粉丝"
            self.attentionNumLB.text = "\(relation.intValue("attentionNum") ?? 0)" + "关注"
            if DataManager.isCoach() {
                self.memberNumLB.text = "\(relation.intValue("memberNum") ?? 0)" + "学员"
            }
        }
    }
    
    @objc func relationStep(){
        if DataManager.isCoach() {
            memberNumLB.isHidden = false
        }
        let actionHandler: (Int)->() = {[unowned self] tag in
            self.relationAction(tag)
        }
        followNumLB.handler    = actionHandler
        attentionNumLB.handler = actionHandler
        memberNumLB.handler = actionHandler
    }
    
    @IBAction func relationAction(_ tag: Int) {
        // 粉丝1 关注2 学员3
        let vc = RelationVC()
        vc.type = "\(tag)"
        tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 我的消息
    @IBAction func btnMessageClick(_ sender: Any) {
        let vc = MessageVC()
        vc.hbd_barTintColor = BackgroundColor
        vc.hbd_barShadowHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 个人资料
    @IBAction func btnEditClick(_ sender: Any) {
        let vc = MineInfoVC.init(nibName: "MineInfoVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - 我的钱包
    @IBAction func walletAction(_ sender: Any) {
        let vc = WalletVC()
        dzy_push(vc)
    }
    
    //    MARK: - 扫码获取学员课程列表
    private func scanCourseCodeApi(_ code: String) {
        let request = BaseRequest()
        request.url = BaseURL.ScanCourseCode
        request.dic = ["code" : code]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.scanCourseCodeSuccess(data, code: code)
        }
    }
    
    private func scanCourseCodeSuccess(
        _ data: [String : Any]?, code: String
    ) {
        if let dic = data?.dicValue("memberClass") {
            let vc = CoachReduceCourseVC(dic, code: code)
            dzy_push(vc)
        }
    }
    
    private func scanNoticeHandler(_ noti: [AnyHashable : Any]?) {
        if DataManager.isCoach(),
            let code = noti?["code"] as? String
        {
            scanCourseCodeApi(code)
        }else {
            ToolClass.showToast("您还不是教练", .Failure)
        }
    }
    
    //    MARK: - 更换背景图
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.maxSelectableCount = 1
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            if assets.count == 0
            {
                return
            }
            
            for asset in assets {
                
                asset.fetchOriginalImage(completeBlock:{ (image, info) in
                    let controller = CropViewController()
                    controller.delegate = self
                    controller.image = image
                    controller.cropAspectRatio = 3.0 / 2.0 //宽高比例
                    controller.keepAspectRatio = true
                    controller.toolbarHidden = true
                    let navController = UINavigationController(rootViewController: controller)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                })
            }
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }
}

//MARK: - 订单
extension PersonalVC: MyListFuncViewDelegate {
    
    func listFuncView(_ listFuncView: MyListFuncView, didClickActionType type: MyListFuncViewType) {
        switch type {
        case .groupOrder:
            let vc = LocationOrderVC()
            dzy_push(vc)
        case .goodsOrder:
            let vc = GoodsOrderVC()
            dzy_push(vc)
        case .myCoach:
            let vc = CoachListVC()
            dzy_push(vc)
        case .becomeCoach:
            let vc : UIViewController
            if functionView.reviewStatus != 10 {
                vc = CoachCertifyVC()
            }else {
                vc = CoachCertifyStatusVC()
                let vc = vc as! CoachCertifyStatusVC
                vc.statusType = functionView.reviewStatus
            }
            dzy_push(vc)
        }
    }
}

//  MARK: - 我的健身房
extension PersonalVC: MyGymViewDelegate, GymPickerViewDelegate {
    func gymView(_ gymView: MyGymView, didSelected btn: UIButton) {
        if let clubs = pickerView?.datas,
            clubs.count > 0
        {
            if clubs.count == 1 {
                // 只有一个就直接跳转
                goToGymVC(clubs[0])
            }else {
                pickerView?.tableView.reloadData()
                clubPopView.show()
            }
        }else {
            ToolClass.showToast("暂无关联健身房", .Failure)
        }
    }
    
    func gympicker(_ picker: GymPickerView, didSelected data: [String : Any]) {
        clubPopView.hide()
        goToGymVC(data)
    }
    
    // 前往健身房界面
    func goToGymVC(_ data: [String : Any]) {
        guard let smid = data.intValue("smId"),
            let clubid = data.intValue("id")
        else {return}
        DataManager.saveSmid(smid)
        if DataManager.userInfo()?.intValue("type") == 20 {
            let vc = CoachGymVC(clubid)
            vc.personVC = self
            dzy_push(vc)
        }else {
            let vc = MyGymVC(clubid)
            vc.personVC = self
            dzy_push(vc)
        }
    }
}

//  MARK: - 顶部缩放
extension PersonalVC: ScaleTopIVProtocol, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        sacleFunction(y)
        
        if y <= -190 {
            threeBtnBgView.isHidden = false
            let alpha = (y + 190.0) / -40.0
            threeBtnBgView.alpha = alpha >= 1 ? 1 : alpha
        }else {
            threeBtnBgView.isHidden = true
        }
    }
    
    var ivHeight: CGFloat {
        return 190.0
    }
    
    var scaleIV: UIImageView {
        return topIV
    }
}

//MARK: - 图片剪切
extension PersonalVC: CropViewControllerDelegate {
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        self.topIV.image = image
        let imgArr = AliyunUpload.upload.uploadAliOSS([image], type: .UserCover) { (progress) in
            
        }
        updateCoverApi(imgArr[0])
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//    MARK: - 裴云要的切换账号的需求
extension PersonalVC {
    func checkAccount() {
        let btn = UIButton(type: .custom)
        btn.setTitle("切换账号", for: .normal)
        btn.titleLabel?.font = ToolClass.CustomFont(14)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(checkOutAction), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.left.equalTo(10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    @objc func checkOutAction() {
        let vc = CheckOutVC()
        vc.personalVC = self
        present(vc, animated: true, completion: nil)
    }
    
    func updateUserInfo() {
        let user = DataManager.userInfo()
        // 用户昵称
        let head = user!["head"] as! String
        
        // 签名
        if let brief = user?.stringValue("brief"), !brief.isEmpty {
            briefLB.isHidden = false
            briefLB.text = brief
        }else {
            briefLB.isHidden = true
            msgViewHeightLC.constant = 158
        }
        
        // 用户封面
        if let cover = user?.stringValue("cover") {
            topIV.setCoverImageUrl(cover)
        }
        
        // 头像
        headIV.setCoverImageUrl(head)
        headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ownerPage)))
        nameLB.text = user?.stringValue("nickname")
    }
}
