//
//  MyMotionAddVideo.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController
import ZKProgressHUD

class MyMotionAddVideo: UIView {
    
    @IBOutlet weak var videoIV: UIImageView!
    @IBOutlet weak var coverIV: UIImageView!
    
    var videoPath:String?
    var coverImage:UIImage?
    
    var videoId:String?
    var coverUrl:String?
    
    class func instanceFromNib() -> MyMotionAddVideo {
        return UINib(nibName: "MyMotionAddView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! MyMotionAddVideo
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTapAction)))
        coverIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverTapAction)))
    }
    
    func setData(_ dic:[String:Any])
    {
        videoId = dic["video"] as? String
        self.videoIV.setCoverImageUrl(BaseURL.VideoCover + "?video=" + videoId!)
        
        coverUrl = dic["cover"] as? String
        self.coverIV.setCoverImageUrl(coverUrl!)
    }
    
    func getInfo()->[String:Any]?
    {
        var dic = [String: Any]()
        
        if videoId == nil && coverUrl == nil
        {
            //新增
            if videoPath == nil
            {
                ToolClass.showToast("请上传视频", .Failure)
                return nil
            }
            dic["videoPath"] = videoPath
            dic["videoImg"] = videoIV.image
            
            if self.coverImage != nil
            {
                dic["cover"] = self.coverImage
            }
            
            return dic
        }else{
            
            if videoPath == nil
            {
                dic["videoId"] = videoId
            }else{
                dic["videoPath"] = videoPath
                dic["videoImg"] = videoIV.image
            }
            
            if self.coverImage != nil
            {
                dic["cover"] = self.coverImage
            }else{
                dic["coverUrl"] = coverUrl
            }
        }
        return dic
    }
    

    @objc func videoTapAction()
    {
        showImagePickerWithAssetType(
            .allVideos,
            allowMultipleType: false,
            sourceType: .photo,
            allowsLandscape: true,
            singleSelect: true
        )
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
        pickerController.exportsWhenCompleted = true
        pickerController.exportStatusChanged = { status in
            switch status {
            case .exporting:
                print("exporting")
                ZKProgressHUD.show()
            case .none:
                print("none")
                ZKProgressHUD.dismiss()
            }
        }
        pickerController.didSelectAssets = { [weak self] (assets: [DKAsset]) in
            
            if assets.count == 0
            {
                return
            }
            
            let asset = assets[0]
            
            if asset.type == .video
            {
                
                if pickerController.exportsWhenCompleted
                {
                    let cutInfo = CropVideoInfo()
                    cutInfo.startTime = 0
                    cutInfo.endTime = 0
                    cutInfo.duration = 0
                    cutInfo.path = asset.localTemporaryPath!.path
                    cutInfo.outputSize = AliyunOutputVideoSize
                    DispatchQueue.main.async {
                        
                        let vc = CropVideoVC()
                        vc.cutInfo = cutInfo
                        vc.hbd_barHidden = true
                        vc.delegate = self
                        vc.onlyCrop = true
                        let parent = ToolClass.controller2(view: self!)
                        parent?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
              
            }else{
                asset.fetchOriginalImage(completeBlock: { (image, info) in
                    let controller = CropViewController()
                    controller.delegate = self
                    controller.image = image
                    controller.cropAspectRatio = 1.0
                    controller.keepAspectRatio = true
                    controller.toolbarHidden = true
                    let parent = ToolClass.controller2(view: self!)
                    
                    let navController = UINavigationController(rootViewController: controller)
                    navController.modalPresentationStyle = .fullScreen
                    parent?.present(navController, animated: true, completion: nil)
                })
            }

        }
        
        let vc = ToolClass.controller2(view: self)
        pickerController.modalPresentationStyle = .fullScreen
        vc?.present(pickerController, animated: true) {}
    }
}

extension MyMotionAddVideo:CropViewControllerDelegate,CropVideoCompleteDelegate
{
    //MARK: -------CropVideoCompleteDelegate
    func cropComplete(_ path: String) {
        self.videoIV.image = ToolClass.getCoverFromVideo(path)
        videoPath = path
    }
    
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
