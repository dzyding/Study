//
//  PersonalPageVC.swift
//  PPBody
//
//  Created by edz on 2018/12/5.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PersonalPageVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var collectionview: UICollectionView!
    // 顶部做动画的 IV
    @IBOutlet weak var topIV: UIImageView!
    // 顶部的假 naviBar
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    let topicDetailModel = TopicDetailModel()
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    var uid: String?
    var name = ""
    
    var user:[String:Any]?
    
    var isBlack: Int = 0
    
    let calculationHead = PersonalPageHeadView.instanceFromNib()
    var headerHeight:CGFloat = 0
    
    var payView:CoachPayView?
    
    var payIMView: CoachIMPayView?
    
    var payType = 10 //IM 支付
    /// 顶部图片的高度
    @IBOutlet weak var topIVHeightLC: NSLayoutConstraint!
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToolClass.removeChildController(self, removeClass: QRScanCodeVC.self)
        topIVHeightLC.constant = ScreenWidth / 3.0 * 2.0
        titleView.alpha = 0
        titleViewHeightLC.constant = isiPhoneXScreen() ? 88 : 64
        topIV.isHidden = true
        
        if user != nil {
            uid = user!["uid"] as? String
            name = (user!["nickname"] as? String)!
            titleLB.text = self.name + "的动态"
        }
        collectionview.dzy_registerCellFromNib(TopicCell.self)
        collectionview.dzy_registerHeaderFromNib(PersonalPageHeadView.self)
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getTopicList(loadmore ? (self!.currentPage)!+1 : 1)
        }
        refresh.ifHasHead = false
        collectionview.srf_addRefresher(refresh)
        
        getOtherInfo()
        
        registObservers([
            Config.Notify_ExitMember
        ], queue: .main) { [weak self] (_) in
            self?.getOtherInfo()
        }
        
        registObservers([
            Config.Notify_PaySuccess
        ], queue: .main) { [weak self] (nofity) in
            if self?.payType == 20 {
                //支付成功的回调通知
                self?.payView?.hideCoachPayView()
                let alert =  UIAlertController.init(title: "支付成功", message: "恭喜你成为Ta的学员,并且自动加入Ta的部落组织", preferredStyle: .alert)
                let actionN = UIAlertAction.init(title: "确认", style: .cancel) { (_) in
                    
                }
                alert.addAction(actionN)
                self?.present(alert, animated: true, completion: nil)
                
                NotificationCenter.default.post(name: Config.Notify_BeCoachMember, object: nil)
            }else{
                self?.dataDic.removeValue(forKey: "payIM")
                self?.payIMView?.hideCoachPayView()
                
                self?.chatIMAction()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //    MARK: - 返回
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //进入聊天页面
    func chatIMAction()
    {
        let user = self.dataDic["user"] as! [String:Any]
        
        let conversationVC = MessageChatVC()
        conversationVC.conversationType = RCConversationType.ConversationType_PRIVATE
        conversationVC.targetId = "\(ToolClass.decryptUserId(user["uid"] as! String)!)"
        conversationVC.title = user["nickname"] as? String
        conversationVC.userInfo = user
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
//    MARK: - 更多
    @IBAction func moreAction(_ sender: UIButton) {
        if let uid = uid {
            let vc = PersonalMoreVC(uid, data: dataDic)
            dzy_push(vc)
        }
    }

    func getOtherInfo() {
        let request = BaseRequest()
        request.dic = ["uid":self.uid!]
        request.url = BaseURL.OtherInfo
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataDic = data!["personalPage"] as! [String:Any]
            let user = self.dataDic["user"] as! [String:Any]
            self.name = (user["nickname"] as? String)!
            self.titleLB.text = self.name + "的动态"
            if let cover = user.stringValue("cover") {
                self.topIV.setCoverImageUrl(cover)
            }
            self.isBlack = self.dataDic.intValue("isBlack") ?? 0
            self.getTopicList(1)
        }
    }
    
    func getTopicList(_ page: Int) {
        if isBlack == 1 {
            collectionview.reloadData()
            return
        }
        let request = BaseRequest()
        request.dic = ["uid":self.uid!]
        request.page = [page,20]
        request.url = BaseURL.OtherTopic
        request.isUser = true
        request.start { (data, error) in
            
            self.collectionview.srf_endRefreshing()
            self.topIV.isHidden = false
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            if self.currentPage == 1
            {
                
                self.dataArr.removeAll()
                
                if listData.isEmpty
                {
                }else{
                    self.collectionview.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.collectionview.srf_canLoadMore(true)
                }else{
                    self.collectionview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.collectionview.srf_canLoadMore(false)
            }
            
            self.dataArr.append(contentsOf: listData)
            self.collectionview.reloadData()
            self.collectionview.layoutIfNeeded()
        }
    }
    
    func attentionAPI(_ isAttention: Bool)
    {
        let request = BaseRequest()
        request.dic = ["uid":self.uid!,"type":isAttention ? "10" : "20"]
        request.url = BaseURL.Attention
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            NotificationCenter.default.post(name: Config.Notify_AttentionPersonal, object: nil, userInfo: ["uid":self.uid!])
        }
    }
    
    //成为教练学员
    func memberAPI(_ isMember: Bool)
    {
        let request = BaseRequest()
        request.dic = ["uid":self.uid!,"type":isMember ? "10" : "20"] //10 成为 20 取消
        request.url = BaseURL.CoachMember
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else
            {
                if error?.contains("汗水不足") == true {
                    self?.payView?.hideCoachPayView()
                    let vc = AddSweatVC()
                    self?.dzy_push(vc)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        ToolClass.showToast(error!, .Failure)
                    })
                }else {
                    ToolClass.showToast(error!, .Failure)
                }
                return
            }
            
            if isMember
            {
                // header 会接收通知进行 "申请会员" 按钮的隐藏和显示。 自己也会接收通知用来隐藏支付界面和提示成功
                NotificationCenter.default.post(name: Config.Notify_PaySuccess, object: nil)
                // 需要更新用户信息，传到里面界面的时候拿来判断
                self?.getOtherInfo()
                
            }else{
                // header 会接收通知进行 "申请会员" 按钮的隐藏和显示
                NotificationCenter.default.post(name: Config.Notify_ExitMember, object: nil)
                self?.getOtherInfo()
            }
            // 更新个人中的教练板块，发现板块中的部落部分
            NotificationCenter.default.post(name: Config.Notify_BeCoachMember, object: nil)
        }
    }
    
    func imPayAPI()
    {
        let request = BaseRequest()
        request.dic = ["uid":self.uid!]
        request.url = BaseURL.PayIM
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let payIM = data!["payIM"] as! Int
            if payIM == 1
            {
                //不需要支付 直接聊天
            }else{
                //需要支付费用
            }
            
        }
    }
    
}

extension PersonalPageVC:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    PersonalPageHeaderViewDelegate,
    TopicDetailScrollDelegate,
    CoachPayDelegate
{
    // MARK: - CoachPayDelegate
    func payCoachMember(_ dues: Int, payType: String) {
        memberAPI(true)
    }
    
    // MARK: - TopicDetailScrollDelegate
    func supportForIndex(_ indexPath: IndexPath, isSelect: Bool) {
        var dic = self.dataArr[indexPath.row]
        
        if (dic["isSupport"] as? Int) != nil
        {
            dic["isSupport"] = isSelect ? 1 : 0
        }
        
        var supportNum = dic["supportNum"] as! Int
        
        if isSelect
        {
            supportNum += 1
        }else{
            supportNum -= 1
        }
        dic["supportNum"] = supportNum
        
        self.dataArr[indexPath.row] = dic
        
        self.collectionview.reloadItems(at: [indexPath])
    }
    
    func needLoadMore() {
        self.getTopicList(self.currentPage!+1)
    }
    
    func scrollAtIndex(_ indexPath: IndexPath) {
        self.collectionview.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func applyAction() {
        payView = CoachPayView.showCoachPayView()
        payView?.delegate = self
        payView?.uid = self.uid
        let user = self.dataDic["user"] as! [String:Any]
        payView?.head = user["head"] as! String
        let dues = self.dataDic["dues"] as? Int
        payView?.dues = dues == nil ? 0 : dues!
        
        let free = self.dataDic["free"] as? Int
        
        if free != nil && free == 1
        {
            payView?.isFree = true
        }else{
            payView?.isFree = false
        }
        
        payType = 20
    }
    
    func attentionAction(_ isAttention: Bool) {
        self.attentionAPI(isAttention)
    }
    
    //    MARK: - 点击头像
    func headAction(_ image: UIImage) {
        let type = DzyShowImageType.image(image)
        let vc = DzyShowImageView(type)
        vc.show()
    }
    
    //    MARK: - 跳转聊天
    func imAction() {
        if isBlack == 1 {
            ToolClass.showToast("你已被对方拉黑，无法聊天", .Failure)
            return
        }
        chatIMAction()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(TopicCell.self, indexPath)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let head = collectionView
            .dzy_dequeueHeader(PersonalPageHeadView.self, indexPath)
        head?.delegate = self
        head?.setData(dataDic)
        return head!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        calculationHead.na_width = ScreenWidth
        calculationHead.setData(self.dataDic)
        calculationHead.setNeedsLayout()
        calculationHead.layoutIfNeeded()
        
        headerHeight = calculationHead.scrollview.contentSize.height
        return CGSize(width: collectionView.na_width, height: calculationHead.scrollview.contentSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let topicCell = cell as! TopicCell
        topicCell.setData(dataArr[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 3*16)/2
        return CGSize(width: width, height: width+76)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        vc.initIndex = indexPath
        vc.delegate = self
        vc.topicDetailModel = topicDetailModel
        vc.personalPageVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - 顶部缩放
extension PersonalPageVC: ScaleTopIVProtocol {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tempY = scrollView.contentOffset.y
        // 更改标题 view 的透明度  51 为 "动态" 所在view 的高度
        if tempY > headerHeight - 51.0 {
            let alpha = (tempY - (headerHeight - 51.0)) / 51.0
            titleView.alpha = alpha
        }else{
            titleView.alpha = 0
        }
        
        // 顶部缩放
        sacleFunction(-tempY)
    }
    
    var scaleIV: UIImageView {
        return topIV
    }
    
    var ivHeight: CGFloat {
        return 190.0
    }
    
    var ifHidden: Bool {
        return true
    }
}
