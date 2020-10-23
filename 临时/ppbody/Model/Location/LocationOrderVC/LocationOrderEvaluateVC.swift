//
//  LocationOrderEvaluateVC.swift
//  PPBody
//
//  Created by edz on 2019/11/4.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import DKImagePickerController

class LocationOrderEvaluateVC: BaseVC {
    
    private let orderId: Int

    @IBOutlet weak var clHeightLC: NSLayoutConstraint!

    @IBOutlet weak var placeHolderLB: UILabel!
    
    @IBOutlet weak var inputTX: UITextView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lvMsgLV: UILabel!
    ///上传图片≥3张可领取20滴汗水
    @IBOutlet weak var msgLB: UILabel!
    
    private var imageArr = [Any]()
    
    private var photos = [INSPhotoViewable]()
    
    private var uploadLoadingView: UploadLoadingView?
    
    private var width: CGFloat = (ScreenWidth - 2 * 39 - 20.0) / 3.0
    
    init(_ orderId: Int) {
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        navigationItem.title = "评价"
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
        clHeightLC.constant = width
        collectionView.dzy_registerCellFromNib(ImagePublicCell.self)
        UIImage(named: "evluate_add").flatMap({
            imageArr.append($0)
        })
    }

    private func initUI() {
        let str = "上传图片≥3张可领取20滴汗水"
        if let range = str.range(of: "20滴") {
            let attStr = NSMutableAttributedString(
                string: str, attributes: [
                    NSAttributedString.Key.font : dzy_FontBlod(10),
                    NSAttributedString.Key.foregroundColor : UIColor.white
            ])
            attStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                value: YellowMainColor,
                                range: dzy_toNSRange(range, str: str))
            msgLB.attributedText = attStr
        }
    }
    
    @IBAction func releaseAction(_ sender: DzySafeBtn) {
        guard let user = DataManager.userInfo() else {return}
        guard let content = inputTX.text, content.count > 0 else {
            ToolClass.showToast("请输入评论内容", .Failure)
            inputTX.becomeFirstResponder()
            return
        }
        let rank = stackView.arrangedSubviews
            .filter({($0 as? UIButton)?.isSelected == true})
            .count
        guard rank > 0 else {
            ToolClass.showToast("请进行评级", .Failure)
            return
        }
        sender.isEnabled = false
        var dic: [String : String] = [
            "nickname" : user.stringValue("nickname") ?? "",
            "head" : user.stringValue("head") ?? "",
            "score" : "\(rank)",
            "content" : content,
            "lbsOrderId" : "\(orderId)"
        ]
        guard photos.count > 0 else {
            commentApi(dic)
            return
        }
        uploadLoadingView = UploadLoadingView.showUploadLoadingView()
        uploadLoadingView?.max = Double(photos.count)
        var imgArr = [UIImage]()
        for photo in photos {
            photo.loadImageWithCompletionHandler { (img, error) in
                guard let img = img else {return}
                imgArr.append(img)
                guard imgArr.count == self.photos.count else {return}
                var imgList = [String]()
                DispatchQueue.global().async {
                    imgList = AliyunUpload
                        .upload
                        .uploadAliOSS(imgArr, type: .Evaluate) { (progress) in
                        if progress == -1 {
                            DispatchQueue.main.sync {
                                //上传失败
                                ToolClass.showToast("网络异常，上传终止", .Failure)
                                self.uploadLoadingView?.removeFromSuperview()
                                sender.isEnabled = true
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            let progressIndex = self.uploadLoadingView?.setProgress(progress)
                            if progressIndex == 1  {
                                dic["imgs"] = ToolClass
                                    .toJSONString(dict: imgList)
                                self.commentApi(dic)
                            }
                        }
                    }
                }
            }
        }
    }
    
//    MARK: - 选中评分
    @IBAction func selectSweatAction(_ sender: UIButton) {
        (0..<stackView.arrangedSubviews.count).forEach { (index) in
            if let btn = stackView.arrangedSubviews[index] as? UIButton {
                btn.isSelected = index <= sender.tag
            }
        }
        lvMsgLV.isHidden = false
        switch sender.tag {
        case 0:
            lvMsgLV.text = "很差"
        case 1:
            lvMsgLV.text = "一般"
        case 2:
            lvMsgLV.text = "满意"
        case 3:
            lvMsgLV.text = "非常满意"
        default:
            lvMsgLV.text = "无可挑剔"
        }
    }
    
//    MARK: - dk
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 9 - imageArr.count
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
            for i in 0..<assets.count {
                let dk = assets[assets.count - i - 1]
                self.imageArr.insert(dk, at: 0)
                let photo = INSPhoto(dk: dk)
                self.photos.insert(photo, at: 0)
                self.reloadCollectionView()
            }
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }
    
    func reloadCollectionView() {
        let count = min(imageArr.count, 8)
        let row = count % 3 == 0 ? count / 3 : (count / 3 + 1)
        var height: CGFloat = CGFloat(row) * width
        if row > 1 {
            height += 10.0 * CGFloat(row - 1)
        }
        clHeightLC.constant = height
        collectionView.reloadData()
    }
    
//    MARK: - Api
    private func commentApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClubComment
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            self.uploadLoadingView?.removeFromSuperview()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                ToolClass.showToast("评价成功", .Success)
                NotificationCenter.default.post(
                    name: Config.Notify_RefreshLocationOrder,
                    object: nil)
                self.dzy_delayPop(1)
            }
        }
    }
}

extension LocationOrderEvaluateVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count > 8 ? 8 : imageArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(ImagePublicCell.self, indexPath)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let imagePublicCell = cell as! ImagePublicCell
        let imageAny = imageArr[indexPath.row]
        if let dk = imageAny as? DKAsset {
            let size = CGSize(width: width, height: width).toPixel()
            dk.fetchImage(with: size) { (image, info) in
                imagePublicCell.coverIV.image = image
            }
        }else if let img = imageAny as? UIImage{
            imagePublicCell.coverIV.image = img
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageArr.count < 9 &&
            indexPath.row == imageArr.count - 1
        {
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
}

extension LocationOrderEvaluateVC: PhotoBrowerActionDelegate {
    func deleteAction(_ index: Int) {
        photos.remove(at: index)
        imageArr.remove(at: index)
        reloadCollectionView()
    }
}

extension LocationOrderEvaluateVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLB.isHidden = textView.text.count > 0
    }
}
