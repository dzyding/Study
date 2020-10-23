//
//  LGymCoachView.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
 
protocol LGymCoachViewDelegate: class {
    func coachView(_ coachView: LGymCoachView,
                   didClickCoach coach: [String : Any])
}

class LGymCoachView: UIView, InitFromNibEnable {
    
    weak var delegate: LGymCoachViewDelegate?
    
    @IBOutlet weak var titleLB: UILabel!
    
    private var ptList: [[String : Any]] = []

    @IBOutlet weak var collectionView: UICollectionView!

    func initUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dzy_registerCellFromNib(LGymCoachCell.self)
    }
    
    func updateUI(_ ptList: [[String : Any]]) {
        self.ptList = ptList
        titleLB.text = "教练(\(ptList.count))"
        collectionView.reloadData()
    }
}

extension LGymCoachView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ptList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(LGymCoachCell.self, indexPath)!
        cell.updateUI(ptList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110.0, height: 200.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.coachView(self, didClickCoach: ptList[indexPath.row])
    }
}
