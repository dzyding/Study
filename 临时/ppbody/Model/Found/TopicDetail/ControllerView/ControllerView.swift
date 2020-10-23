//
//  ControllerView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol ControllerViewActionDelegate:NSObjectProtocol {
    //显示评论
    func commentShowAction()
    //详情
    func detailAction()
    //评论
    func commentAction()
    //分享
    func shareAction()
    //点赞
    func supportAction(_ isSelect: Bool)
    //点击头像
    func personalPage()
    //送礼
    func giftAction()
}

class ControllerView: UIView
{
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var gifIV: UIImageView!
    @IBOutlet weak var commentNumLB: UILabel!
    @IBOutlet weak var supportNumLB: UILabel!
    @IBOutlet weak var supportBtn: FaveButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var shareNumLB: UILabel!
    @IBOutlet weak var giftBtn: UIButton!
    @IBOutlet weak var textBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLB: UILabel!
    
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    weak var delegate:ControllerViewActionDelegate?
    
    
    lazy var contentLB: YYLabel = {
        let label = YYLabel()
        self.textView.addSubview(label)
        label.textColor = UIColor.white
        label.font = ToolClass.CustomFont(14)
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = ScreenWidth - 32
        
        label.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 28, height: 14)
        btn.backgroundColor = UIColor.ColorHex("#BAB9BB")
        btn.titleLabel?.font = ToolClass.CustomFont(9)
        btn.setTitle("详情", for: .normal)
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(detailAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    var dataTopic:[String:Any]?
    
    class func instanceFromNib() -> ControllerView {
        return UINib(nibName: "ControllerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ControllerView
    }
    
    
    func isContainPoint(_ point: CGPoint,  with event: UIEvent?) -> Bool
    {
        if self.headIV.frame.contains(point) ||
            self.supportBtn.frame.contains(point) ||
            self.commentBtn.frame.contains(point) ||
            self.shareBtn.frame.contains(point) ||
            self.addressView.frame.contains(point) ||
            self.giftBtn.frame.contains(point) ||
            self.tagView.frame.contains(point) ||
            self.textView.frame.contains(point) ||
            self.bottomView.frame.contains(point)
        {
            return true
        }
        
        return false
    }

    override func awakeFromNib() {
        //        self.frame = ScreenBounds
        commentTF.delegate = self
        self.commentTF.attributedPlaceholder = NSAttributedString(string: "说你想说的话...",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        
        self.headIV.layer.borderWidth = 1
        self.headIV.layer.borderColor = UIColor.white.cgColor
        self.headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(personalAction)))
        addSeeMoreBtn()
    }
    
    private func addSeeMoreBtn() {
        let buttonText = NSMutableAttributedString.yy_attachmentString(withContent: self.moreBtn, contentMode: .center, attachmentSize: self.moreBtn.frame.size, alignTo: ToolClass.CustomFont(14), alignment: YYTextVerticalAlignment.center)
        
        let moreText = NSMutableAttributedString(string: "... ")
        moreText.yy_color = .white
        moreText.yy_font = ToolClass.CustomFont(14)
        moreText.append(buttonText)
        self.contentLB.truncationToken = moreText
    }
    
    private func setGifImage() {
        let time = "2019-06-03 00:00:00"
        let formatt = DateFormatter()
        formatt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatt.date(from: time),
            date.timeIntervalSince(Date()) < 0
        {
            gifIV.isHidden = true
        }else {
            gifIV.isHidden = false
            let path = Bundle.main.path(forResource: "61.gif", ofType: nil) ?? ""
            gifIV.kf.setImage(with: URL(fileURLWithPath: path))
        }
    }
    
    func setData(_ dic: [String:Any])
    {
        self.dataTopic = dic

        
        let user = dic["user"] as! [String:Any]
        
        self.headIV.setHeadImageUrl(user["head"] as! String)
        setGifImage()

        let type = user["type"] as! Int
        if type == 10
        {
            self.typeLB.isHidden = true
            let uid = user["uid"] as? String
            
            if uid != nil
            {
                let userId = ToolClass.decryptUserId(uid!)
                if userId == 1004
                {
                    //PP助手
                    self.typeLB.isHidden = false
                    self.typeLB.text = "官方"
                    self.typeLB.textColor = UIColor.white
                    self.headIV.layer.borderColor = OfficialColor.cgColor
                    self.typeLB.backgroundColor = OfficialColor
                    self.typeLB.layer.borderWidth = 1
                    self.typeLB.layer.borderColor = UIColor.white.cgColor
                }else{
                    self.headIV.layer.borderColor = UIColor.white.cgColor
                    
                }
            }
            
        }else{
            self.typeLB.isHidden = false
            self.typeLB.text = "教练"
            self.typeLB.textColor = BackgroundColor
            self.typeLB.backgroundColor = YellowMainColor
            self.typeLB.layer.borderWidth = 0
            self.typeLB.layer.borderColor = UIColor.clear.cgColor
            self.headIV.layer.borderColor = YellowMainColor.cgColor
            
        }
        
        let content = dic["content"] as! String
        
        let contentAtt = NSMutableAttributedString(string: content)
        contentAtt.yy_font = ToolClass.CustomFont(14)
        contentAtt.yy_color = UIColor.white
        contentAtt.yy_lineSpacing = 5
        self.contentLB.attributedText = contentAtt
        
        let address = dic["address"] as? String
        if address != nil && !(address?.isEmpty)!
        {
            self.addressView.isHidden = false
            self.addressLB.text = address
            self.textBottomMargin.constant = 35
        }else{
            self.addressView.isHidden = true
            self.textBottomMargin.constant = 10
        }
        
        let tag = dic["tag"] as? String
        if tag != nil && !(tag?.isEmpty)!
        {
            self.tagView.isHidden = false
            self.tagLB.text = tag
        }else{
            self.tagView.isHidden = true
        }
        
        let supportNum = dic["supportNum"] as! Int
        self.supportNumLB.text = supportNum.compressValue
        
        let commentNum = dic["commentNum"] as! Int
        self.commentNumLB.text = commentNum.compressValue
        
        let shareNum = dic["shareNum"] as! Int
        self.shareNumLB.text = shareNum.compressValue
        
        let isSupport = dic["isSupport"] as? Int
        if isSupport != nil
        {
            self.supportBtn.isSelected = isSupport == 1 ? true : false
        }
        
        // 如果是自己，隐藏送礼按钮
        if let uid = dic.dicValue("user")?.stringValue("uid"),
            ToolClass.decryptUserId(uid) == ToolClass.decryptUserId(DataManager.userAuth())
        {
            giftBtn.isHidden = true
        }else {
            giftBtn.isHidden = false
        }
    }
    
    
    func startLoadingPlayItemAnim(_ isStart: Bool)
    {
        if isStart
        {
            self.loadingView.isHidden = false
            self.loadingView.layer.removeAllAnimations()
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.5
            animationGroup.beginTime = CACurrentMediaTime() + 0.5
            animationGroup.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
            animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            let scaleAnimation = CABasicAnimation()
            scaleAnimation.keyPath = "transform.scale.x"
            scaleAnimation.fromValue = 1
            scaleAnimation.toValue = ScreenWidth
            
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.fromValue = 1
            alphaAnimation.toValue = 0.5
            
            animationGroup.animations = [scaleAnimation,alphaAnimation]
            
            self.loadingView.layer.add(animationGroup, forKey: nil)
            
        }else{
            self.loadingView.layer.removeAllAnimations()

            self.loadingView.isHidden = true
        }
    }
    
    
    @IBAction func supportAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var supportNum = Int(self.supportNumLB.text!)!
        
        if sender.isSelected
        {
            supportNum += 1
        }else{
            supportNum -= 1
            
            supportNum = supportNum < 0 ? 0 : supportNum
        }
        
        self.supportNumLB.text = "\(supportNum)"
        
        self.delegate?.supportAction(sender.isSelected)
    }
    
    @IBAction func commentShowAction(_ sender: UIButton) {
        self.delegate?.commentShowAction()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        self.delegate?.shareAction()
    }
    
    @IBAction func giftAction(_ sender: Any) {
        self.delegate?.giftAction()
    }
    
    @objc func personalAction()
    {
        self.delegate?.personalPage()
    }
    
    @objc func detailAction(_ sender: UIButton) {
        self.delegate?.detailAction()
    }
    
}

extension ControllerView:UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.commentAction()
        return false
    }
}
