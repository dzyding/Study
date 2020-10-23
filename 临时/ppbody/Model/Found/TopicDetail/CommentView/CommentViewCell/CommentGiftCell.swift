//
//  CommentGiftCell.swift
//  PPBody
//
//  Created by edz on 2018/12/13.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CommentGiftCell: UITableViewCell {
    
    // 用户头像
    @IBOutlet weak var headIV: UIImageView!
    // 用户姓名
    @IBOutlet weak var nameLB: UILabel!
    // 详细信息
    @IBOutlet weak var msgLB: UILabel!
    // 礼物图片
    @IBOutlet weak var giftIV: UIImageView!
    // 礼物数量
    @IBOutlet weak var numLB: UILabel!
    
    var data: [String : Any]? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msgLB.textColor = YellowMainColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateViews() {
        guard let data = data, let user = data.dicValue("user"), let gift = data.dicValue("gift") else {return}
        headIV.setCoverImageUrl(user.stringValue("head") ?? "")
        nameLB.text = user.stringValue("nickname")
        msgLB.text = "赠送给作者\(gift.stringValue("name") ?? "")"
        giftIV.setCoverImageUrl(gift.stringValue("cover") ?? "")
        numLB.text = "X\(data.intValue("num") ?? 0)"
    }
}

// 给 text 添加描边
class GiftNameLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        //描边
        guard let c = UIGraphicsGetCurrentContext() else {return}
        c.setLineWidth(0.5)
        c.setLineJoin(.round)
        c.setTextDrawingMode(.stroke)
        //描边颜色
        textColor = .red
        super.drawText(in: rect)
        //文字颜色
        textColor = .white
        c.setTextDrawingMode(.fill)
        super.drawText(in: rect)
    }
}
