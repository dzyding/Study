//
//  SetIdentityCardView.swift
//  PPBody
//
//  Created by Mike on 2018/6/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController

class SetIdentityCardView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgFront: UIImageView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var viewFront: UIView!
    @IBOutlet weak var viewContent: UIView!
    
    var type = "1"
    
    var positiveImage: UIImage?
    var nagativeImage: UIImage?

    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.lblDesc.text = "1.身份证照片不得有遮挡，保持字迹清晰\n2.在白色背景下拍摄，保持身份证边缘清晰\n3.请从证件上方拍摄，防止画面变形"
        self.lblDesc.lineBreakMode = .byCharWrapping
        self.lblDesc.attributedText = ToolClass.rowSpaceText(self.lblDesc.text!, system: 13)
        self.lblDesc.sizeToFit()

    }
    
    //提交获取图片
    func getIDCardPic() -> [UIImage]? {
        if positiveImage == nil {
            ToolClass.showToast("请上传身份证正面", .Failure)
            return nil
        }
        if nagativeImage == nil {
            ToolClass.showToast("请上传身份证背面", .Failure)
            return nil
        }
        return [positiveImage!, nagativeImage!]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapFront = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.viewFront.addGestureRecognizer(tapFront)
        
        let tapBack = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.viewBack.addGestureRecognizer(tapBack)

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
            if self.type == "1" {
                if assets.count == 0
                {
                    return
                }
                for asset in assets {
                    
                    asset.fetchOriginalImage(completeBlock: { (image, info) in
                        self.imgFront.image = image
                        self.positiveImage = image
                    })
                }
            }
            else if self.type == "2" {
                if assets.count == 0
                {
                    return
                }
                for asset in assets {
    
                    asset.fetchOriginalImage(completeBlock: { (image, info) in
                        self.imgBack.image = image
                        self.nagativeImage = image
                    })
                }
            }
            
        }
        pickerController.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(pickerController, animated: true) {}
    }
    
    @objc func tapView(tap:UITapGestureRecognizer) {
        if tap.view == viewFront {
            //弹出相册
            type = "1"
            showImagePickerWithAssetType(
                .allPhotos,
                allowMultipleType: false,
                sourceType: .photo,
                allowsLandscape: true,
                singleSelect: true
            )
        }
        else if tap.view == viewBack {
            type = "2"
            showImagePickerWithAssetType(
                .allPhotos,
                allowMultipleType: false,
                sourceType: .photo,
                allowsLandscape: true,
                singleSelect: true
            )
            
        }
    }
    
    class func instanceFromNib() -> SetIdentityCardView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[3] as! SetIdentityCardView
    }
}












