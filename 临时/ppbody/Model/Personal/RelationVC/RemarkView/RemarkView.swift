//
//  RemarkView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/10/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RemarkView: UIView {
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var remarkTF: UITextField!
    
    @IBOutlet weak var contentView: UIView!
    
    var complete:((String) -> ())?
    var userDic:[String:Any]?
    {
        didSet{
            self.headIV.setHeadImageUrl(userDic!["head"] as! String)
            self.nameLB.text = userDic!["nickname"] as? String
            
            let remark = userDic!["remark"] as? String
            if remark != nil
            {
                self.remarkTF.text = remark
            }
        }
        
    }
    
    class func instanceFromNib() -> RemarkView {
        return UINib(nibName: "RemarkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RemarkView
    }
    
    override func awakeFromNib() {
        self.remarkTF.attributedPlaceholder = NSAttributedString(string: "请输入备注名称",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        
        let animation = CASpringAnimation(keyPath: "transform.scale")
        
        animation.duration = animation.settlingDuration // 动画持续时间
        animation.repeatCount = 1 // 重复次数
        animation.autoreverses = false // 动画结束时执行逆动画
        animation.mass = 1
        animation.stiffness = 100
        animation.damping = 13
        animation.initialVelocity = 8
        animation.fillMode = CAMediaTimingFillMode.removed
        animation.isRemovedOnCompletion = true
        
        animation.fromValue = 0.1
        animation.toValue = 1
        
        self.contentView.layer.add(animation, forKey: nil)
    }

    
    @IBAction func okAction(_ sender: UIButton) {
        if (self.remarkTF.text?.isEmpty)!
        {
            ToolClass.showToast("请填写备注名称", .Success)
            return
        }
        
        self.remarkAPI()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    
    //关注用户 和取消
    func remarkAPI()
    {
        let request = BaseRequest()
        request.dic = ["uid":userDic!["uid"] as! String,"remark":self.remarkTF.text!]
        request.url = BaseURL.RemarkMember
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.complete?(self.remarkTF.text!)
            
            self.removeFromSuperview()
        }
    }
    
}
