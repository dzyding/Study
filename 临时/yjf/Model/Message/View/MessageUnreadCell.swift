//
//  MessageUnreadCell.swift
//  YJF
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MessageUnreadCell: UITableViewCell, CzzdMsgProtocol {
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var infoLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        titleLB.text = data.stringValue("title")
        timeLB.text = MessageHelper.time(data.stringValue("createTime"))
        if let content = czzdShowMsg(data) {
            var attStr = DzyAttributeString()
            attStr.str = content
            attStr.color = dzy_HexColor(0xa3a3a3)
            attStr.font  = dzy_Font(11)
            attStr.lineSpace = defaultLineSpace
            infoLB.attributedText = attStr.create()
            infoLB.lineBreakMode = .byTruncatingTail
        }else {
            infoLB.attributedText = nil
        }
    }
}
