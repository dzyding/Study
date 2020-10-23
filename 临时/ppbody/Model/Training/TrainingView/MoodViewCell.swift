//
//  MoodViewCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MoodViewCell: ScalingCarouselCell {
    
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var playIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setData(_ url: String, type: Int)
    {
        if type == 10
        {
            //图文
            self.playIV.isHidden = true
        }else{
            self.playIV.isHidden = false
        }
        self.coverIV.setCoverImageUrl(url)
    }
}
