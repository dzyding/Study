//
//  MineTribeDetailHeaderView.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeDetailHeaderView: UIView {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblCreateTime: UILabel!
    @IBOutlet weak var lblNum: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var viewCard: UIView!

    
    
    class func instanceFromNib() -> MineTribeDetailHeaderView {
        return UINib(nibName: "MineTribeDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MineTribeDetailHeaderView
    }
    
    func setData(_ dic:[String:Any])
    {
        self.imgBg.setCoverImageUrl(dic["cover"] as! String)
        self.lblNum.text = (dic["totalMember"] as! NSNumber).stringValue
        self.lblTitle.text = dic["name"] as? String
        self.lblCreateTime.text = (dic["createTime"] as! String)[0..<9]
        self.lblDesc.text = dic["slogan"] as? String
        
        let city = dic["city"] as! String
        self.lblArea.text = city.isEmpty ? "未知城市" : city
    }

}
