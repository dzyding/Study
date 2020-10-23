//
//  TopicTagDetailVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicTagDetailVC: BaseVC {
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var joinBtn: UIButton!
    
    @IBOutlet weak var qdbgIV: UIImageView!
    
    @IBOutlet weak var qdMsgLB: UILabel!
    
    @IBOutlet weak var qdBtn: UIButton!
    
    @IBOutlet weak var qdView: UIView!
    
    let calculationHead = TopicTagDetailHeadView.instanceFromNib()
    var headerHeight:CGFloat = 0
    
    var tag:String?
    
    let topicDetailModel = TopicDetailModel()
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dzy_registerCellFromNib(TopicCell.self)
        collectionview.dzy_registerHeaderFromNib(
            TopicTagDetailHeadView.self)
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getTopicList(loadmore ? (self!.currentPage)!+1 : 1)
        }
        collectionview.srf_addRefresher(refresh)
        getTopicTagDetail()
    }
    
    @IBAction func joinAction(_ sender: UIButton) {
        TopicTag = self.tag
        let mask = MaskPublicView.instanceFromNib()
        mask.initUI()
        mask.frame = ScreenBounds
        mask.navigationVC = self.navigationController
        UIApplication.shared.keyWindow?.addSubview(mask)
    }
    
    // 初始化
    func updateUI()  {
        joinBtn.isHidden = dataDic.intValue("status") == 20
        if let clock = dataDic.intValue("clock"), clock > 0 {
            qdView.isHidden = false
            if dataDic.intValue("isClock") == 1 {
                updateQdMsg(false)
            }
        }
    }
    
    // 更新
    func updateQdMsg(_ ifUpdate: Bool) {
        guard let max = dataDic.intValue("clock"),
            var num = dataDic.intValue("clockNum")
        else {return}
        if ifUpdate {num += 1}
        qdbgIV.image = UIImage(named: "topicTag_qd_yes")
        qdMsgLB.textColor = .white
        qdMsgLB.text = "\(num)/\(max)"
        qdBtn.isUserInteractionEnabled = false
    }
    
    @IBAction func qdAction(_ sender: UIButton) {
        qdAction()
    }
    
    func getTopicTagDetail()
    {
        let request = BaseRequest()
        request.dic = ["tag":self.tag!]
        request.url = BaseURL.TagDetail
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataDic = data!["topicTag"] as! [String:Any]
            self.updateUI()
            self.getTopicList(1)
        }
    }
    
    func qdAction() {
        let request = BaseRequest()
        request.url = BaseURL.clockTopicTag
        request.dic = ["tag" : tag ?? ""]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self?.updateQdMsg(true)
        }
    }
    
    
    func getTopicList(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["tag":self.tag!]
        request.page = [page,20]
        request.url = BaseURL.TagTopicList
        request.isUser = true
        request.start { (data, error) in
            
            self.collectionview.srf_endRefreshing()
            
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
}


extension TopicTagDetailVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TopicDetailScrollDelegate
{
    
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
        let head = collectionView.dzy_dequeueHeader(
            TopicTagDetailHeadView.self,
            indexPath)
        head?.setData(self.dataDic)
        return head!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        calculationHead.na_width = ScreenWidth
        calculationHead.setData(self.dataDic)
        calculationHead.setNeedsLayout()
        calculationHead.layoutIfNeeded()
        
        headerHeight = calculationHead.scrollview.contentSize.height + 32
        return CGSize(width: collectionView.na_width, height: headerHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let topicCell = cell as! TopicCell
        topicCell.setData(dataArr[indexPath.row],topic: true)
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
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > self.headerHeight
        {
            self.title = "#" + self.tag!
        }else{
            self.title = ""
        }
    }
    
}
