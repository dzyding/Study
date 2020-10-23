//
//  CoachHomeLateMotionView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PersonalLastMotionView: UIView {

    @IBOutlet weak var colLateMotion: UICollectionView!
    @IBOutlet weak var colLayout: UICollectionViewFlowLayout!
    
    var dataArr = [[String:Any]]()
    
    override func awakeFromNib() {
        
        
        colLateMotion.register(UINib.init(nibName: "CoachHomeMotionCell", bundle: nil), forCellWithReuseIdentifier: "CoachHomeMotionCell")

        colLateMotion.delegate = self
        colLateMotion.dataSource = self
                
        
        colLayout.itemSize = CGSize.init(width: (ScreenWidth - 32)/3.0, height: 135.0)
        colLayout.scrollDirection = .horizontal
        colLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        colLayout.minimumLineSpacing = 0
        colLayout.minimumInteritemSpacing = 0
        
    }
    
    class func instanceFromNib() -> PersonalLastMotionView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[3] as! PersonalLastMotionView
    }
    
    func setData(_ lastTraining:[[String:Any]])
    {
        self.dataArr = lastTraining
        self.colLateMotion.reloadData()
    }

}

extension PersonalLastMotionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoachHomeMotionCell", for: indexPath) as! CoachHomeMotionCell
        cell.setData(self.dataArr[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
