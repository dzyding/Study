//
//  AddHousePhotoHeader.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class AddHousePhotoHeader: UICollectionReusableView {

    @IBOutlet private weak var msgLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ num: Int) {
        msgLB.text = "最多上传\(num)张"
    }
}
