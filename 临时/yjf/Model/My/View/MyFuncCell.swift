//
//  MyFuncCell.swift
//  YJF
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyFuncCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ type: MyFuncType) {
        var imgName = ""
        switch type {
        case .bid:
            titleLB.text = "我的竞买"
            imgName = "my_icon_buy"
        case .footmark:
            titleLB.text = "浏览过的房源"
            imgName = "my_icon_liulan"
        case .attention:
            titleLB.text = "关注的房源"
            imgName = "my_icon_attention"
        case .evaluate:
            titleLB.text = "评价与反馈"
            imgName = "my_icon_pingjia"
        case .discount:
            titleLB.text = "佣金折扣"
            imgName = "my_icon_money"
        case .collect:
            titleLB.text = "收藏的房源"
            imgName = "my_icon_fav"
        case .looked:
            titleLB.text = "实地看过的房源"
            imgName = "my_icon_looked"
        case .myHouse:
            titleLB.text = "我的房源"
            imgName = "my_icon_house"
        case .showFirst:
            titleLB.text = "房源优显"
            imgName = "my_icon_viphouse"
        case .about:
            titleLB.text = "关于我们"
            imgName = "my_icon_about"
        }
        iconIV.image = UIImage(named: imgName)
    }
}
