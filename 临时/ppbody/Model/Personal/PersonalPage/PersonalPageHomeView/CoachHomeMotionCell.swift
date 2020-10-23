//
//  CoachHomeMotionCell.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachHomeMotionCell: UICollectionViewCell {
    

    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var coverIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(_ dic:[String:Any])
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.nameLB.text = dic["name"] as? String
    }
}
