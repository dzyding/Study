//
//  LocationCityTBHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/11/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationCityTBHeaderView: UIView, InitFromNibEnable {
    
    var handler: (([String : Any]) -> ())?

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var hotList: [[String : Any]] = []
    
    private var currentCity: [String : Any] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView
            .dzy_registerHeaderFromNib(CityTitleSectionHeader.self)
        collectionView.dzy_registerCellFromNib(CityRectCell.self)
    }
    
    func updateUI(_ hotList: [[String : Any]],
                  current: [String : Any]) -> CGFloat {
        self.hotList = hotList
        self.currentCity = current
        collectionView.reloadData()
        
        let count = hotList.count
        let row = count % 3 == 0 ? count / 3 : (count / 3 + 1)
        var height: CGFloat = 40 + 45 + 40 + 45 * CGFloat(row) + 20
        if row > 1 {
            height += CGFloat(row - 1) * 10.0
        }
        return height
    }
}

extension LocationCityTBHeaderView:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return hotList.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView
                .dzy_dequeueCell(CityRectCell.self, indexPath)
            cell?.updateUI(currentCity)
            return cell!
        default:
            let cell = collectionView
                .dzy_dequeueCell(CityRectCell.self, indexPath)
            cell?.updateUI(hotList[indexPath.row])
            return cell!
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView
            .dzy_dequeueHeader(CityTitleSectionHeader.self, indexPath)
        header?.updateUI(indexPath.section == 0 ? "当前城市" : "热门城市")
        return header!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 46.0 - 28.0) / 3.0
        return CGSize(width: width, height: 45.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: ScreenWidth, height: 40.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 1:
            return UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 30)
        default:
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 30)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = indexPath.section == 0 ?
            currentCity : hotList[indexPath.row]
        handler?(data)
    }
}
