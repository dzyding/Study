//
//  StudentCourseDetailVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class StudentCourseDetailVC: BaseVC {
    
    @IBOutlet weak var scalingview: ScalingCarouselView!
    @IBOutlet weak var pageController: NaPageControl!
    @IBOutlet weak var flowLayout: MotionGroupFlowLayout!
    
    var planCode:String?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "课程详情"
                
        self.scalingview.register(UINib(nibName: "StudentCourseDetailCell", bundle: nil), forCellWithReuseIdentifier: "StudentCourseDetailCell")
  
        
        getData()
    }
    
    
    

    func getData() {
        let request = BaseRequest()
        request.dic = ["planCode": planCode!]
        request.url = BaseURL.MotionForPlan
        request.start { (data, error) in
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.dataArr = listData
            self.scalingview.reloadData()
  
            self.pageController.numberOfPages = self.dataArr.count
            self.pageController.currentPage = 0
        }
    }

}

extension StudentCourseDetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentCourseDetailCell", for: indexPath) as! StudentCourseDetailCell
        let dic = self.dataArr[indexPath.row]
        
        cell.setData(dic)
        
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scalingview.didScroll()
        
        guard (scalingview.currentCenterCellIndex?.row) != nil else { return }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pointInView = self.view.convert(scalingview.center, to: scalingview)
        let indexPathNow =  scalingview.indexPathForItem(at: pointInView)
        let index = (indexPathNow?.row ?? 0) % self.dataArr.count
        self.pageController.currentPage = index
        
    }

}

private typealias ScalingCarouselFlowDelegate = StudentCourseDetailVC
extension ScalingCarouselFlowDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

