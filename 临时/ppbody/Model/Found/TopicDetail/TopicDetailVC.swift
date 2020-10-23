//
//  TopicDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

protocol TopicDetailActionDelegate: NSObjectProtocol{
    //显示评论
    func commentShowAction(_ tid: String, indexPath: IndexPath)
    //详情
    func detailAction(_ dic:[String:Any])
    //评论
    func commentAction(_ tid: String, indexPath: IndexPath)
    //分享
    func shareAction(_ tid: String, indexPath: IndexPath)
    //点赞
    func supportAction(_ tid: String, isSupport: Bool, indexPath: IndexPath)
    //送礼
    func giftAction(_ indexPath: IndexPath?)
    
    //点击头像
    func personalPage(indexPath: IndexPath)
    
    //@谁的传递
    func directAction()
}

@objc protocol TopicDetailScrollDelegate {
    //需要加载更多
    func needLoadMore()
    //滑动到哪一个index
    func scrollAtIndex(_ indexPath: IndexPath)
    //点赞了哪一个
    @objc optional func supportForIndex(_ indexPath: IndexPath, isSelect: Bool)
}


class TopicDetailVC: BaseVC {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    /// 送礼弹出框
    lazy var popView: DzyPopView = {
        let v = GiftPopView.initFromNib(GiftPopView.self)
        v.delegate = self
        v.parentVCView = view
        v.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: GiftPopView.height)
        
        let pop = DzyPopView(.POP_bottom, viewBlock: v)
        pop.ifNeedBg = false
        return pop
    }()
    
    var topicDetailModel:TopicDetailModel!
    
    var personalPageVC:PersonalPageVC?
    
    lazy var commentListView:TopicCommentListView = {
        let commentListView = TopicCommentListView.instanceFromNib()
        return commentListView
    }()
    
    lazy var commentView:TopicCommentView = {
        let commentView = TopicCommentView.instanceFromNib()
        return commentView
    }()
    
    lazy var detailView: TopicContentDetailView = {
        let detailView = TopicContentDetailView.instanceFromNib()
        return detailView
    }()
    
    var initPlay = false
    
    var initIndex: IndexPath?
    var initScroll = false
    
    var willdisplayCell:UICollectionViewCell?
    
//    var lastVideoCell:VideoTopicDetailCell?
    
    var videoCellArr = [VideoTopicDetailCell]()
    
    weak var delegate:TopicDetailScrollDelegate?
    
    @objc dynamic var currentIndex = 0
    var isCurPlayerPause:Bool = false
    
    deinit {
        print("========deinit：TopicDetailVC=======================")
        topicDetailModel.collectionview = nil
        let cells = collectionview.visibleCells
        for cell in cells  {
            if let videoCell = cell as? VideoTopicDetailCell {
                videoCell.cancelLoading()
            }
        }
        NotificationCenter.default.removeObserver(self)
        self.removeObserver(self, forKeyPath: "currentIndex")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicDetailModel.collectionview = self.collectionview
        ToolClass.adjustsScrollViewInsetNever(self, collectionview)
        
        collectionview.register(UINib(nibName: "VideoTopicDetailCell", bundle: nil), forCellWithReuseIdentifier: "VideoTopicDetailCell")
        collectionview.register(UINib(nibName: "ImageTopicDetailCell", bundle: nil), forCellWithReuseIdentifier: "ImageTopicDetailCell")
        collectionview.scrollsToTop = false

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.currentIndex = self.initIndex!.row
            let curIndexPath = IndexPath.init(row: self.currentIndex, section: 0)
            self.collectionview.scrollToItem(at: curIndexPath, at: .centeredVertically, animated: false)
            
            self.collectionview.setNeedsLayout()
            self.collectionview.layoutIfNeeded()

            self.addObserver(self, forKeyPath: "currentIndex", options: [.initial, .new], context: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        // 刷新汗水值
        getUserSweatApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        let cells = collectionview.visibleCells
        for cell in cells  {
            if let videoCell = cell as? VideoTopicDetailCell
            {
                videoCell.play()
                
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        view.endEditing(true)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        

        var isPause = false
        
        let childs = self.navigationController?.children
        
        if childs != nil
        {
            for v in childs!
            {
                if v is TopicDetailVC
                {
                    isPause = true
                }
            }
        }  
        
        let cells = collectionview.visibleCells
        for cell in cells  {
            if let videoCell = cell as? VideoTopicDetailCell
            {
                if isPause
                {
                    videoCell.pause()
                }else{
                    videoCell.cancelLoading()
                }
            }
        }
        
    }
    
    @objc func applicationBecomeActive() {
        let cell = collectionview.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))  as? VideoTopicDetailCell
        if cell != nil && !isCurPlayerPause {
            cell!.play()
        }
    }
    
    @objc func applicationEnterBackground() {
        let cell = collectionview.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) as? VideoTopicDetailCell
        if cell != nil {
            isCurPlayerPause = cell!.playerView.rate() == 0 ? true :false
            cell!.pause()
        }
    }
    
    //    MARK: - 送礼 api
    @objc func sendGiftApi(_ tid: String, _ giftID: String, _ num: String) {
        let request = BaseRequest()
        request.url = BaseURL.GiveGift
        request.dic = [
            "tid": tid,
            "giftId" : giftID,
            "num" : num
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            guard let count = Int(num) else {return}
            self?.changeLocalSweat(count, giftID)
        }
    }
    
    //    MARK: - 获取汗水值
    func getUserSweatApi() {
        let request = BaseRequest()
        request.url = BaseURL.UserSweat
        request.isUser = true
        request.start { (data, error) in
            if let sweat = data?.intValue("sweat") {
                DataManager.changeSweat(sweat)
            }
        }
    }
    
    //     MARK: - 更改本地汗水记录
    func changeLocalSweat(_ count: Int, _ giftID: String) {
        popView.subviews.forEach { (v) in
            if let numView = v as? GiftPopView {
                numView.changeSwaet(-count, giftID)
            }
        }
    }
    
    //    MARK: - 送礼动画
    func sendGiftAnimate(_ rectS: CGRect, rectE: CGRect, copyImg: UIImage) {
        let widthS = UI_W(60)
        //第一个Frame
        let first = CGRect(x: rectS.midX - widthS / 2.0, y: rectS.midY - widthS / 2.0, width: widthS, height: widthS)
        //第五个Frame (根据最终的frame调整了一下中心点)
        let fifth  = CGRect(x: rectE.midX - UI_W(15), y: rectE.midY - UI_W(15), width: UI_W(30), height: UI_W(30))
        // y 运动的全程
        let maxY = fifth.midY - first.midY
        //x 平分
        let x = (fifth.minX - first.minX) / 4.0
        // y 平分
        let y = maxY / 2.0
        //第二个Frame
        let second = CGRect(x: first.midX + x - UI_W(27), y: first.minY + y, width: UI_W(54), height: UI_W(54))
        //第三个Frame
        let third  = CGRect(x: second.midX + x - UI_W(23), y: second.minY + y, width: UI_W(46), height: UI_W(46))
        //第四个Frame
        let forth  = CGRect(x: third.midX + x - UI_W(21), y: third.minY - 20.0, width: UI_W(42), height: UI_W(42))
        
        let imgView = UIImageView(image: copyImg)
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        imgView.frame = first
        view.addSubview(imgView)
        
        UIView.animate(withDuration: 1.2) {
            imgView.transform = imgView.transform.rotated(by: 2.0)
        }
        
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                imgView.frame = second
            })
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.6, animations: {
                imgView.frame = third
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.8, animations: {
                imgView.frame = forth
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 1.0, animations: {
                imgView.frame = fifth
            })
        }) { (finished) in
            imgView.removeFromSuperview()
        }
    }
}

//MARK: - 送礼的相关代理
extension TopicDetailVC: GiftPopViewDelegate {
    // 前往钱包
    func gotoWallet() {
        let vc = AddSweatVC()
        dzy_push(vc)
    }
    
    // 送礼
    func sendAction(rentS: CGRect, image: UIImage, count: Int, giftID: Int) {
        // 动画
        func animate() {
            let cell = collectionview.cellForItem(at: IndexPath(item: currentIndex, section: 0))
            var rentE = CGRect.zero
            if let cell = cell as? VideoTopicDetailCell {
                rentE = cell.controllerview.convert(cell.controllerview.headIV.frame, to: view)
            }else if let cell = cell as? ImageTopicDetailCell {
                rentE = cell.controllerview.convert(cell.controllerview.headIV.frame, to: view)
            }
            sendGiftAnimate(rentS, rectE: rentE, copyImg: image)
        }
        
        let dic = topicDetailModel.indexObjec(currentIndex)
        if let tid = dic.stringValue("tid") {
            sendGiftApi(tid, "\(giftID)", "\(count)")
            // 不需要管请求是否成功
            animate()
            commentSuccessIndexPath(IndexPath(item: currentIndex, section: 0))
        }
    }
}

extension TopicDetailVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopicDetailActionDelegate,CommentSuccessActionDelegate
{
    //MARK: - CommentSuccessActionDelegate
    func commentSuccessIndexPath(_ indexPath: IndexPath) {
        let cell = collectionview.cellForItem(at: indexPath)
        
        if let imagecell = cell as? ImageTopicDetailCell
        {
            let commentNum = Int(imagecell.controllerview.commentNumLB.text!)!
            imagecell.controllerview.commentNumLB.text = "\(commentNum+1)"
        }else if let videocell = cell as? VideoTopicDetailCell{
            let commentNum = Int(videocell.controllerview.commentNumLB.text!)!
            videocell.controllerview.commentNumLB.text = "\(commentNum+1)"
        }
        
        topicDetailModel.commentForIndex(indexPath.row)
    }
    
    //MARK: - TopicDetailActionDelegate
    
    // 送礼
    func giftAction(_ indexPath: IndexPath?) {
        popView.show(view)
    }
    
    func directAction() {
        
    }
    
    func commentShowAction(_ tid: String, indexPath: IndexPath) {
        
        commentListView.tid = tid
        
        let dic = topicDetailModel.indexObjec(indexPath.row)
        let user = dic["user"] as! [String:Any]
        commentListView.topicUid = user["uid"] as! String
        commentListView.indexPath = indexPath
        commentListView.delegate = self
        commentListView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(commentListView)
        
        UIView.animate(withDuration: 0.25) {
            self.commentListView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }
    
    func commentAction(_ tid: String, indexPath: IndexPath) {
        commentView.tid = tid
        commentView.indexPath = indexPath
        commentView.delegate = self
        commentView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(commentView)
        
        UIView.animate(withDuration: 0.25) {
            self.commentView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }
    
    func shareAction(_ tid: String, indexPath: IndexPath) {
        let dic = topicDetailModel.indexObjec(indexPath.row)
        let sharePlatformView = SharePlatformView.instanceFromNib()
        sharePlatformView.frame = ScreenBounds
        sharePlatformView.dataDic = dic
        sharePlatformView.initUI(.topic)
        sharePlatformView.reportHandler = { [weak self] in
            let vc = ReportListVC(.video, data: dic)
            self?.dzy_push(vc)
        }
        UIApplication.shared.keyWindow?.addSubview(sharePlatformView)
    }
    
    func supportAction(_ tid: String, isSupport: Bool, indexPath: IndexPath) {
        let request = BaseRequest()
        request.dic = ["type":isSupport ? "10" : "20", "tid":tid]
        request.url = BaseURL.SupportTopic
        request.isUser = true
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            
            self.topicDetailModel.supportForIndex(indexPath.row, isSelect: isSupport)
            self.delegate?.supportForIndex!(indexPath, isSelect: isSupport)
        }
    }
    
    func detailAction(_ dic: [String : Any]) {
        detailView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        detailView.setData(dic)
        self.view.addSubview(detailView)
        
        UIView.animate(withDuration: 0.25) {
            self.detailView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }
    
    func personalPage(indexPath: IndexPath) {
        
        if personalPageVC != nil
        {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let dic = topicDetailModel.indexObjec(indexPath.row)
        let user = dic["user"] as! [String:Any]
        
        let vc = PersonalPageVC()
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    MARK: - UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicDetailModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dic = topicDetailModel.indexObjec(indexPath.row)
        let video = dic["video"] as? String
        if video != nil && !(video?.isEmpty)!
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoTopicDetailCell", for: indexPath) as! VideoTopicDetailCell
            cell.setData(dic, indexPath: indexPath)
            cell.delegate = self
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTopicDetailCell", for: indexPath) as! ImageTopicDetailCell
            cell.setData(dic, indexPath: indexPath)
            cell.delegate = self
            
            return cell
        }
    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//
//        let rectInSuperview = self.collectionview.convert(cell.frame, to: self.view)
////
////        let dic = topicDetailModel.indexObjec(indexPath.row)
////
////                print("willDisplay",cell)
//        willdisplayCell = cell
//
//
//        if let aliCell = cell as? VideoTopicDetailCell
//        {
//
//            if !videoCellArr.contains(aliCell)
//            {
//                videoCellArr.append(aliCell)
//            }
//
//            lastVideoCell = aliCell
//
////            aliCell.coverIV.isHidden = false
//            if abs(rectInSuperview.origin.y) < 10
//            {
//                if self.initIndex?.row == 0 || (self.initIndex?.row != 0 && cell.frame.origin.y > 0)
//                {
////                    aliCell.startVideoPlay()
//                }
//            }
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
////         print("didEndDisplaying",cell)
//
//        if willdisplayCell == cell
//        {
//            //没有滑动
//            //            lastVideoCell?.reset()
//        }else{
//            //滑动了
////            videoTopicModel.reset()
////            AVPlayerManager.shared().pauseAll()
//        }
//    }
//
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ScreenBounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//        for cell in self.collectionview.visibleCells
//        {
//            let rectInSuperview = self.collectionview.convert(cell.frame, to: self.view)
//            if rectInSuperview.origin.y == 0
//            {
//                let indexPath = self.collectionview.indexPath(for: cell)
//                self.delegate?.scrollAtIndex(indexPath!)
//
//
//                if let alicell = cell as? VideoTopicDetailCell
//                {
//                    print("startVideoPlay")
//                    alicell.startVideoPlay()
//                }
//
//            }
//        }
        
        let index = Int(scrollView.contentOffset.y/ScreenHeight)
        if self.currentIndex != index{
            self.currentIndex = index
            self.delegate?.scrollAtIndex(IndexPath(row: self.currentIndex, section: 0))
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
 
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "currentIndex") {
            isCurPlayerPause = false
            weak var cell = collectionview.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) as? VideoTopicDetailCell
            if cell?.isPlayerReady ?? false {
                cell?.replay()
            } else {
                AVPlayerManager.shared().pauseAll()
                cell?.onPlayerReady = {[weak self] in
                    if let indexPath = self?.collectionview?.indexPath(for: cell!) {
                        if !(self?.isCurPlayerPause ?? true) && indexPath.row == self?.currentIndex {
                            cell?.play()
                        }
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
