//
//  CoachHomeCourseView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachHomeCourseView: UIView {

    @IBOutlet weak var colCourse: UICollectionView!
    @IBOutlet weak var colLayout: UICollectionViewFlowLayout!
    
    var dataArr = [[String:Any]]()
    var coach:[String:Any]?
    var isMember = false
    
    override func awakeFromNib() {
        
        colCourse.register(UINib.init(nibName: "CoachHomeCourseCell", bundle: nil), forCellWithReuseIdentifier: "CoachHomeCourseCell")
        colCourse.showsHorizontalScrollIndicator = false
        colCourse.showsVerticalScrollIndicator = false
        colCourse.backgroundColor = BackgroundColor
        colCourse.delegate = self
        colCourse.dataSource = self
        
        colLayout.itemSize = CGSize.init(width: 81, height: 81)
        colLayout.scrollDirection = .horizontal
        colLayout.sectionInset = UIEdgeInsets(top: 0 , left: 16.0, bottom: 0, right: 16.0)
        colLayout.minimumLineSpacing = 16.0
        colLayout.minimumInteritemSpacing = 0
    }
    
    class func instanceFromNib() -> CoachHomeCourseView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! CoachHomeCourseView
    }
    
    func setData(_ plans: [[String:Any]], own:[String:Any], isMember:Bool)
    {
        self.dataArr = plans
        self.coach = own
        self.isMember = isMember
        self.colCourse.reloadData()
    }

}

extension CoachHomeCourseView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoachHomeCourseCell", for: indexPath) as! CoachHomeCourseCell
        cell.setData(self.dataArr[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isMember
        {
            let dic = dataArr[indexPath.row]
            let vc = CoachPlanDetailVC()
            vc.dataDic = dic
            vc.owner = self.coach
            ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
}












