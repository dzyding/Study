//
//  PrivateTrainVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol PrivateTrainSelectPlanDelegate: NSObjectProtocol {
    func selectMotionPlan(_ plan: [String:Any])
}

class PrivateTrainVC: BaseVC {

    @IBOutlet weak var colList: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    weak var delegate:PrivateTrainSelectPlanDelegate?
    
    var other:[String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.itemSize = CGSize.init(width: (ScreenWidth - 16 * 3)/2.0, height: (ScreenWidth - 16 * 3)/2.0)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        layout.sectionInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        
        colList.register(UINib.init(nibName: "PrivateTrainCell", bundle: nil), forCellWithReuseIdentifier: "PrivateTrainCell")
        colList.alwaysBounceVertical = true
        colList.delegate = self
        colList.dataSource = self
        colList.showsVerticalScrollIndicator = false
        colList.showsHorizontalScrollIndicator = false
        colList.backgroundColor = BackgroundColor
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getCourseList()
        }
        
        colList.srf_addRefresher(refresh)
        getCourseList()
        
        if self.other != nil
        {
            self.title = self.other!["nickname"] as! String + "的计划库"
        }
    }
    
    //计划列表
    func getCourseList() {
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanList
        if self.other == nil
        {
            request.isUser = true
        }else{
            request.otherUid = self.other!["uid"] as? String
        }
        
        request.start { (data, error) in
            
            self.colList.srf_endRefreshing()
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr.removeAll()
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.dataArr.append(contentsOf: listData)
            self.colList.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension PrivateTrainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivateTrainCell", for: indexPath) as! PrivateTrainCell
        cell.setData(data: dataArr[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dic = dataArr[indexPath.row]

        if self.delegate != nil
        {
            self.delegate?.selectMotionPlan(dic)
            self.navigationController?.popViewController(animated: true)
        }else{
            let vc = CoachPlanDetailVC()
            vc.dataDic = dic
            if self.other == nil
            {
                vc.owner = DataManager.userInfo()
            }else{
                vc.owner = self.other
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    

    }
    
}













