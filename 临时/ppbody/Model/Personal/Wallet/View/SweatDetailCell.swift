//
//  SweatDetailCell.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SweatDetailCell: UITableViewCell {
    /// 详细信息
    @IBOutlet weak var msgLB: UILabel!
    /// 日期
    @IBOutlet weak var dateLB: UILabel!
    /// 数量
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func updateViews(_ data: [String : Any]) {
        msgLB.text = data.stringValue("content")
        dateLB.text = ToolClass.compareCurrentTime(date: data.stringValue("createTime") ?? Date().description)
        if let type = data.intValue("type"),
            let num = data.intValue("num")
        {
            let color = type <= 20 ? RGB(r: 110.0, g: 172.0, b: 86.0) : .white
            numLB.text = (type <= 20 ? "+" : "-") + " \(num)滴"
            numLB.textColor = color
        }
    }
}
