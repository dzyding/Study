//
//  TagView_old.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TagView_old: UIView
{
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    
    class func instanceFromNib() -> TagView_old {
        return UINib(nibName: "TagView_old", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TagView_old
    }
    
    func setData(_ dic: [String:Any])
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.titleLB.text = "#\(dic["name"]!)#"
    }
}
