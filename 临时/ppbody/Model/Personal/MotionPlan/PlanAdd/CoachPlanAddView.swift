//
//  CoachPlanAddView.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController

class CoachPlanAddView: UIView {
    
    
    @IBOutlet weak var coverIV: UIImageView!
    var coverImage:UIImage?
    var coverUrl:String?
    
    
    class func instanceFromNib() -> CoachPlanAddView {
        return UINib(nibName: "CoachPlanAddView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CoachPlanAddView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverTapAction)))
    }
    
    func setData(_ dic:[String:Any])
    {
        coverUrl = dic["cover"] as? String
        self.coverIV.setCoverImageUrl(coverUrl!)
    }
    
    
    func getInfo()->[String:Any]?
    {
        var dic = [String: Any]()
        
        if self.coverImage == nil
        {
            if self.coverUrl == nil
            {
                ToolClass.showToast("请上传计划封面", .Failure)
                return nil
            }
            dic["cover"] = coverUrl
        }else{
            dic["cover"] = coverImage!
        }
        return dic
    }
    
    @objc func coverTapAction()
    {
        showImagePickerWithAssetType(
            .allPhotos,
            allowMultipleType: false,
            sourceType: .both,
            allowsLandscape: true,
            singleSelect: true
        )
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
            
            if assets.count == 0
            {
                return
            }
            assets[0].fetchOriginalImage(completeBlock: { (image, info) in
                let controller = CropViewController()
                controller.delegate = self
                controller.image = image
                controller.cropAspectRatio = 1.0
                controller.keepAspectRatio = true
                controller.toolbarHidden = true
                let parent = ToolClass.controller2(view: self)
                
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .fullScreen
                parent?.present(navController, animated: true, completion: nil)
            })
        }
        pickerController.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(pickerController, animated: true) {}
    }
    
    
}

extension CoachPlanAddView:  CropViewControllerDelegate {
    
    //MARK: -------CropViewControllerDelegate
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        self.coverIV.image = image
        coverImage = image
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}
