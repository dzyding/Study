//
//  MineTribeEditSelectView.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DKImagePickerController

class MineTribeEditSelectView: UIView {
    
    @IBOutlet weak var txtSign: IQTextView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var cityLB: UILabel!
    
    @IBOutlet weak var cityView: UIView!
    
    var tribeImg: UIImage?
    
    override func awakeFromNib() {
        txtSign.placeholder = "请输入部落签名"
        txtSign.textColor = UIColor.white
        
        cityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cityAction)))
        viewBg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView)))
    }
    
    @objc func tapView() {
        //弹出相册
        showImagePickerWithAssetType(
            .allPhotos,
            allowMultipleType: false,
            sourceType: .photo,
            allowsLandscape: true,
            singleSelect: true
        )
    }
    
    @objc func cityAction()
    {
        let vc = CityVC()
        vc.delegate = self
        ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
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
            assets[0].fetchOriginalImage(completeBlock:{ (image, info) in
                
                let controller = CropViewController()
                controller.delegate = self
                controller.image = image
                controller.cropAspectRatio = 2.0
                controller.keepAspectRatio = true
                controller.toolbarHidden = true
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .fullScreen
                ToolClass.controller2(view: self)?.present(navController, animated: true, completion: nil)
                
            })
        }
        pickerController.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(pickerController, animated: true) {}
    }
    
    class func instanceFromNib() -> MineTribeEditSelectView {
        return UINib(nibName: "TribeEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! MineTribeEditSelectView
    }
    
    func getSelectData() -> [String: Any]? {
        if txtName.text?.count == 0 {
            ToolClass.showToast("请输入部落名称", .Failure)
            return nil
        }
        if txtSign.text.count == 0 {
            ToolClass.showToast("请输入部落签名", .Failure)
            return nil
        }
        
        if (cityLB.text?.isEmpty)!
        {
            ToolClass.showToast("请输入部落所在城市", .Failure)
            return nil
        }
        
        return [
            "name": txtName.text ?? "",
            "slogan": txtSign.text ?? "",
            "city":cityLB.text ?? ""
        ]
    }
    
}

extension MineTribeEditSelectView: CropViewControllerDelegate,CitySelectDelegate {
    
    func selectCity(_ city: String) {
        self.cityLB.text = city
    }
    
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        self.imgBG.image = image
        self.tribeImg = image
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}








