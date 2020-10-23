//
//  ShareItemView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/11/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class ShareItemView: UIView {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var iconIV: UIImageView!
    
    class func instanceFromNib() -> ShareItemView {
        return UINib(nibName: "ShareItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ShareItemView
    }
    
    func setData(_ dic:[String:String])
    {
        titleLB.text = dic["title"]
        iconIV.image = UIImage(named: dic["icon"]!)
    }
}
