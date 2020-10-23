//
//  WalletHeaderView.swift
//  PPBody
//
//  Created by edz on 2018/12/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SWalletHeaderView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var emptyHandler: ((Bool)->())?
    
    var dataArr: [[String : Any]] = []
    
    static func initFromNib() -> SWalletHeaderView {
        let v = Bundle.main.loadNibNamed("SWalletHeaderView", owner: self, options: nil)?.first as! SWalletHeaderView
        v.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200)
        return v
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dzy_registerCellFromNib(SWalletHeaderGiftCell.self)
        
        giftStatisticsApi()
    }
    
    func giftStatisticsApi() {
        let request = BaseRequest()
        request.url = BaseURL.giftStatistics
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error ?? "", .Failure)
                self?.emptyHandler?(true)
                return
            }
            if let list = data?["list"] as? [[String : Any]] {
                self?.dataArr = list
                self?.collectionView.reloadData()
                self?.emptyHandler?(list.isEmpty)
            }else {
                self?.emptyHandler?(true)
            }
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension SWalletHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(SWalletHeaderGiftCell.self, indexPath)!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SWalletHeaderGiftCell {
            cell.data = dataArr[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
