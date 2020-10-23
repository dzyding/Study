//
//  TribeFoundVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AttentionFoundVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var collectionview: UICollectionView!
    var itemInfo = IndicatorInfo(title: "View")
    
    let topicDetailModel = TopicDetailModel()
    
    lazy var emptyView:EmptyView = {
        let emptyview = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        emptyview.setStyle(EmptyStyle.AttentionEmpty)
        return emptyview
    }()
    
    var tidArr = [String]()

    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
        
    }
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        
        collectionview.register(UINib(nibName: "TopicCell", bundle: nil), forCellWithReuseIdentifier: "TopicCell")
//        collectionview.register(UINib(nibName: "AttentionFoundHead", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AttentionFoundHead")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getTopicList(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        collectionview.srf_addRefresher(refresh)
        
        getTopicList(1)
        
        registObservers([
            Config.Notify_AttentionPersonal
        ]) { [weak self] (_) in
            self?.getTopicList(1)
        }
    }
    
    func getTopicList(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["type":"30"]
        request.page = [page,20]
        request.url = BaseURL.TopicList
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
                self.tidArr.removeAll()
                if listData.isEmpty
                {
                    if self.emptyView.superview == self.collectionview
                    {
                        return
                    }
                    self.collectionview.addSubview(self.emptyView)
                    self.emptyView.center = CGPoint(x: self.collectionview.bounds.width/2, y: self.collectionview.bounds.height/2 + 90)
                    self.collectionview.reloadData()
                    return
                    
                }else{
                    self.emptyView.removeFromSuperview()
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
            
            var dataList = [[String:Any]]()
            for dic in listData
            {
                let tid = dic["tid"] as! String
                if self.tidArr.contains(tid)
                {
                    continue
                }
                self.tidArr.append(tid)
                dataList.append(dic)
            }
            self.dataArr.append(contentsOf: dataList)
            self.collectionview.reloadData()
            self.collectionview.layoutIfNeeded()
        }
    }
}

extension AttentionFoundVC: IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopicDetailScrollDelegate
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
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let topicCell = cell as! TopicCell
        topicCell.setData(dataArr[indexPath.row])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "TopicCell", for: indexPath) as! TopicCell
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        let head = collectionview.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AttentionFoundHead", for: indexPath)
//        return head
//        
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        vc.initIndex = indexPath
        vc.delegate = self
        vc.topicDetailModel = topicDetailModel
        self.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 3*16)/2
        return CGSize(width: width, height: width+76)
    }
    
}
