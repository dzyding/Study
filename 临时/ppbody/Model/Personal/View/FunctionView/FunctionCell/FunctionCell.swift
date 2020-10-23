//
//  FunctionCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class FunctionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var iconIV: UIImageView!
    
    func setData(_ dic: [String:Any])
    {
        self.iconIV.image = UIImage(named: dic["icon"] as! String)
        self.titleLB.text = dic["name"] as? String
    }
}
