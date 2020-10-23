//
//  T12GoodsListCell.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class T12GoodsListCell: UITableViewCell {

    @IBOutlet weak var imgIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        imgIV.setCoverImageUrl(data.stringValue("banner") ?? "")
    }
}
