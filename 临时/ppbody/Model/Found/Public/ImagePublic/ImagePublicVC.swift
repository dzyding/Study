//
//  ImagePublicVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import DKImagePickerController
import IQKeyboardManagerSwift

class ImagePublicVC: BaseVC
{
    @IBOutlet weak var textview: IQTextView!
    @IBOutlet weak var textviewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var deleteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var deleteLB: UILabel!
    
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLB: UILabel!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var cityLB: UILabel!
    
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var showLB: UILabel!
    
    @IBOutlet weak var redirectView: UIView!
    @IBOutlet weak var redirectStackview: UIStackView!
    
    
    var publicBtn:UIButton!
    
    
    @IBOutlet weak var collectionviewHeight: NSLayoutConstraint!
    var imageArr = [Any]()
    
    let itemWidth = (ScreenWidth - 64 - 2*8)/3
    
    var longPressGesture = UILongPressGestureRecognizer()
    
    var photos = [INSPhotoViewable]()
    
    var dataTopic = ["display":"30"] //上传信息 初始值是公开的
    
    var uploadLoadingView: UploadLoadingView?
    
    var remindUserList = [StudentUserModel]()
    
    private lazy var dragingItem: ImagePublicCell = {
        let cell = UINib(nibName: "ImagePublicCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ImagePublicCell
        cell.frame = CGRect(x: 0, y: 0, width: (ScreenWidth - 64 - 2*8)/3, height: (ScreenWidth - 64 - 2*8)/3)
        cell.isHidden = true
        return cell
    }()
    
    var indexPath: IndexPath?
    var targetIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发布图文"
        addNavigationBar()
        
        collectionview.register(UINib(nibName: "ImagePublicCell", bundle: nil), forCellWithReuseIdentifier: "ImagePublicCell")
        collectionview.addSubview(dragingItem)
        
        longPressGesture =  UILongPressGestureRecognizer(target: self, action: #selector(handlLongPress(gesture:)) )
        longPressGesture.minimumPressDuration = 1
        self.collectionview.addGestureRecognizer(longPressGesture)

        let addImage = UIImage(named: "public_image_add")
        imageArr.append(addImage!)
        
        
        topicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topicAction)))
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationAction)))
        showView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAction)))
        redirectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(remindAction)))
        
        //删除布局
        if IS_IPHONEX {
            self.deleteViewHeight.constant = 34 + 50
            self.deleteViewBottomMargin.constant = -self.deleteViewHeight.constant
        }
        
        
        if TopicTag != nil
        {
            self.tagView.isHidden = false
            self.tagLB.text = "#" + TopicTag!
            dataTopic["tag"] = TopicTag!
        }
        
        self.reloadCollectionView()

    }
    
    func addNavigationBar()
    {
        publicBtn = UIButton(type: .custom)
        publicBtn.setTitle("发表", for: .normal)
        publicBtn.backgroundColor = YellowMainColor
        publicBtn.setTitleColor(BackgroundColor, for: .normal)
        publicBtn.frame = CGRect(x: 0, y: 0, width: 56, height: 24)
        publicBtn.layer.cornerRadius = 4
        publicBtn.titleLabel?.font = ToolClass.CustomFont(13)
        publicBtn.addTarget(self, action: #selector(publicAction), for: .touchUpInside)
        publicBtn.enableInterval = true
        
        let rightBar = UIBarButtonItem(customView: publicBtn)
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    @objc func topicAction()
    {
        let vc = TopicTagVC(.select)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func locationAction()
    {
        let vc = SearchAddressVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showAction()
    {
        let vc = TopicAuthVC()
        if dataTopic["display"] != nil {
            vc.display = dataTopic["display"]
        }
        if dataTopic["tribeIds"] != nil
        {
            vc.tribeIds = ToolClass.getArrayFromJSONString(jsonString: dataTopic["tribeIds"]!) as? [String]
        }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func remindAction()
    {
        let vc = TopicAttentionVC()
        vc.originUserList = remindUserList
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //增加用户提醒
    func setRemindView()
    {
        for view in self.redirectStackview.arrangedSubviews
        {
            self.redirectStackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for user in self.remindUserList
        {
            let iv = UIImageView()
            iv.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            iv.layer.masksToBounds = true
            iv.layer.cornerRadius = 15
            iv.setHeadImageUrl(user.head!)
            iv.snp.makeConstraints { (make) in
                make.width.height.equalTo(30)
            }
            self.redirectStackview.addArrangedSubview(iv)
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
    
    //点击发布按钮
    @objc func publicAction()
    {
        if self.textview.text.isEmpty
        {
            ToolClass.showToast("大人，还是随便写写吧", .Failure)
            self.textview.becomeFirstResponder()
            return
        }
        if self.photos.count == 0 {
            ToolClass.showToast("大人，晒图啦", .Failure)
            return
        }
        uploadLoadingView = UploadLoadingView.showUploadLoadingView()
        self.publicBtn.isEnabled = false
        uploadLoadingView?.max = Double(photos.count)
        
        var imgArr = [UIImage]()
        
        for photo in photos {
            photo.loadImageWithCompletionHandler { (img, error) in
                guard let img = img else {return}
                imgArr.append(img)
                if imgArr.count == self.photos.count {
                    if self.remindUserList.count != 0 {
                        self.dataTopic["remind"] = self.getJsonRemind()
                    }
                    var imgList = [String]()
                    DispatchQueue.global().async {
                        imgList = AliyunUpload.upload.uploadAliOSS(imgArr, type: .Topic) { (progress) in
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
                                if progressIndex == 1 && self.dataTopic["imgs"] == nil {
                                    print("PPBody Server")
                                    self.dataTopic["content"] = self.textview.text
                                    self.dataTopic["imgs"] = ToolClass.toJSONString(dict: imgList)
                                    
                                    self.publicTopicToServer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //获取提醒人的json字符串
    func getJsonRemind() -> String
    {
        var remindArr = [[String:Any]]()
        for model in self.remindUserList
        {
            var dic = [String:Any]()
            dic["uid"] = model.uid!
            dic["nickname"] = model.name!
            dic["head"] = model.head
            remindArr.append(dic)
        }
        
        return ToolClass.toJSONString(dict:remindArr)
    }
    
    //发布话题到服务器
    func publicTopicToServer()
    {
        let request = BaseRequest()
        request.dic = dataTopic
        request.isUser = true
        request.url = BaseURL.PublicTopic
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.publicBtn.isEnabled = true
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.uploadLoadingView?.removeFromSuperview()
            ToolClass.showToast("发布成功", .Success)
            NotificationCenter.default.post(name: Config.Notify_PublicTopic, object: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
      
        }
    }
}

private typealias PrivateAPI = ImagePublicVC
extension PrivateAPI: SelectTopicTagDelegate,SelectAddressDelegate,SelectTopicAuthDelegate, PhotoBrowerActionDelegate,TopicAttentionSelectDelegate {
    
    func selectAuth(_ auth: [String : String]) {
        let display = auth["display"]
        self.showLB.text = display == "30" ? "公开" : "仅部落可见"
        
        dataTopic["display"] = display
        if display == "20"
        {
            dataTopic["tribeIds"] = auth["tribeIds"]
        }else{
            dataTopic.removeValue(forKey: "tribeIds")
        }
    }

    func selectTag(_ name: String) {
        if name == ""
        {
            self.tagView.isHidden = true
            dataTopic.removeValue(forKey: "tag")
        }else{
            self.tagView.isHidden = false
            self.tagLB.text = "#" + name
            
            dataTopic["tag"] = name
            
        }
    }
    
    func selectAddress(_ address: [String : String]) {
        if address.isEmpty
        {
            self.cityLB.text = ""
            
            dataTopic.removeValue(forKey: "address")
            dataTopic.removeValue(forKey: "latitude")
            dataTopic.removeValue(forKey: "longitude")
        }else{
             self.cityLB.text = address["name"]
            dataTopic["address"] = address["name"]
            dataTopic["latitude"] = address["latitude"]
            dataTopic["longitude"] = address["longitude"]
        }
       
    }
    
    func selectRemindUser(_ userList: [StudentUserModel]) {
        self.remindUserList = userList
        self.setRemindView()
    }
    
    
    func deleteAction(_ index: Int) {
        self.photos.remove(at: index)
        self.imageArr.remove(at: index)
        self.reloadCollectionView()
    }
}

extension ImagePublicVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
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
