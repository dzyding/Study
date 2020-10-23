//
//  CoachPayView.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol CoachPayDelegate:NSObjectProtocol {
    func payCoachMember(_ dues: Int, payType: String)
}

class CoachPayView: UIView {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var centerYLC: NSLayoutConstraint!
    
    @IBOutlet weak var viewYellow: UIView!
    @IBOutlet weak var imgHead: UIImageView!
    
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var lblMoney: UILabel!
    
    weak var delegate:CoachPayDelegate?
    
    var uid:String?
    
    var dues = 0
 
    var isFree = false{
        didSet{
            if isFree {
                self.lblMoney.text = "首次申请免费"
            }else{
                 self.lblMoney.text = "成为学员需要支付\(dues)滴汗水"
            }
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
    
    static func showCoachPayView() -> CoachPayView
    {
        let v = CoachPayView.instanceFromNib()
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
        delegate?.payCoachMember(dues, payType: "")
    }
    
    class func instanceFromNib() -> CoachPayView {
        return UINib(nibName: "CoachPayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CoachPayView
    }
}

