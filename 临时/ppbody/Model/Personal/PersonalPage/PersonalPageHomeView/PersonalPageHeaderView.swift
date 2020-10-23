//
//  PersonalPageHeaderView.swift
//  PPBody
//
//  Created by edz on 2018/12/5.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol PersonalPageHeaderViewDelegate: NSObjectProtocol {
    func applyAction()
    func attentionAction(_ isAttention:Bool)
    func imAction()
    /// 点击头像
    func headAction(_ image: UIImage)
}

class PersonalPageHeaderView: UIView, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var queenIV: UIImageView!
    @IBOutlet weak var headIV: UIImageView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    
    @IBOutlet weak var briefLB: UILabel!
    
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var attentionBtn: UIButton!
    @IBOutlet weak var attentionRight: NSLayoutConstraint!
    @IBOutlet weak var IMBtn: UIButton!
    /// 名称
    @IBOutlet weak var nicknameLB: UILabel!
    /// 评论? (类似名字)
    @IBOutlet weak var remarkLB: UILabel!
    /// 教练
    @IBOutlet weak var identifyBtn: UIButton!
    /// 粉色，关注视图
    @IBOutlet weak var numLB: UILabel!
    /// 教练标签视图距离 nameLB 的距离
    @IBOutlet weak var scrollViewTopLC: NSLayoutConstraint!
    
    weak var delegate:PersonalPageHeaderViewDelegate?
    var payType = 10 //IM 支付
    
    class func instanceFromNib() -> PersonalPageHeaderView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PersonalPageHeaderView
    }
    
    deinit {
        deinitObservers()
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickHeadAction(_:)))
        headIV.addGestureRecognizer(tap)
        headIV.isUserInteractionEnabled = true
        
        registObservers([
            Config.Notify_PaySuccess
        ], queue: .main) { [weak self] (_) in
            //支付成功的回调通知
            if self?.payType == 20 {
                UIView.animate(withDuration: 0.25, animations: {
                    self?.applyBtn.alpha = 0
                }, completion: { (finish) in
                    self?.applyBtn.isHidden = true
                })
            }
        }
        
        registObservers([
            Config.Notify_ExitMember
        ], queue: .main) { [weak self] (_) in
            //解除会员关系
            self?.applyBtn.isHidden = false
            self?.applyBtn.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self?.applyBtn.alpha = 1
            }, completion: { (finish) in
                
            })
        }
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        payType = 20
        self.delegate?.applyAction()
    }
    
    @IBAction func attentionAction(_ sender: UIButton) {
        attentionBtnStatus(!sender.isSelected)
        self.delegate?.attentionAction(sender.isSelected)
    }
    
    //    MARK: - 点击头像
    @objc func clickHeadAction(_ tap: UITapGestureRecognizer) {
        if let imageView = tap.view as? UIImageView,
            let image = imageView.image
        {
            self.delegate?.headAction(image)
        }
    }
    
    //    MARK: - IM
    @IBAction func imAction(_ sender: UIButton) {
        payType = 10
        self.delegate?.imAction()
    }
    
    func setData(_ dic: [String:Any]) {
        guard let user = dic.dicValue("user") else {return}
        
        self.headIV.setHeadImageUrl(user["head"] as! String)
        
        let remark = user["remark"] as? String
        if remark != nil
        {
            self.nicknameLB.text = remark
            self.remarkLB.text = "(" + (user["nickname"] as! String) + ")"
            self.remarkLB.isHidden = false
        }else{
            self.nicknameLB.text = user["nickname"] as? String
        }
        
        self.briefLB.text = user["brief"] as? String
        
        if (self.briefLB.text?.isEmpty)!
        {
            self.briefLB.isHidden = true
        }
        
        let type = user["type"] as! Int
        
        let own = dic["own"] as? Int
        
        if type != 20 {
            //对方是用户
            headIV.layer.borderWidth = 2
            headIV.layer.borderColor = UIColor.white.cgColor
            
            identifyBtn.isHidden = true
            applyBtn.isHidden  = true
            attentionBtn.isHidden = false
            IMBtn.isHidden = false
            attentionRight.constant = 58
            
            if briefLB.isHidden {
                scrollViewTopLC.constant = -10
            }else{
                scrollViewTopLC.constant = 10
            }
            
            if DataManager.isCoach() {
                if let isMember = dic.intValue("isMember"),
                    isMember == 1
                {
                    // 已经是会员了
                }else{
                    attentionRight.constant = 16
                    IMBtn.isHidden = true
                }
            }
        }else{
            //对方是教练
            headIV.layer.borderWidth = 2
            headIV.layer.borderColor = YellowMainColor.cgColor
            
            attentionBtn.isHidden = false
            identifyBtn.isHidden = false
            
            // 是否显示教练标签，及布局高度调整
            let tags = user["tags"] as? String ?? ""
            let tagArr = tags.components(separatedBy: "|")
            if tagArr.count == 0 {
                self.scrollview.isHidden = true
                if self.briefLB.isHidden
                {
                    scrollViewTopLC.constant = 0
                }else{
                    scrollViewTopLC.constant = 20
                }
            }else{
                setTagView(tagArr)
                
                if self.briefLB.isHidden
                {
                    scrollViewTopLC.constant = 20
                }else{
                    scrollViewTopLC.constant = 50
                }
            }
            
            if DataManager.isCoach() {
                applyBtn.isHidden = true
                IMBtn.isHidden = true
                attentionRight.constant = 16
            }else{
                IMBtn.isHidden = false
                
                if let isMember = dic.intValue("isMember"),
                    isMember == 1
                {
                    //已经是会员了
                    applyBtn.isHidden = true
                }else {
                    applyBtn.isHidden = false
                }
            }
        }
        
        if own != nil && own == 1 {
            //自己看自己
            applyBtn.isHidden = true
            attentionBtn.isHidden = true
            IMBtn.isHidden = true
        }else{
            let isAttention = dic["isAttention"] as! Int
            attentionBtnStatus(isAttention == 1 ? true : false)
            
            let uid = user["uid"] as? String

            if uid != nil
            {
                let userId = ToolClass.decryptUserId(uid!)
                if userId == 1004
                {
                    //PP助手
                    headIV.layer.borderColor = UIColor.ColorHex("#ff4e50").cgColor
                    identifyBtn.setBackgroundImage(UIImage(named: "mind_own"), for: .normal)
                    identifyBtn.isHidden = false
                    identifyBtn.setTitleColor(UIColor.white, for: .normal)
                    identifyBtn.setTitle("官方", for: .normal)
                }
            }
        }
        
        
        let relation = dic["relation"] as! [String:Any]
        
        let attentionNum = relation["attentionNum"] as! Int
        let followNum = relation["followNum"] as! Int
        
        var numshow = followNum.compressValue + "粉丝" + " · " + attentionNum.compressValue + "关注"
        
        let memberNum = relation["memberNum"] as? Int
        
        if memberNum != nil
        {
            numshow = numshow + " · " + (memberNum?.compressValue)! + "学员"
        }
        self.numLB.text = numshow
    }
    
    func setTagView(_ tags:[String])
    {
        for view in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        var limitNum = 0
        for tag in tags
        {
            if limitNum == 3
            {
                break
            }
            let txt = UILabel()
            txt.text = tag
            txt.font = ToolClass.CustomFont(10)
            txt.textColor = .white
            txt.textAlignment = .center
            txt.backgroundColor = RGB(r: 102, g: 102, b: 102)
            txt.layer.cornerRadius = 3
            txt.layer.masksToBounds = true
            txt.sizeToFit()
            
            txt.snp.makeConstraints { (make) in
                make.width.equalTo(txt.na_width + 14)
                make.height.equalTo(txt.na_height + 4)

            }
            self.stackview.addArrangedSubview(txt)
            
            limitNum += 1
        }
    }
    
    //是否关注呈现关注按钮的状态
    func attentionBtnStatus(_ attention: Bool)
    {
        if attention
        {
            self.attentionBtn.backgroundColor = ColorLine
        }else{
            self.attentionBtn.backgroundColor = YellowMainColor
        }
        self.attentionBtn.isSelected = attention
    }
}
