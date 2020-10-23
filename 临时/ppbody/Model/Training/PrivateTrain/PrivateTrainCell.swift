//
//  PrivateTrainCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PrivateTrainCell: UICollectionViewCell {

    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblLitterDesc: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.backgroundColor = BackgroundColor
        // Initialization code
    }
    
    func setData(data: [String: Any]) {
        imgBg.setHeadImageUrl(data["cover"] as! String)
        lblTitle.text = "【\(data["name"] as! String)】"
        lblDesc.text = data["content"] as? String
        lblLitterDesc.text = "被训练\(data["useNum"]!)次"
    }

}
