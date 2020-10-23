//
//  TribeFoundVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeFoundVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    var itemInfo = IndicatorInfo(title: "View")
    
    let topicDetailModel = TopicDetailModel()
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    var tribeArr = [[String:Any]]()
    
    var recommend = [[String:Any]]()
    
    var tidArr = [String]()
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        
        collectionview.register(UINib(nibName: "TopicCell", bundle: nil), forCellWithReuseIdentifier: "TopicCell")
        if DataManager.isCoach()
        {
            collectionview.register(UINib(nibName: "TribeFoundCoachHead", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TribeFoundCoachHead")
        }else{
            collectionview.register(UINib(nibName: "TribeFoundHead", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TribeFoundHead")
        }
        
        //empty View
        self.tableview.tableHeaderView = TribeFoundEmptyHead.instanceFromNib()
        self.tableview.register(UINib(nibName: "TribeRecommendCell", bundle: nil), forCellReuseIdentifier: "TribeRecommendCell")
        let refresh1 = Refresher{ [weak self] (loadmore) -> Void in
            
            self?.getCoachTribe()
     
        }
        tableview.srf_addRefresher(refresh1)

        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            
            if !loadmore
            {
                //刷新
                self?.getCoachTribe()
            }else{
                self?.getTopicList((self!.currentPage)!+1)
            }
        }
        collectionview.srf_addRefresher(refresh)
        getCoachTribe()
        
        //成为教练学员的时候 发现部落板块
        registObservers([
            Config.Notify_BeCoachMember
        ]) { [weak self] (_) in
            self?.getCoachTribe()
        }
        
        if DataManager.isCoach()
        {
            self.collectionview.isHidden = false
            self.tableview.isHidden = true
            return
        }
    }
    
    func getCoachTribe()
    {
        let request = BaseRequest()
        request.url = BaseURL.MyTribe
        request.isUser = true
        request.start { (data, error) in
            
            self.collectionview.srf_endRefreshing()
            self.tableview.srf_endRefreshing()
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.tribeArr = data?["list"] as! [[String:Any]]
            
            if self.tribeArr.count == 0
            {
                //没有任何加入的部落
                
                self.collectionview.isHidden = true
                self.tableview.isHidden = false
                if self.recommend.count == 0
                {
                    self.getRecommendTribe()
                }
                
            }else{
                self.getTopicList(1)
                self.collectionview.isHidden = false
                self.tableview.isHidden = true
            }
           
        }
    }
    
    
    func getTopicList(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["type":"20"]
        request.page = [page,20]
        request.url = BaseURL.TopicList
        request.isUser = true
        request.start { (data, error) in
            
            
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
    
    func getRecommendTribe()
    {
        let request = BaseRequest()
        request.url = BaseURL.RecommondTribe
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            
            self.recommend.append(contentsOf: listData)
            self.tableview.reloadData()
        }
    }
}

typealias TableViewDelegate = TribeFoundVC
extension TableViewDelegate: UITableViewDelegate,UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recommend.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let chartCell = cell as? TribeRecommendCell
        chartCell?.setData(self.recommend[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TribeRecommendCell", for: indexPath) as! TribeRecommendCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        let tap = DataManager.tribeTap()
        if tap == 0
        {
            let alert =  UIAlertController.init(title: "温馨提示", message: "申请成为Ta的学员将自动加入Ta的部落，且可以查看部落里面的所有内容", preferredStyle: .alert)
            let actionY = UIAlertAction.init(title: "确认", style: .destructive) { (_) in
                
                //保存弹框
                DataManager.saveTribeTap(1)
                //跳转到主页
                let dic = self.recommend[indexPath.row]
                let user = dic["user"] as! [String:Any]
                let vc = PersonalPageVC()
                vc.user = user
                self.tabBarController?.navigationController?.pushViewController(vc, animated: true)
                
            }
            let actionN = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
                
            }
            alert.addAction(actionY)
            alert.addAction(actionN)
            self.present(alert, animated: true, completion: nil)
        }else{
            let dic = self.recommend[indexPath.row]
            let user = dic["user"] as! [String:Any]
            let vc = PersonalPageVC()
            vc.user = user
            self.tabBarController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension TribeFoundVC: IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopicDetailScrollDelegate
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if DataManager.isCoach()
        {
            let head = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TribeFoundCoachHead", for: indexPath) as! TribeFoundCoachHead
            if self.tribeArr.count != 0
            {
                head.setData(self.tribeArr[0])
            }
            return head
        }else{
            let head = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TribeFoundHead", for: indexPath) as! TribeFoundHead
            head.setData(self.tribeArr)
            return head
        }
    }
    
    
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
