//
//  UserPrivateTrainCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class UserPrivateTrainCell: UITableViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblCoachName: UILabel!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var colList: UICollectionView!
    @IBOutlet weak var colLayout: UICollectionViewFlowLayout!
    
    var dataArr = [[String: Any]]()
    
    var dataDic = [String:Any]()

    override func awakeFromNib() {
        super.awakeFromNib()
        imgIcon.layer.cornerRadius = 22.0
        imgIcon.layer.masksToBounds = true
        backgroundColor = BackgroundColor
        colLayout.itemSize = CGSize.init(width: (ScreenWidth-16*3)/2.0, height: (ScreenWidth-16*3)/2.0)
        colLayout.minimumLineSpacing = 16.0
        colLayout.minimumInteritemSpacing = 0
        colLayout.sectionInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        colLayout.scrollDirection = .horizontal
        
        colList.register(UINib.init(nibName: "UserPrivateTrainChildCell", bundle: nil), forCellWithReuseIdentifier: "UserPrivateTrainChildCell")
        // Initialization code
    }
    
    func setData(data: [String: Any]) {
        self.dataDic = data
        imgIcon.setHeadImageUrl(data["head"] as! String)
        lblCoachName.text = data["nickname"] as? String
        dataArr = data["list"] as! [[String: Any]]
        
        if dataArr.count < 8
        {
            self.btnRight.isHidden = true
        }else{
            self.btnRight.isHidden = false
        }
        
        colList.reloadData()
    }

    @IBAction func moreAction(_ sender: UIButton) {
        let vc = PrivateTrainVC()
        vc.other = self.dataDic
        ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserPrivateTrainCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPrivateTrainChildCell", for: indexPath) as! UserPrivateTrainChildCell
        cell.setData(data: dataArr[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dic = dataArr[indexPath.row]
        let vc = CoachPlanDetailVC()
        vc.dataDic = dic
        vc.owner = self.dataDic
        ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
