//
//  PPBodyManVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PPBodyMainVC: UITabBarController, ObserverVCProtocol {
    
    private var fpp: String?
    
    var observers: [[Any?]] = []
    
    var _backView:UIView? = nil
    var  items:NSArray = []
    
    private let vcs: [UIViewController] = [
        TrainingVC(),
        LocationVC(),
        FoundVC(),
        PersonalVC()
    ]
    
    private let NameArr = ["训练", "附近", "发现", "我的"]
    
    private let PicArr = [
        "tab_icon_train",
        "tab_icon_loc",
        "tab_icon_find",
        "tab_icon_my"
    ]
    
    var addressView: AddressBookView?
    
    var isShowTips = false
    /// 是否已展示当前约课视图
    private var showClass = false
    
    override func viewWillAppear(_ animated: Bool) {
        // 每次切换到根 也就是 "训练","统计","发现","我的" 的时候会触发
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        getMessageNotify()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        
    }
    func getAllSystemFonts() {
        UIFont.familyNames.map {
            UIFont.fontNames(forFamilyName: $0)
            }.forEach { (fonts:[String]) in
                fonts.forEach({
                    print($0)
                })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        getAllSystemFonts()
        view.backgroundColor = BackgroundColor
        let item = UIBarButtonItem(title: "",
                                   style: UIBarButtonItem.Style.plain,
                                   target: self,
                                   action: nil)
        navigationItem.backBarButtonItem = item
        tabBar.barTintColor =  BackgroundColor
        tabBar.isTranslucent = false
        tabBar.tintColor =  YellowMainColor
        modalPresentationStyle = .fullScreen
        //移除缓存信息
        DataManager.removeMemberInfo()
        creatTabBar()
        refreshAuth()
        registNotice()
        selectedIndex = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkMyCourse()
        checkPasteboard()
    }
    
    deinit {
        deinitObservers()
    }
    
    //    MARK: - 收取容云信息
    func registNotice() {
        registObservers([
           Config.Notify_MessageForIM
        ]) { [weak self] (nofity) in
            if let extra = nofity.userInfo?["extra"] as? String,
                extra.hasPrefix("sweat="),
                let content = nofity.userInfo?["content"] as? String
            {
                // 获取汗水
                DispatchQueue.main.async {
                    let v = GetSweatView(content)
                    KEY_WINDOW?.addSubview(v)
                }
            }
            
            if let extra = nofity.userInfo?["extra"] as? String {
                let strArr = extra.components(separatedBy: ":")
                DispatchQueue.main.async { [weak self] in
                    if strArr.first == Config.ReduceCompleteKey,
                        strArr.last == self?.qrView.code
                    {
                        self?.reduceCourseSuccess()
                    }
                }
            }
        }
        
        registObservers([
            Config.Notify_DidBecomeActive
        ]) { [weak self] (_) in
            self?.checkPasteboard()
        }
    }
    
    //    MARK: - 核销成功
    private func reduceCourseSuccess() {
        ToolClass.showToast("核销成功", .Success)
        if popView.superview != nil {
            popView.hide()
        }
        if showClass == false {
            hideClassShowView()
        }
    }
    
    func addressBookAction() {
        if addressView == nil {
            addressView = AddressBookView.instanceFromNib()
            addressView?.frame = self.view.bounds
        }
        navigationController?.view.addSubview(addressView!)
    }
    
    //MARK: - 创建tabBar
    func creatTabBar()  {
        viewControllers = vcs.enumerated().map({ (index, vc) -> UIViewController in
            vc.tabBarItem.title = NameArr[index]
            let imageName = PicArr[index]
            vc.tabBarItem.selectedImage = UIImage(named: imageName)?
                .withRenderingMode(.alwaysOriginal)
            vc.tabBarItem.image = UIImage(named: imageName + "_no")?
                .withRenderingMode(.alwaysOriginal)
            vc.tabBarItem.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor : YellowMainColor
            ], for: .selected)
            return vc
        })
        
        //设置 tabBar 工具栏字体颜色 (未选中  和  选中)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor :
                UIColor.ColorHex("0xA8A8A8"),
        ], for: .normal)

        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor :
            YellowMainColor
        ], for: .selected)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "发现", "我的":
            getMessageNotify()
        default:
            break
        }
        checkMyCourse()
    }
    
    //    MARK: - 判断当前是否有课，并添加
    private func checkMyCourse() {
        if !showClass,
            classView.superview == nil,
            !DataManager.isCoach()
        {
            myCourseApi()
        }
    }
    
//    MARK: - 判断是否有复制文本
    private func checkPasteboard() {
        guard let str = UIPasteboard.general.string,
            str.contains("PPbody") else {return}
        UIPasteboard.general.string = ""
        let arr = str.components(separatedBy: "$")
        guard arr.count == 3 else {return}
        fpp = nil
        resolvShareCode(arr[1]) { [weak self] (data) in
            self?.getShareDetail(data)
        }
    }
    
    private func getShareDetail(_ data: [String : Any]) {
        guard let type = data.intValue("type"),
            let goodsId = data.intValue("goodsId") else {return}
        fpp = data.stringValue("fpp")
        //10 团购 11 私教 12 团操 20 商品
        if type == 10 {
            groupBuyDetailApi(goodsId)
        }else if type == 11 {
            ptExpDetailApi(goodsId)
        }else if type == 20 {
            goodsDetailApi(goodsId)
        }
    }
    
//    MARK: - 各种更新商品详情
    private func updateShareView(_ type: ShareType,
                                 data: [String : Any])
    {
        shareView.updateUI(type, data: data)
        popView.updateSourceView(shareView)
        popView.show()
    }
    
//    MARK: - 前往各种商品详情
    private func goGoodsDetail(_ type: ShareType, goodsId: Int) {
        popView.hide()
        switch type {
        case .lbs_gb:
            let vc = LocationGBDetailVC(goodsId)
            vc.fpp = fpp
            dzy_push(vc)
        case .lbs_exp:
            let vc = LocationPtExpDetailVC(goodsId)
            vc.fpp = fpp
            dzy_push(vc)
        case .goods:
            let vc = T12GoodsDetailVC(goodsId)
            vc.fpp = fpp
            dzy_push(vc)
        default:
            break
        }
    }
    
//    MARK: - 检测是否有正在上的课
    private func updateMyCourse(_ data: [String : Any]?) {
        if let course = data?.dicValue("course") {
            classView.initUI(course)
            view.addSubview(classView)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var classView: PublicClassShowView = {
        let view = PublicClassShowView
            .initFromNib(PublicClassShowView.self)
        view.frame = CGRect(
            x: 0, y: tabBar.frame.minY - 90,
            width: ScreenWidth, height: 90.0
        )
        view.delegate = self
        return view
    }()
    
    private lazy var popView = DzyPopView(.POP_center_above)
    
    private lazy var qrView: PublicClassQrCodeView = {
        let view = PublicClassQrCodeView
            .initFromNib(PublicClassQrCodeView.self)
        let width = ScreenWidth - 50.0
        view.frame = CGRect(
            x: 0, y: 0, width: width, height: width + 30.0
        )
        return view
    }()
    
    private lazy var shareView: PublicShareGoodsView = {
        let view = PublicShareGoodsView.initFromNib()
        view.handler = { [weak self] (type, goodsId) in
            self?.goGoodsDetail(type, goodsId: goodsId)
        }
        return view
    }()
    
    //    MARK: - api
    func refreshAuth() {
        let request = BaseRequest()
        request.dic = ["from":"IOS"]
        request.isUser = true
        request.url = BaseURL.RefreshAuth
        request.start { (data, error) in
            guard error == nil else{
//                ToolClass.showToast(error!, .Failure)
                return
            }
            let newUser = data!["user"] as! [String:Any]
            let newReview = newUser["review"] as! Int
            let rongToken = newUser["rongToken"] as! String
            print(rongToken)
            RCIMClient.shared().connect(withToken: rongToken, success: { (userId) in
                print("============RongCloud===========")
                print(userId!)
                JPUSHService.setAlias(userId, completion: { (iResCode, iAlias, seq) in
                    print(iResCode)
                    print(iAlias as Any)
                    print(seq)
                }, seq: 1)
                
            }, error: { (error) in
                print(error)
            }, tokenIncorrect: {
                
            })
            
            let oldReview = DataManager.userInfo()!["review"] as! Int
            DataManager.saveUserInfo(newUser)
            if newReview == 20 && oldReview == 10 {
                //审核驳回
                ToolClass.showToast("您的教练申请被驳回，请联系工作人员", .Failure)
            }else if newReview == 30 && oldReview == 10 {
                //审核通过
                ToolClass.showToast("您的教练申请已通过", .Success)
                NotificationCenter.default.post(name: Config.Notify_CoachReviewSuccess, object: nil)
            }
        }
    }
    
    //获取未读消息通知
    func getMessageNotify() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MessageNotify
        request.start { (data, error) in
            guard error == nil else {
//                ToolClass.showToast(error!, .Failure)
                return
            }
            let msgNum = data!["msgNum"] as! [String:Any]
            DataManager.saveMessageNotify(msgNum)
        }
    }
    
    private func myCourseApi() {
        let request = BaseRequest()
        request.url = BaseURL.MyIngCourse
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                return
            }
            self.updateMyCourse(data)
        }
    }
    
    private func resolvShareCode(_ code: String,
                            complete: @escaping ([String : Any])->()) {
        let request = BaseRequest()
        request.url = BaseURL.ResolveShareCode
        request.dic = ["code" : code]
        request.start { (data, error) in
            if let data = data?.dicValue("shareInfo") {
                complete(data)
            }
        }
    }
    
    private func groupBuyDetailApi(_ goodsId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.GroupBuyDetail
        request.dic = ["groupBuyId" : "\(goodsId)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            data?.dicValue("groupBuyInfo").flatMap({
                self.updateShareView(.lbs_gb, data: $0)
            })
        }
    }
    
    private func ptExpDetailApi(_ goodsId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.PtExpDetail
        request.dic = ["ptExpId" : "\(goodsId)"]
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("ptExpInfo") {
                self.updateShareView(.lbs_exp, data: data)
            }
        }
    }
    
    private func goodsDetailApi(_ goodsId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.GoodsDetail
        request.dic = ["goodsId" : "\(goodsId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data?.dicValue("goods") {
                self.updateShareView(.goods, data: data)
            }
        }
    }
}

extension PPBodyMainVC: PublicClassShowViewDeleagate {
    func classShowView(_ classShowView: PublicClassShowView, didClickQrBtn btn: UIButton, code: String?) {
        if let code = code {
            qrView.updateUI(code)
            popView.updateSourceView(qrView)
            popView.show()
        }
    }
    
    func classShowView(_ classShowView: PublicClassShowView, didClickHideBtn btn: UIButton) {
        hideClassShowView()
    }
    
    func hideClassShowView() {
        UIView.animate(withDuration: 1, animations: {
            self.classView.transform = self.classView.transform.translatedBy(
                x: -ScreenWidth, y: 0
            )
        }) { (_) in
            self.classView.removeFromSuperview()
            self.showClass = true
        }
    }
}
