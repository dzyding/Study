//
//  MyLikeVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MyLikeVC : BaseVC
{
    @IBOutlet weak var collectionview: UICollectionView!
    
    let topicDetailModel = TopicDetailModel()
    
    override var dataArr : [[String:Any]]
        {
        didSet{
            topicDetailModel.dataTopic = dataArr
        }
    }
    
    override func viewDidLoad() {
        
        self.title = "我的喜欢"

        collectionview.register(UINib(nibName: "TopicCell", bundle: nil), forCellWithReuseIdentifier: "TopicCell")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        collectionview.srf_addRefresher(refresh)
        
        getData(1)
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.page = [page,20]
        request.isUser = true
        request.url = BaseURL.MySupportTopic
        request.start { (data, error) in
            
            self.collectionview.srf_endRefreshing()
            
            guard error == nil else
            {
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

extension MyLikeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopicDetailScrollDelegate
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
        self.getData(self.currentPage!+1)
    }
    
    func scrollAtIndex(_ indexPath: IndexPath) {
        self.collectionview.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
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

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        vc.initIndex = indexPath
        vc.delegate = self
        vc.topicDetailModel = topicDetailModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 3*16)/2
        return CGSize(width: width, height: width+76)
    }
    
}
