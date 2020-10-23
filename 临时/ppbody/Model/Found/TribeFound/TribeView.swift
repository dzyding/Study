//
//  TribeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeView: UIView
{
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var memberLB: UILabel!
    @IBOutlet weak var hotNumLB: UILabel!
    
    class func instanceFromNib() -> TribeView {
        return UINib(nibName: "TribeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TribeView
    }
    
    func setData(_ dic: [String:Any])
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.titleLB.text = "\(dic["name"]!)"
        
        self.hotNumLB.text = (dic["contributionNum"] as! NSNumber).floatValue.removeDecimalPoint
        self.memberLB.text = "成员：" + (dic["memberNum"] as! Int).compressValue
    }
}
