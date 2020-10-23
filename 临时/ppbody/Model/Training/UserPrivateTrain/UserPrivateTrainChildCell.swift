//
//  UserPrivateTrainChildCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class UserPrivateTrainChildCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    @IBOutlet weak var lblTrainNum: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        // Initialization code
    }
    
    func setData(data: [String: Any]) {
        imgBg.setHeadImageUrl(data["cover"] as! String)
        lblTitle.text = data["name"] as? String
        lblDesc.text = data["content"] as? String
        lblTrainNum.text = "被训练\(data["useNum"]!)次"
    }

}
