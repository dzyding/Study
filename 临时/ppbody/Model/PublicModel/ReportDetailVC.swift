//
//  ReportDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController
import IQKeyboardManagerSwift

class ReportDetailVC: BaseVC {
    
    private var width: CGFloat {
        return (ScreenWidth - 40.0 - 30.0) / 4.0
    }
    
    private var imageArr: [Any] = [UIImage(named: "public_image_add")!]
    
    private var reportData: [String : String]
    
    private let type: ReportType
    
    private var photos = [INSPhotoViewable]()
    
    private var uploadLoadingView: UploadLoadingView?
    
    private weak var publicBtn: UIButton!

    @IBOutlet weak var collectionViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var infoLB: UILabel!
    
    @IBOutlet weak var inputTV: IQTextView!
    
    @IBOutlet weak var textNumLB: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    init(_ type: ReportType, data: [String : String]) {
        self.reportData = data
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setPublishBtn()
    }
    
    private func initUI() {
        collectionView.dzy_registerCellFromNib(ImagePublicCell.self)
        collectionViewHeightLC.constant = width
        infoLB.text = reportData.stringValue("title")
        inputTV.delegate = self
        switch type {
        case .user:
            navigationItem.title = "用户举报"
        case .video:
            navigationItem.title = "视频举报"
        }
    }
    
    private func setPublishBtn() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        btn.titleLabel?.font = dzy_FontBlod(15)
        btn.setTitleColor(RGB(r: 227.0, g: 64.0, b: 77.0), for: .normal)
        btn.setTitle("提交", for: .normal)
        btn.addTarget(self, action: #selector(publicAction), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = barBtn
        publicBtn = btn
    }
    
    private func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 4 - imageArr.count
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
            
            for i in 0..<assets.count {
                let dk = assets[assets.count-i-1]
                self.imageArr.insert(dk, at: 0)
                let photo = INSPhoto(dk: dk)
                self.photos.insert(photo, at: 0)
                self.collectionView.reloadData()
            }
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }
    
    //点击发布按钮
    @objc func publicAction() {

        if inputTV.text.count > 0 {
            reportData["content"] = inputTV.text
        }
  
        publicBtn.isEnabled = false
        
        if photos.count > 0
        {
            uploadLoadingView = UploadLoadingView.showUploadLoadingView()
            uploadLoadingView?.max = Double(photos.count)
               var imgArr = [UIImage]()
               for photo in photos {
                   photo.loadImageWithCompletionHandler { (img, error) in
                       imgArr.append(img!)
                       if imgArr.count == self.photos.count {
                           var imgList = [String]()
                           DispatchQueue.global().async {
                               imgList = AliyunUpload.upload.uploadAliOSS(imgArr, type: .Report) { (progress) in
                                   if progress == -1 {
                                       DispatchQueue.main.sync {
                                           //上传失败
                                           ToolClass.showToast("网络异常，上传终止", .Failure)
                                           self.uploadLoadingView?.removeFromSuperview()
                                           self.publicBtn.isEnabled = true
                                       }
                                       return
                                   }
                                   DispatchQueue.main.async {
                                       let progressIndex = self.uploadLoadingView?.setProgress(progress)
                                       if progressIndex == 1 && self.reportData["imgs"] == nil {
                                           self.reportData["imgs"] = ToolClass.toJSONString(dict: imgList)
                                           self.reportApi()
                                       }
                                   }
                               }
                           }
                       }
                   }
               }
        }else{
           self.reportApi()
        }
        
   
    }
    
    //发布话题到服务器
    func reportApi() {
        let request = BaseRequest()
        request.dic = reportData
        request.url = BaseURL.Accusation
        request.isUser = true
        request.start { (data, error) in
            DispatchQueue.main.async {
                self.uploadLoadingView?.removeFromSuperview()
            }
            guard error == nil else
            {
                //执行错误信息
                self.publicBtn.isEnabled = true
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("提交成功", .Success)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}

extension ReportDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(ImagePublicCell.self, indexPath)
        let imageAny = imageArr[indexPath.row]
        if let dk = imageAny as? DKAsset {
            dk.fetchImage(with: CGSize(width: width, height: width).toPixel()) { (image, info) in
                cell?.coverIV.image = image
            }
        }else if let img = imageAny as? UIImage {
            cell?.coverIV.image = img
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageArr.count < 4 && indexPath.row == self.imageArr.count - 1 {
            showImagePickerWithAssetType(
                .allPhotos,
                allowMultipleType: false,
                sourceType: .both,
                allowsLandscape: true,
                singleSelect: false
            )
            return
        }
        
        let currentPhoto = photos[indexPath.row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
        
        let photobrower = PhotoBrowerOverlayView.instanceFromNib()
        photobrower.delegate = self
        photobrower.showEditTool()
        photobrower.currentIndex = indexPath.row
        galleryPreview.overlayView = photobrower
        galleryPreview.modalPresentationStyle = .fullScreen
        present(galleryPreview, animated: true, completion: nil)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

extension ReportDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        if text.count > 200 {
            let index = text.index(text.startIndex, offsetBy: 200)
            text = String(text[..<index])
            inputTV.text = text
        }
        textNumLB.text = "\(text.count)" + "/200"
    }
}

extension ReportDetailVC: PhotoBrowerActionDelegate {
    func deleteAction(_ index: Int) {
        photos.remove(at: index)
        imageArr.remove(at: index)
        collectionView.reloadData()
    }
}


