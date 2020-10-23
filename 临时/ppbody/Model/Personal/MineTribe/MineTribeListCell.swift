//
//  MineTribeListCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeListCell: UITableViewCell {
    
    @IBOutlet weak var imgContent: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblNum: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(dic: [String: Any]) {
        imgContent?.setCoverImageUrl(dic["cover"] as? String ?? "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530701138383&di=e3c6930861b72441b4628b10bbe8b445&imgtype=0&src=http%3A%2F%2Fimg4.duitang.com%2Fuploads%2Fitem%2F201602%2F28%2F20160228014432_ShZJL.jpeg")
        lblTitle.text = dic["name"] as? String ?? ""
        lblDesc.text = dic["slogan"] as? String ?? ""
        lblNum.text = "成员：" + (dic["memberNum"] as! NSNumber).stringValue + "人"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
