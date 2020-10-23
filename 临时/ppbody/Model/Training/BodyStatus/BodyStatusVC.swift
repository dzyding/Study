//
//  BodyStatusVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/15.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BodyStatusVC: BaseVC {
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var barCollection: UICollectionView!
    
    @IBOutlet weak var scrollContent: UIScrollView!
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var currentIndex: IndexPath?
    
    var isOther = false
    
    lazy var typeArr = {
        return [["基本", "1", "0"],
                ["体重", "0", "0"],
                ["骨骼肌", "0", "0"],
                ["脂肪", "0", "0"],
                ["胸围", "0", "0"],
                ["臀围", "0", "0"],
                ["腰围", "0", "0"],
                ["臂围", "0", "0"],
                ["腿围", "0", "0"]]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "身材指标"
        layout.itemSize = CGSize.init(width: 40.0, height: 72.0)
        layout.minimumLineSpacing = 35
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 16.0, bottom: 0, right: 16.0)
        layout.minimumInteritemSpacing = 0
        
        barCollection.register(UINib.init(nibName: "BarCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BarCollectionCell")
        barCollection.showsHorizontalScrollIndicator = false
        barCollection.backgroundColor = CardColor
        
        let firstVc = BodyStatusFirstVC("")
        addChild(firstVc)
        firstVc.view.frame = scrollContent.bounds
        scrollContent.addSubview(firstVc.view)
        
        currentIndex = IndexPath.init(row: 0, section: 0)
        
        for i in 1 ..< typeArr.count {
            let vc = BodyStatusRulerVC()
            vc.delegate = self
            switch i
            {
            case 1:
                vc.bodyStatusType = BodyStatusType.Weight
                break
            case 2:
                vc.bodyStatusType = BodyStatusType.Muscle
                break
            case 3:
                vc.bodyStatusType = BodyStatusType.Fat
                break
            case 4:
                vc.bodyStatusType = BodyStatusType.Bust
                break
            case 5:
                vc.bodyStatusType = BodyStatusType.Hipline
                break
            case 6:
                vc.bodyStatusType = BodyStatusType.Waist
                break
            case 7:
                vc.bodyStatusType = BodyStatusType.Arm
                break
            case 8:
                vc.bodyStatusType = BodyStatusType.Thigh
                break
            default:
                break
            }
            addChild(vc)
        }
        scrollContent.isPagingEnabled = true
        scrollContent.bounces = false
        scrollContent.showsVerticalScrollIndicator = false
        scrollContent.showsHorizontalScrollIndicator = false
        scrollContent.delegate = self
        
        
        btnSave.addTarget(self, action: #selector(btnSaveClick), for: .touchUpInside)
        btnSaveIsHidder()
        
        //判断是否是学员
        if DataManager.memberInfo() != nil {
            isOther = true
            let member = DataManager.memberInfo()
            title = member!["nickname"] as! String + "的体态数据"
        }
        
        getBodyData()
    }
    
    func btnSaveIsHidder() {
        if self.currentIndex?.row == 0 {
            self.btnSave.isHidden = true
        }
        else {
            self.btnSave.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollContent.contentSize = CGSize.init(width: ScreenWidth * CGFloat(typeArr.count), height: scrollContent.bounds.size.height)
    }
    
    @objc func btnSaveClick() {
        if !dataDic.isEmpty
        {
            btnSave.isEnabled = false
            publishBodyData()
        }
    }
    
    func getBodyData() {
        let request = BaseRequest()
        if isOther
        {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.BodyData
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let body = data!["body"] as! [String:Any]
            
            for vc in self.children
            {
                if let firstVC = vc as? BodyStatusFirstVC
                {
                    firstVC.setBodyData(body)
                }else if let ruler = vc as? BodyStatusRulerVC
                {
                    ruler.dataDic = body
                }
            }            
        }
    }
    
    func publishBodyData()
    {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String : String]
        if isOther {
            //教练上传需要上传个人uid
            request.isOther = true
            request.dic["coachUid"] = DataManager.userAuth()
        }else{
            request.isUser = true
        }
        request.url = BaseURL.AddBodyData
        request.start { (data, error) in
            
            self.btnSave.isEnabled = true
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("体态数据记录成功", .Success)
            

            NotificationCenter.default.post(name: Config.Notify_BodyDataChange, object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}


extension BodyStatusVC : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate,BodyStatusRulerSelectDelegate {
    
    //MARK: BodyStatusRulerSelectDelegate
    func selectRuler(_ type: BodyStatusType, isChange: Bool, value: CGFloat) {
        var bodypart = ""
        var index = 0
        switch type {
        case .Weight:
            bodypart = "weight"
            index = 1
        case .Muscle:
            bodypart = "muscle"
            index = 2
        case .Fat:
            bodypart = "fat"
            index = 3
        case .Bust:
            bodypart = "bust"
            index = 4
        case .Hipline:
            bodypart = "hipline"
            index = 5
        case .Waist:
            bodypart = "waist"
            index = 6
        case .Arm:
            bodypart = "arm"
            index = 7
        case .Thigh:
            bodypart = "thigh"
            index = 8
        }
        
        if isChange
        {
            self.dataDic[bodypart] = "\(value)"
            self.typeArr[index][2] = "1"
        }else{
            self.typeArr[index][2] = "0"
            self.dataDic.removeValue(forKey: bodypart)
        }

        self.barCollection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BarCollectionCell", for: indexPath) as? BarCollectionCell
        cell?.setData(arr: typeArr[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.currentIndex == indexPath {
            return
        }
        else {
            self.currentIndex = indexPath
        }
        self.changeSelectedStatus(indexPath.row)
        self.scrollContent.setContentOffset(CGPoint.init(x: CGFloat(indexPath.row)*ScreenWidth, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollContent {
            let index = scrollView.contentOffset.x/ScreenWidth
            if self.currentIndex == IndexPath.init(row: Int(index), section: 0) {
                return
            }
            else {
                self.currentIndex = IndexPath.init(row: Int(index), section: 0)
            }
            self.changeSelectedStatus(Int(index))
        }
    }
    
    func changeSelectedStatus(_ index: Int) {
        let vc = self.children[index]
        if !self.scrollContent.subviews.contains(vc.view) {
            self.scrollContent.addSubview(vc.view)
            vc.view.frame = CGRect.init(x: ScreenWidth * CGFloat(index), y: 0, width: ScreenWidth, height: self.scrollContent.bounds.size.height)
        }
        for i in 0..<typeArr.count {
            typeArr[i][1] = "0"
            if index == i {
                typeArr[index][1] = "1"
            }
        }
        self.barCollection.reloadData()
        self.btnSaveIsHidder()
        
        let barNewAttributes = self.barCollection.layoutAttributesForItem(at: self.currentIndex!)
        
        if CGFloat((barNewAttributes?.frame.origin.x)!) > self.barCollection.frame.size.width/2.0 || (barNewAttributes?.frame.origin.x)! >= (self.barCollection.contentOffset.x + self.view.frame.size.width - self.barCollection.contentInset.left) {
            let alignmentOffset = (self.view.frame.size.width - (barNewAttributes?.frame.size.width)!) * 0.5
            var contentOffset = (barNewAttributes?.frame.origin.x)! - alignmentOffset
            contentOffset = max(0, contentOffset)
            contentOffset = min(self.barCollection.contentSize.width - self.view.frame.size.width, contentOffset)
            let targetContentOffset = self.barCollection.contentSize.width > self.view.frame.size.width ? contentOffset : 0
            self.barCollection.setContentOffset(CGPoint.init(x: targetContentOffset, y: 0), animated: true)
        }
        else {
            self.barCollection.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
    }
}

