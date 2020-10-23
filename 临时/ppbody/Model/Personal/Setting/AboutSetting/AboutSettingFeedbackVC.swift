//
//  AboutSettingFeedbackVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/16.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import DKImagePickerController
import IQKeyboardManagerSwift

class AboutSettingFeedbackVC: BaseVC {
    
    @IBOutlet weak var textview: IQTextView!
    @IBOutlet weak var textviewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var collectionviewHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var deleteLB: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    var imageArr = [Any]()
    
    var photos = [INSPhotoViewable]()
    var uploadLoadingView: UploadLoadingView?
    let itemWidth = (ScreenWidth - 64 - 2*8)/3
    var longPressGesture = UILongPressGestureRecognizer()
    
    var callBtn:UIButton!
    
    var indexPath: IndexPath?
    var targetIndexPath: IndexPath?
    
    private lazy var dragingItem: ImagePublicCell = {
        let cell = UINib(nibName: "ImagePublicCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ImagePublicCell
        cell.frame = CGRect(x: 0, y: 0, width: (ScreenWidth - 64 - 2*8)/3, height: (ScreenWidth - 64 - 2*8)/3)
        cell.isHidden = true
        return cell
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "意见反馈"
        addNavigationBar()
        
        collectionview.register(UINib(nibName: "ImagePublicCell", bundle: nil), forCellWithReuseIdentifier: "ImagePublicCell")
        collectionview.addSubview(dragingItem)
        
        longPressGesture =  UILongPressGestureRecognizer(target: self, action: #selector(handlLongPress(gesture:)) )
        longPressGesture.minimumPressDuration = 1
        self.collectionview.addGestureRecognizer(longPressGesture)
        
        let addImage = UIImage(named: "public_image_add")
        imageArr.append(addImage!)
        
        
        
        //删除布局
        if IS_IPHONEX {
            self.deleteViewHeight.constant = 34 + 50
            self.deleteViewBottomMargin.constant = -self.deleteViewHeight.constant
        }
        
         self.reloadCollectionView()
    }
    
    func addNavigationBar()
    {
        callBtn = UIButton(type: .custom)
        callBtn.setImage(UIImage(named: "setting_phone"), for: .normal)
        callBtn.sizeToFit()
        callBtn.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)
        
        let rightBar = UIBarButtonItem(customView: callBtn)
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        ToolClass.callMobile("400-027-0986")
    }
    
    @IBAction func sendFeedbackAction(_ sender: UIButton) {
        
        if self.textview.text.isEmpty
        {
            ToolClass.showToast("大人，还是随便写写吧", .Failure)
            self.textview.becomeFirstResponder()
            return
        }
        self.dataDic["content"] = self.textview.text
        
        self.callBtn.isEnabled = false
        
        
        if self.photos.count == 0
        {
            self.publicFeedBackToServer()
            return
        }
        
        uploadLoadingView = UploadLoadingView.showUploadLoadingView()
        uploadLoadingView?.max = Double(photos.count)
        
        var imgArr = [UIImage]()
        
        for photo in photos
        {
            photo.loadImageWithCompletionHandler { (img, error) in
                imgArr.append(img!)
                if imgArr.count == self.photos.count
                {
                    var imgList = [String]()
                    
                    DispatchQueue.global().async {
                        imgList = AliyunUpload.upload.uploadAliOSS(imgArr, type: .Topic) { (progress) in
                            if progress == -1 {
                                DispatchQueue.main.async {
                                    //上传失败
                                    ToolClass.showToast("网络异常，上传终止", .Failure)
                                    self.uploadLoadingView?.removeFromSuperview()
                                    self.callBtn.isEnabled = true
                                }
                                return
                            }
                            
                            DispatchQueue.main.async {
                                let progressIndex = self.uploadLoadingView?.setProgress(progress)
                                if progressIndex == 1 && self.dataDic["imgs"] == nil {
                                    self.dataDic["imgs"] = ToolClass.toJSONString(dict: imgList)
                                    self.publicFeedBackToServer()
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func handlLongPress(gesture: UILongPressGestureRecognizer) {
        
        let point = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            dragBegan(point: point)
        case UIGestureRecognizer.State.changed:
            drageChanged(point: point)
        case UIGestureRecognizer.State.ended:
            drageEnded(point: point)
        case UIGestureRecognizer.State.cancelled:
            drageEnded(point: point)
        default: break
            
        }
        
    }
    
    //MARK: - 长按开始
    private func dragBegan(point: CGPoint) {
        
        indexPath = collectionview.indexPathForItem(at: point)
        if indexPath == nil || (self.imageArr.count < 10 && indexPath?.row == self.imageArr.count - 1)
        {return}
        
        let item = collectionview.cellForItem(at: indexPath!) as? ImagePublicCell
        item?.isHidden = true
        dragingItem.isHidden = false
        dragingItem.frame = (item?.frame)!
        dragingItem.coverIV.image = item?.coverIV.image
        self.collectionview.bringSubviewToFront(self.dragingItem)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 5, options: .curveEaseIn, animations: {
            self.dragingItem.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.dragingItem.alpha = 0.7
        }, completion: nil)
        
        
        if self.deleteViewBottomMargin.constant < 0
        {
            UIView.animate(withDuration: 0.25) {
                self.deleteViewBottomMargin.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - 长按过程
    private func drageChanged(point: CGPoint) {
        if indexPath == nil || (self.imageArr.count < 10 && indexPath?.row == self.imageArr.count - 1)
        {return}
        
        //删除View的判断
        let parentPoint = self.collectionview.convert(point, to: self.view)
        
        if parentPoint.y + dragingItem.na_height/2 > self.deleteView.na_top {
            self.deleteLB.text = "松开即可删除"
        }else{
            self.deleteLB.text = "拖到此处删除"
        }
        
        dragingItem.center = point
        targetIndexPath = collectionview.indexPathForItem(at: point)
        if targetIndexPath == nil || indexPath == targetIndexPath || (self.imageArr.count < 10 && targetIndexPath?.row == self.imageArr.count - 1) {return}
        
        // 更新数据
        let obj = imageArr[indexPath!.item]
        imageArr.remove(at: indexPath!.row)
        imageArr.insert(obj, at: targetIndexPath!.item)
        //图片预览 更新数据
        let photo = photos[indexPath!.item]
        photos.remove(at: indexPath!.row)
        photos.insert(photo, at: targetIndexPath!.item)
        
        //交换位置
        collectionview.moveItem(at: indexPath!, to: targetIndexPath!)
        indexPath = targetIndexPath
        
        
    }
    
    //MARK: - 长按结束
    private func drageEnded(point: CGPoint) {
        if indexPath == nil || (self.imageArr.count < 10 && indexPath?.row == self.imageArr.count - 1)
        {return}
        
        var delete = false
        
        let parentPoint = self.collectionview.convert(point, to: self.view)
        
        if parentPoint.y + dragingItem.na_height/2 > self.deleteView.na_top {
            delete = true
        }
        
        if self.deleteViewBottomMargin.constant == 0
        {
            UIView.animate(withDuration: 0.25) {
                self.deleteViewBottomMargin.constant = -self.deleteViewHeight.constant
                self.view.layoutIfNeeded()
            }
        }
        
        let endCell = collectionview.cellForItem(at: indexPath!)
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.dragingItem.transform = CGAffineTransform.identity
            if !delete
            {
                self.dragingItem.center = (endCell?.center)!
                
            }
            self.dragingItem.alpha = delete ? 0.0 : 1.0
            
        }, completion: {
            
            (finish) -> () in
            
            endCell?.isHidden = false
            self.dragingItem.isHidden = true
            
            
            if delete
            {
                self.imageArr.remove(at: (self.indexPath?.item)!)
                self.photos.remove(at: (self.indexPath?.item)!)
                self.reloadCollectionView()
            }
            
            self.indexPath = nil
            
        })
    }
    
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.maxSelectableCount = 10 - imageArr.count
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
                self.reloadCollectionView()
            }
            
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }
    
    func reloadCollectionView()
    {
        let width = (ScreenWidth - 64 - 2*8)/3
        
        let collum = Double(self.imageArr.count) / 3.0
        var index = 0
        if collum <= 1 {
            index = 1
        }else if collum <= 2
        {
            index = 2
        }else{
            index = 3
        }
        self.collectionviewHeight.constant = CGFloat(index) * (width + 8) - 8
        
        self.collectionview.reloadData()
    }
    
    
    func publicFeedBackToServer()
    {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String : String]
        request.isUser = true
        request.url = BaseURL.FeedBack
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.sendBtn.isEnabled = true
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.uploadLoadingView?.removeFromSuperview()
            ToolClass.showToast("意见反馈提交成功", .Success)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
            
        }
    }
    
}

private typealias PrivateAPI = AboutSettingFeedbackVC
extension PrivateAPI: PhotoBrowerActionDelegate {
    
    func deleteAction(_ index: Int) {
        self.photos.remove(at: index)
        self.imageArr.remove(at: index)
        self.reloadCollectionView()
    }
}

extension AboutSettingFeedbackVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    
  
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count > 9 ? 9 : imageArr.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let imagePublicCell = cell as! ImagePublicCell
        let imageAny = imageArr[indexPath.row]
        
        if let dk = imageAny as? DKAsset
        {
            dk.fetchImage(with: CGSize(width: itemWidth, height: itemWidth).toPixel()) { (image, info) in
                imagePublicCell.coverIV.image = image
            }
            
        }else if let img = imageAny as? UIImage{
            imagePublicCell.coverIV.image = img
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "ImagePublicCell", for: indexPath) as! ImagePublicCell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.imageArr.count < 10 && indexPath.row == self.imageArr.count - 1 {
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}
