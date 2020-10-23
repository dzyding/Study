//
//  LocationShopPhotoVC.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationShopPhotoVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商家图片"
        collectionView
            .dzy_registerCellFromNib(LocationShopPhotoCell.self)
    }

}

extension LocationShopPhotoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(LocationShopPhotoCell.self, indexPath)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widht = (ScreenWidth - 32.0 - 11.0) / 2.0
        return CGSize(width: widht, height: widht)
    }
}
