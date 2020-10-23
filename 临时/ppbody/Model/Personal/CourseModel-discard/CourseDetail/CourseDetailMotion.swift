//
//  CourseDetailMotion.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import DKImagePickerController
import HBDNavigationBar

protocol CourseDetailMotionDelegate: NSObjectProtocol {
    func deleteCourseDetailMotion(_ cell: CourseDetailMotion)
    func playVideo(_ frame: CGRect, path: String? , video: String?)
}

class CourseDetailMotion: UIView {
    @IBOutlet weak var motionIV: UIImageView!
    @IBOutlet weak var motionNameLB: UILabel!
    @IBOutlet weak var deleteMotionBtn: UIButton!
    @IBOutlet weak var targetLB: UILabel!
    @IBOutlet weak var actualLB: UILabel!
    @IBOutlet weak var marginLeftActualBtn: NSLayoutConstraint!
    @IBOutlet weak var actualBtn: UIButton!
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var mediaView: UIView!
    
    weak var delegate:CourseDetailMotionDelegate?
    
    var coverPath:String?
    var videoPath:String?
    
    let margin:CGFloat = 4
    
    var photos = [INSPhotoViewable]()
    
    lazy var playView: UIView = {
        let view = UIView()
        return view
    }()
    
    var player: AVPlayer?
    var timer: CMTime?
    
    var actualDic = [String:Any]()
    
    lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "course_camear"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 66, height: 66)
        btn.addTarget(self, action: #selector(addMediaAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    var mediaArr = [Any]()
    
    var dataDic = [String:Any]()
    
    var motionCode: String = ""
    
    var courseDic:[String:Any]?
    
    class func instanceFromNib() -> CourseDetailMotion {
        return UINib(nibName: "CourseDetailMotion", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CourseDetailMotion
    }
    
    override func awakeFromNib() {
        
    }
    
    func setData(_ dic:[String:Any], edit:Bool)
    {
        self.dataDic = dic
        
        let motion = dic["motion"] as! [String:Any]
        
        self.motionCode = motion["code"] as! String
        
        self.motionNameLB.text = motion["name"] as? String
        self.motionIV.setCoverImageUrl(motion["cover"] as! String)
        
        let target = dic["target"] as! [String:Any]
        
        let time = target["time"] as? Int
        
        if time == nil
        {
            let groupNum = target["groupNum"] as! Int
            let freNum = target["freNum"] as! Int
            let weight = (target["weight"] as! NSNumber).floatValue.removeDecimalPoint
            self.targetLB.text = "\(groupNum)组  " + "\(freNum)个/组  " + weight + "kg"
        }else{
            self.targetLB.text =  "\(time!)分钟"
        }
        
        if edit {

            if DataManager.isCoach()
            {
                //教练可以编辑
                self.addBtn.na_top = self.mediaView.na_height - 66
                self.mediaView.addSubview(self.addBtn)
            }else{
                self.deleteMotionBtn.isHidden = true
                self.titleLB.text = "训练照片/视频"
                self.actualBtn.isHidden = true
                self.actualLB.text = "教练暂无记录"
            }
            
        }else{
            
            self.deleteMotionBtn.isHidden = true
            self.titleLB.text = "训练照片/视频"
            self.actualBtn.isHidden = true
            
            let actual = dic["actual"] as! [String:Any]
            let time = actual["time"] as? Int
            
            if time == nil
            {
                let groupNum = actual["groupNum"] as! Int
                let freNum = actual["freNum"] as! Int
                let weight = (actual["weight"] as! NSNumber).floatValue.removeDecimalPoint
                self.actualLB.text = "\(groupNum)组  " + "\(freNum)个/组  " + weight + "kg"
            }else{
                self.actualLB.text =  ToolClass.secondToText(time!)
            }
            
            
            let imgs = dic["imgs"] as! [String]
            
            var index = 0
            
            for img in imgs
            {
                if img.contains("oss.ppbody.com")
                {
                    let photo = INSPhoto(imageURL: URL(string: img), thumbnailImage: nil)
                    self.photos.append(photo)
                    //图片
                    let media = CourseDetailMediaView.instanceFromNib()
                    media.coverIV.setCoverImageUrl(img)
                    media.tag = index
                    media.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageAction(_:))))
                    self.mediaView.addSubview(media)
                    
                    index += 1
                }else{
                    //视频
                    let media = CourseDetailMediaView.instanceFromNib()
                    media.playIV.isHidden = false
                    media.coverIV.setCoverImageUrl(img)
                    media.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapVideoAction(_:))))
                    self.mediaView.addSubview(media)
                    
                    self.videoPath = dic["video"] as? String
                }
            }
            refreshMediaView()
        }
    }
    
    //刷新页面的目标值
    func refreshTarget(_ dic:[String:Any])
    {
        self.dataDic = dic
        
        let target = dic["target"] as! [String:Any]
        
        let time = target["time"] as? Int
        
        if time == nil
        {
            let groupNum = target["groupNum"] as! Int
            let freNum = target["freNum"] as! Int
            let weight = (target["weight"] as! NSNumber).floatValue.removeDecimalPoint
            self.targetLB.text = "\(groupNum)组  " + "\(freNum)个/组  " + weight + "kg"
        }else{
            self.targetLB.text =  ToolClass.secondToText(time!)
        }
    }
    
    @IBAction func addMediaAction(_ sender: UIButton) {
        
        var isVideo = false
        for media in self.mediaArr
        {
            if media is String
            {
                isVideo = true
                break
            }
        }
        
        if isVideo
        {
            return
        }
        //说明是图片
        if self.mediaArr.count > 0
        {
            self.showImagePickerWithAssetType(
                .allPhotos,
                allowMultipleType: false,
                sourceType: .both,
                allowsLandscape: true,
                singleSelect: false
            )
            return
        }
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        let videoAction = UIAlertAction(
            title: "拍摄/上传[视频]",
            style: .default){ (action) in
                let vc = CourseVideoRecordVC()
                vc.delegate = self
                vc.hbd_barHidden = true
                let nav = HBDNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                ToolClass.controller2(view: self)?.present(nav, animated: true, completion: nil)
                
        }
        alertController.addAction(videoAction)
        
        let picAction = UIAlertAction(
            title: "拍摄/上传[照片]",
            style: .default){ (action) in
                self.showImagePickerWithAssetType(
                    .allPhotos,
                    allowMultipleType: false,
                    sourceType: .both,
                    allowsLandscape: true,
                    singleSelect: false
                )
        }
        
        alertController.addAction(picAction)
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = CGRect(x: 80, y:(sender.na_height)/2, width: 0.0, height: 0.0)
        ToolClass.controller2(view: self)?.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    @IBAction func deleteMotionAction(_ sender: UIButton) {
        
        self.delegate?.deleteCourseDetailMotion(self)
    }
    
    @IBAction func addActualAction(_ sender: UIButton) {
        
        if sender.isSelected
        {
            self.actualLB.text = ""
            self.actualDic.removeAll()
            sender.isSelected = false
            return
        }
        
        let motion = self.dataDic["motion"] as! [String:Any]
        let target = self.dataDic["target"] as! [String:Any]
        
        
        
        let motionCode = motion["code"] as! String
        let planCode = ToolClass.planCodeFromMotion(motionCode)
        if ToolClass.isCardio(motionCode)
        {
            //有氧训练
            let vc = MotionTrainingCardioVC()
            vc.dataDic = motion
            vc.target = target
            vc.coach = self.courseDic?["coach"] as? [String:Any]
            vc.planCode = planCode
            vc.delegate = self
            ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let vc = MotionTrainingVC()
        vc.dataDic = motion
        vc.target = target
        vc.coach = self.courseDic?["coach"] as? [String:Any]
        vc.planCode = planCode
        vc.delegate = self
        ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.maxSelectableCount = 3 - mediaArr.count
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
                
                self.mediaArr.append(dk)
                let photo = INSPhoto(dk: dk)
                self.photos.append(photo)
                self.addChildViewToMedia(dk, index: i)
            }
            
        }
        pickerController.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(pickerController, animated: true) {}
    }
    
    func addChildViewToMedia(_ dk: DKAsset, index: Int)
    {
        let media = CourseDetailMediaView.instanceFromNib()
        dk.fetchOriginalImage(completeBlock: { (image, info) in
            media.coverIV.image = image
        })
        media.subBtn.isHidden = false
        media.tag = index
        media.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageAction(_:))))
        media.deleteBlock = {[weak self](child) in
            child.removeFromSuperview()
            if !(self?.mediaView.subviews.contains((self?.addBtn)!))!
            {
                self?.mediaView.addSubview((self?.addBtn)!)
            }
            self?.mediaArr.remove(at: child.tag)
            self?.refreshMediaView()
        }
        
        self.mediaView.insertSubview(media, at: self.mediaView.subviews.count-1)
        
        if self.mediaView.subviews.count > 3
        {
            self.addBtn.removeFromSuperview()
        }
        
        refreshMediaView()
        
    }
    
    func refreshMediaView()
    {
        var last:UIView?
        
        for i in 0..<self.mediaView.subviews.count
        {
            let child = self.mediaView.subviews[i]
            if last == nil
            {
                child.na_left = 0
            }else{
                child.na_left = last!.na_right + margin
            }
            
            last = child
        }
    }
    
    @objc func tapImageAction(_ tap: UITapGestureRecognizer)
    {
        let index = tap.view!.tag
        
        
        
        let currentPhoto = photos[index]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
        
        let photobrower = PhotoBrowerOverlayView.instanceFromNib()
        photobrower.delegate = self
        photobrower.currentIndex = index
        galleryPreview.overlayView = photobrower
        galleryPreview.modalPresentationStyle = .fullScreen
        ToolClass.controller2(view: self)?.present(galleryPreview, animated: true, completion: nil)
        
    }
    
    @objc func tapVideoAction(_ tap: UITapGestureRecognizer)
    {
        let child = tap.view
        let parentFrame =  child?.superview!.convert((child?.frame)!, to: ToolClass.controller2(view: self)?.navigationController?.view)
        self.delegate?.playVideo(parentFrame!, path: self.videoPath, video: nil)
        
    }
    
    //获取动作数据
    func getMotionData() -> Any
    {
        if self.actualDic.isEmpty
        {
            return self
        }
        
        var data = [String:Any]()
        data["code"] = self.motionCode
        data["target"] = self.dataDic["target"] as! [String:Any]
        data["actual"] = self.actualDic
        
        var imgsArr = [UIImage]()
        for view in self.mediaView.subviews
        {
            if let mediaView = view as? CourseDetailMediaView
            {
                if !mediaView.playIV.isHidden
                {
                    //视频
                    let video = ["path":self.videoPath,"cover":self.coverPath]
                    data["video"] = video
                    break
                }else{
                    imgsArr.append(mediaView.coverIV.image!)
                }
            }
        }
        
        if imgsArr.count != 0 {
            data["imgs"] = imgsArr
        }
        
        return data
        
    }
}

extension CourseDetailMotion: CourseVideoRecordVCDelegate,PhotoBrowerActionDelegate,MotionTrainingRebackDelegate
{
    func trainingData(_ actual: [String : Any], groupMotions: [[String : Any]]?) {
        if groupMotions == nil
        {
            let time = actual["time"] as! Int
            self.actualLB.text = ToolClass.secondToText(time)
        }else{
            let groupNum = actual["groupNum"] as! String
            let freNum = actual["freNum"] as! String
            let weight = actual["weight"] as! String
            self.actualLB.text = groupNum + "组  " + freNum + "个/组  " + weight + "kg"
        }
        
        self.actualBtn.isSelected = true
        
        actualDic["time"] = actual["time"] as! Int
        actualDic["list"] = groupMotions
    }
    
    func deleteAction(_ index: Int) {
        
    }
    
    func recordFinfish(_ output: String) {
        
        self.videoPath = output
        
        self.mediaArr.append(output)
        
        let image = ToolClass.getCoverFromVideo(output)
        
        coverPath = PPBodyPathManager.compositionRootDir() + "/" + motionCode + "cover.png"
        let data = image.pngData()
        try! data?.write(to: URL(fileURLWithPath: coverPath!))
        
        
        let media = CourseDetailMediaView.instanceFromNib()
        media.subBtn.isHidden = false
        media.coverIV.image = image
        media.playIV.isHidden = false
        media.tag = self.mediaView.subviews.count - 1
        media.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapVideoAction(_:))))
        media.deleteBlock = {[weak self](child) in
            child.removeFromSuperview()
            if !(self?.mediaView.subviews.contains((self?.addBtn)!))!
            {
                self?.mediaView.addSubview((self?.addBtn)!)
            }
            self?.mediaArr.remove(at: child.tag)
            self?.refreshMediaView()
        }
        
        self.mediaView.insertSubview(media, at: self.mediaView.subviews.count-1)
        
        self.addBtn.removeFromSuperview()
        
        refreshMediaView()
        
        
    }
}
