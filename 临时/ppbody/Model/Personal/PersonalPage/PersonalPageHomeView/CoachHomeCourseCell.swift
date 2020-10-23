//
//  CoachHomeCourseCell.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachHomeCourseCell: UICollectionViewCell {
    

    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true

    }

    
    func setData(_ dic:[String:Any])
    {
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.nameLB.text = dic["name"] as? String
    }
   
}
