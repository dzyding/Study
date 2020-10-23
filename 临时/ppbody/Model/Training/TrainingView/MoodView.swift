//
//  MoodView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation



class MoodView: UIView{
    
    @IBOutlet weak var scalingview: ScalingCarouselView!
    
    @IBOutlet weak var emptyView: UIView!
    var topic:[String:Any]?
    
    @IBOutlet weak var tipIV: UIImageView!
    
    var tapGesture: UITapGestureRecognizer?
    
    @IBAction func publicTopicAction(_ sender: UIButton) {
        
        TopicTag = "今日打卡"
    
        let parent = ToolClass.controller2(view: self)

        let mask = MaskPublicView.instanceFromNib()
        mask.initUI()
        mask.frame = ScreenBounds
        mask.navigationVC = parent?.tabBarController?.navigationController
        UIApplication.shared.keyWindow?.addSubview(mask)
    }
    
    var dataArr = [String]()
    
    class func instanceFromNib() -> MoodView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[3] as! MoodView
    }
    
    
    override func awakeFromNib() {
        self.scalingview.delegate = self
        self.scalingview.dataSource = self
        self.scalingview.register(UINib(nibName: "MoodViewCell", bundle: nil), forCellWithReuseIdentifier: "MoodViewCell")
        if DataManager.firstRegister() == 1
        {
            self.tipIV.isHidden = false
            ToolClass.dispatchAfter(after: 8) {
                self.tipIV.isHidden = true
            }
        }else{
            self.tipIV.removeFromSuperview()
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(publicTopicAction(_:)))
    }
    
    func setData(_ dic: [String:Any]?) {
        dataArr.removeAll()
        removeGestureRecognizer(tapGesture!)
        if dic == nil {
            emptyView.isHidden = false
            scalingview.reloadData()
            addGestureRecognizer(tapGesture!)
            return
        }
        emptyView.isHidden = true
        
        topic = dic
        if let imgArr = dic!["imgs"] as? [String] {
            if imgArr.count > 0 {
                dataArr = imgArr
            }else{
                dataArr.append(dic!["cover"] as! String)
            }
        }
        scalingview.reloadData()
    }
}

typealias CarouselDatasource = MoodView
extension CarouselDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodViewCell", for: indexPath) as! MoodViewCell

        let url = self.dataArr[indexPath.row]
        
        let video = self.topic!["video"] as? String
        
        cell.setData(url,type: video == nil || video == "" ? 10 : 20)
        
        return cell
    }
}

typealias CarouselDelegate = MoodView
extension CarouselDelegate: UICollectionViewDelegate,TopicDetailScrollDelegate {
    
    // MARK: - TopicDetailScrollDelegate
    func needLoadMore() {
    }
    
    func scrollAtIndex(_ indexPath: IndexPath) {
        
   
    }
    
    func supportForIndex(_ indexPath: IndexPath, isSelect: Bool) {
        
        if (self.topic!["isSupport"] as? Int) != nil
        {
            self.topic!["isSupport"] = isSelect ? 1 : 0
        }
        
        var supportNum = self.topic!["supportNum"] as! Int
        
        if isSelect
        {
            supportNum += 1
        }else{
            supportNum -= 1
            
            supportNum = supportNum < 0 ? 0 : supportNum
        }
        self.topic!["supportNum"] = supportNum
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scalingview.didScroll()
        
        guard (scalingview.currentCenterCellIndex?.row) != nil else { return }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TopicDetailVC()
        vc.hbd_barAlpha = 0
        
        let topicDetailModel = TopicDetailModel()
        topicDetailModel.dataTopic = [self.topic] as! [[String : Any]]
        vc.topicDetailModel = topicDetailModel
        vc.initIndex = IndexPath(row: 0, section: 0)
        vc.delegate = self
        let parent = ToolClass.controller2(view: self)
        parent?.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
}

private typealias ScalingCarouselFlowDelegate = MoodView
extension ScalingCarouselFlowDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
