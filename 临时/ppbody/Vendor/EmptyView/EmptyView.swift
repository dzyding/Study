//
//  EmptyView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/17.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum EmptyStyle{
    case MotionStatistics
    case AttentionEmpty
    case SearchEmpty
}

class EmptyView: UIView
{
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var txtLB: UILabel!
    @IBOutlet weak var coverCenterX: NSLayoutConstraint!
    
    func setStyle(_ style: EmptyStyle)
    {
        switch style {
        case .MotionStatistics:
            coverIV.image = UIImage(named: "statistic_empty")
            txtLB.text = "您还没有数据记录，赶快开始锻炼吧！"
            self.coverCenterX.constant = 0

        case .AttentionEmpty:
            coverIV.image = UIImage(named: "attention_empty")
            txtLB.text = "暂无好友动态，去关注心仪的小伙伴吧！"
            self.coverCenterX.constant = 0
            
        case .SearchEmpty:
            coverIV.image = UIImage(named: "common_empty")
            txtLB.text = "搜索内容暂无，可以换个关键词试试！"
            self.coverCenterX.constant = 10
        }
    }
    
}
