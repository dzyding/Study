//
//  MineInfoVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import DKImagePickerController

class MineInfoVC: BaseVC {

    /// 上半部分
    @IBOutlet weak var stackview: UIStackView!
    /// 头像
    @IBOutlet weak var headIV: UIImageView!
    /// 昵称
    @IBOutlet weak var nameTF: UITextField!
    /// 身份
    @IBOutlet weak var identityLB: UILabel!
    /// 教练专长
    @IBOutlet weak var tagStackview: UIStackView!
    /// 教练专长所属视图
    @IBOutlet weak var coachView: UIView!
    /// 简介
    @IBOutlet weak var briefTF: UITextField!
    /// 城市
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityLB: UILabel!
    /// 性别
    @IBOutlet weak var sexLB: UILabel!
    /// 身高
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var heightLB: UILabel!
    /// 生日
    @IBOutlet weak var birthdayView: UIView!
    @IBOutlet weak var birthdayLB: UILabel!
    /// 城市、性别、身高、生日 所属视图
    @IBOutlet weak var infoView: UIView!
    /// 成为学员价格
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var tipLB: UILabel!
    
    
    var newImg: UIImage?
    var originInfo:[String:Any]?
    
    var heightArr = [String]()
    
    var tagStr:String?
    
    lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "个人资料"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnCommit)
        nameTF.setPlaceholderColor(Text1Color)
//        priceTF.setPlaceholderColor(Text1Color)
        briefTF.setPlaceholderColor(Text1Color)

        
        headIV.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        cityView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        heightView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        birthdayView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        coachView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        
        getUserInfo()
        
        if !DataManager.isCoach()
        {
            self.identityLB.text = "健身达人"
            self.stackview.removeArrangedSubview(self.coachView)
            self.coachView.removeFromSuperview()
            
            self.infoView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-32)
            }
        }else{
            self.identityLB.text = "认证教练"
        }

        //移除价格修改
        self.priceView.removeFromSuperview()

        
        for i in 120...210 {
            heightArr.append("\(i)")
        }
    }
    
    //    MARK: - 保存
    @objc func saveAction() {
        
        if (self.nameTF.text?.isEmpty)!
        {
            ToolClass.showToast("请输入昵称", .Failure)
            return
        }
        
        if self.newImg != nil
        {
            let imgArr = AliyunUpload.upload.uploadAliOSS([self.newImg!], type: .Head) { (progress) in
                
            }
            
            self.dataDic["head"] = imgArr[0]
        }
        
        if self.nameTF.text != self.originInfo!["nickname"] as? String{
            self.dataDic["nickname"] = self.nameTF.text
        }
        
        if self.cityLB.text !=  self.originInfo!["city"] as? String{
            self.dataDic["city"] = self.cityLB.text
        }
        
        if self.heightLB.text != "\(self.originInfo!["height"] as! Int)cm"
        {
            self.dataDic["height"] = self.heightLB.text?.replacingOccurrences(of: "cm", with: "")
        }
        
        if self.birthdayLB.text != self.originInfo!["birthday"] as? String
        {
            self.dataDic["birthday"] = self.birthdayLB.text
        }
        
        if self.briefTF.text != self.originInfo!["brief"] as? String
        {
            self.dataDic["brief"] = self.briefTF.text
        }
        
        if self.tagStr != nil
        {
            self.dataDic["tags"] = self.tagStr!
        }
        
//        if DataManager.isCoach()
//        {
//            if self.priceTF.isEnabled
//            {
//                let priceNew = Int(self.priceTF.text!)
//                let originPrice = self.originInfo!["dues"] as! Int
//
//                if priceNew! < 30
//                {
//                    ToolClass.showToast("价格必须大于等于30元", .Failure)
//                    return
//                }
//
//                if priceNew != originPrice
//                {
//                    self.dataDic["dues"] = self.priceTF.text!
//                }
//            }
//        }
        
        if self.dataDic.isEmpty
        {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        editUserInfo()
    }
    
    @objc func tapView(tap: UITapGestureRecognizer) {
        if tap.view == coachView {
            let vc = SelectCoachSepecialVC()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == cityView {
            let vc = CityVC()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == heightView {
            
            let height = self.heightLB.text!.replacingOccurrences(of: "cm", with: "")
            let index = self.heightArr.firstIndex(of: height)
            
            let alert = ActionSheetStringPicker.init(title: "请选择身高", rows: heightArr, initialSelection: index!, doneBlock: { (picker, selectIndex, selectValue) in
                self.heightLB.text = selectValue as! String + "cm"
            }, cancel: { (picker) in
                
            }, origin: tap.view)
             ToolClass.setActionSheetStyle(alert: alert!)
            
        }
        else if tap.view == birthdayView {
            
            var selecttime = Date().set(year: 1990, month: 2, day: 7, hour: nil, minute: nil, second: nil, tz: nil)
            
            let former = DateFormatter()
            former.dateFormat = "yyyy-MM-dd"
            
            if !(self.birthdayLB.text?.isEmpty)!
            {

                selecttime = former.date(from: self.birthdayLB.text!)!
            }
            
            let begin = Date().set(year: 1950, month: 2, day: 7, hour: nil, minute: nil, second: nil, tz: nil)
            let end = Date().set(year: 2008, month: 2, day: 7, hour: nil, minute: nil, second: nil, tz: nil)
            
            let alert = ActionSheetDatePicker.init(title: "请选择出生日期", datePickerMode: .date, selectedDate: selecttime, doneBlock: { (picker, selectedDate, origin) in
                
                self.birthdayLB.text = former.string(from: selectedDate as! Date)
            }, cancel: { (picker) in
                
            }, origin: tap.view)
 
            alert?.minimumDate = begin
            alert?.maximumDate = end
            
            
            ToolClass.setActionSheetStyle(alert: alert!)
        }
        else if tap.view == headIV {
            //弹出相册
            showImagePickerWithAssetType(
                    .allPhotos,
                    allowMultipleType: false,
                    sourceType: .photo,
                    allowsLandscape: true,
                    singleSelect: true
            )
   
        }
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
                
                for asset in assets {
         
                    asset.fetchOriginalImage(completeBlock:{ (image, info) in
                        let controller = CropViewController()
                        controller.delegate = self
                        controller.image = image
                        controller.cropAspectRatio = 1.0
                        controller.keepAspectRatio = true
                        controller.toolbarHidden = true
                        let navController = UINavigationController(rootViewController: controller)
                        navController.modalPresentationStyle = .fullScreen
                        self.present(navController, animated: true, completion: nil)
                    })
                }
        }
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true) {}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setData(_ dic: [String:Any])
    {
        self.headIV.setHeadImageUrl(dic["head"] as! String)
        self.nameTF.text = dic["nickname"] as? String
        
        if DataManager.isCoach() {
            let tags = dic["tags"] as! String
            let tagArr = tags.components(separatedBy: "|")
            setTagView(tagArr)
//
//            let memberNum = dic["memberNum"] as! Int
//            let dues = dic["dues"] as! Int
//
//            if memberNum < 9
//            {
//                self.priceTF.isEnabled = false
//                self.priceTF.textColor = Text1Color
//            }else{
//                self.priceTF.isEnabled = true
//                self.priceTF.textColor = UIColor.white
//            }
//            self.priceTF.text = "\(dues)"
//            self.tipLB.text = "学员人数达到10人以上可以修改，超出30元的费用当月结算给相应的教练，当前学员数（\(memberNum)人）"
        }
        
        self.cityLB.text = dic["city"] as? String
        
        let sex = dic["sex"] as! Int
        
        self.sexLB.text = sex == 10 ? "男" : "女"
        self.heightLB.text = "\(dic["height"] as! Int)cm"

        self.birthdayLB.text = dic["birthday"] as? String
        self.briefTF.text = dic["brief"] as? String
    }
    
    
    func setTagView(_ tags:[String])
    {
        for view in self.tagStackview.arrangedSubviews
        {
            self.tagStackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for tag in tags
        {
            let txt = UILabel()
            txt.text = tag
            txt.font = ToolClass.CustomFont(12)
            txt.textColor = YellowMainColor
            txt.layer.borderWidth = 1
            txt.layer.borderColor = YellowMainColor.cgColor
            txt.textAlignment = .center
            txt.backgroundColor = YellowMainColor.withAlphaComponent(0.5)
            txt.sizeToFit()
    
            txt.snp.makeConstraints { (make) in
                make.width.equalTo(txt.na_width + 16)
                make.height.equalTo(txt.na_height + 8)

            }
            txt.layer.cornerRadius = txt.na_height/2
            txt.layer.masksToBounds = true
            
            self.tagStackview.addArrangedSubview(txt)
        }
    }

    func getUserInfo()
    {
        let request = BaseRequest()
        request.url = BaseURL.UserInfo
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }

            let info = data!["info"] as! [String:Any]
            self.originInfo = info
            self.setData(info)
        }
    }
    
    func editUserInfo()
    {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String : String]
        request.url = BaseURL.EditUserInfo
        request.isUser = true
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let newUser = data!["user"] as! [String:Any]
            DataManager.saveUserInfo(newUser)
            
            ToolClass.showToast("保存成功", .Success)
            
            if let newImg = self.newImg,
                let nickname = newUser["nickname"] as? String
            {
                NotificationCenter.default
                    .post(name: Config.Notify_ChangeHead,
                          object: nil,
                          userInfo: ["head": newImg,
                                     "nickname" : nickname])
            }

            ToolClass.dispatchAfter(after: 3, handler: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

}

extension MineInfoVC: CropViewControllerDelegate,CitySelectDelegate,SelectCoachSepecialDelegate {
    
    func selectTags(_ tags: String) {
        let tagArr = tags.components(separatedBy: "|")
        setTagView(tagArr)
        self.tagStr = tags
    }
    
    func selectCity(_ city: String) {
        self.cityLB.text = city
    }
    
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        self.headIV.image = image
        self.newImg = image
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    

}
