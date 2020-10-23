//
//  SetKeepFitCertifyView.swift
//  PPBody
//
//  Created by Mike on 2018/6/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController

class SetKeepFitCertifyView: UIView {
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var colPhoto: UICollectionView!
    @IBOutlet weak var colLayout: UICollectionViewFlowLayout!
    
    var image: UIImage?
    let itemWidth = (ScreenWidth - 64 - 2*8)/3
    
    
    //提交获取图片
    func getkeepFitCertifyPic() -> UIImage? {
        if image == nil {
            ToolClass.showToast("请上传执业证书正面", .Failure)
            return nil
        }
        return image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.colPhoto.delegate = self
        self.colPhoto.dataSource = self
        self.colLayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        self.colLayout.minimumLineSpacing = 8.0
        self.colLayout.minimumInteritemSpacing = 8.0
        self.colLayout.sectionInset = UIEdgeInsets.zero
        self.colPhoto.backgroundColor = UIColor.ColorHex("#333237")
        self.colPhoto.register(UINib.init(nibName: "SetPhotoCell", bundle: nil), forCellWithReuseIdentifier:"SetPhotoCell")
    }
    
    class func instanceFromNib() -> SetKeepFitCertifyView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! SetKeepFitCertifyView
    }
    
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.maxSelectableCount = 1
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            if assets.count == 0 {
                return
            }
            
            for asset in assets {
                asset.fetchOriginalImage(completeBlock: { (image, info) in
                    DispatchQueue.main.async {
                        self.image = image
                        self.colPhoto.reloadData()
                    }
                })
            }
        }
        pickerController.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(pickerController, animated: true) {}
    }
}


extension SetKeepFitCertifyView:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetPhotoCell", for: indexPath) as! SetPhotoCell
        cell.imgContent.image = image ?? UIImage(named: "land_photo_add")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImagePickerWithAssetType(
            .allPhotos,
            allowMultipleType: false,
            sourceType: .photo,
            allowsLandscape: true,
            singleSelect: true
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
}

