//
//  SetPhotoCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SetPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imgContent: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgContent.layer.cornerRadius = 5.0
        // Initialization code
    }

}
