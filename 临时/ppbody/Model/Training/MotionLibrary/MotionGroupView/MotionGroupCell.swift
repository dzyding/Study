//
//  MotionGroupCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MotionGroupCell: UICollectionViewCell {
    @IBOutlet weak var bgIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    var index = Int() // 下标
    
    func setData(_ dic: [String:Any])
    {
        self.bgIV.image = UIImage(named: dic["bg"] as! String)
        self.nameLB.text = dic["name"] as? String
    }
}
