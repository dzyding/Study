//
//  CoachIMPayView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/15.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


class CoachIMPayView: UIView {
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var centerYLC: NSLayoutConstraint!
    
    @IBOutlet weak var viewYellow: UIView!
    @IBOutlet weak var imgHead: UIImageView!
    
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var lblMoney: UILabel!
    
    @IBOutlet weak var wechatPayBtn: UIButton!
    @IBOutlet weak var alipayBtn: UIButton!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    
    var uid:String?
    
    var payIM = 0
    {
        didSet{
            self.lblMoney.text = "支付\(payIM)元，与心意的教练畅聊"
        }
    }
    var head = ""
    {
        didSet{
            self.imgHead.setHeadImageUrl(head)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [YellowMainColor.cgColor, UIColor.ColorHex("#ffb700").cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = viewYellow.frame
        viewYellow.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        hideCoachPayView()
    }
    
    @IBAction func payAction(_ sender: UIButton) {
        
        sender.isSelected = true
        if sender == self.wechatPayBtn
        {
            self.alipayBtn.isSelected = false
        }else{
            self.wechatPayBtn.isSelected = false
        }
    }
    
    static func showCoachPayView() -> CoachIMPayView
    {
        let v = CoachIMPayView.instanceFromNib()
        v.frame = ScreenBounds
        UIApplication.shared.keyWindow?.addSubview(v)
        
        UIView.animate(withDuration: 0.3) {
            v.centerYLC.constant = 20
            v.layoutIfNeeded()
        }
        
        return v
    }
    
    func hideCoachPayView()
    {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.centerYLC.constant = 600
            self.layoutIfNeeded()
            
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    
    @IBAction func btnJoinClick(_ sender: Any) {
        

        if self.wechatPayBtn.isSelected
        {
            getWechatPre()
        }else{
            getAliPayPre()
        }
    }
    
    class func instanceFromNib() -> CoachIMPayView {
        return UINib(nibName: "CoachPayView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! CoachIMPayView
    }
    
    //微信支付下单
    func getWechatPre()
    {
        /*
        let request = BaseRequest()
        let dic = ["price":"\(self.payIM)","type":"10","uid":self.uid!]
        request.dic = dic
        request.url = BaseURL.WechatPayPreOrder
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                self.btnJoin.isEnabled = true
                return
            }
            
            let pay = data!["payInfoWechat"] as! [String:Any]
            
            let req = PayReq()
            req.openID = pay["appid"] as! String
            req.partnerId = pay["partnerid"] as! String
            req.prepayId = pay["prepayid"] as! String
            req.nonceStr = pay["noncestr"] as! String
            req.timeStamp = UInt32(pay["timestamp"] as! String)!
            req.package = pay["package"] as! String
            req.sign = pay["sign"] as! String
            WXApi.send(req)
        }
         */
    }
    
    func getAliPayPre()
    {
        /*
        let request = BaseRequest()
        let dic = ["price":"\(self.payIM)","type":"10","uid":self.uid!]
        request.dic = dic
        request.url = BaseURL.AliPayPreOrder
        request.isUser = true
        
        request.start { (data, error) in
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let orderStr = data!["payInfoAlipay"] as! String
            AlipaySDK.defaultService().payOrder(orderStr, fromScheme: "ppbody", callback: { (resultDic) in
                print(resultDic)
            })
        }
         */
    }
}
