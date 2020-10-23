//
//  MessageListInfoCell.swift
//  YJF
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MessageListInfoCell: UITableViewCell, CzzdMsgProtocol {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet private weak var infoLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ msg: [String : Any]) {
        timeLB.text = MessageHelper.time(msg.stringValue("createTime"))
        titleLB.text = msg.stringValue("title")
        if let content = czzdShowMsg(msg) {
            var attStr = DzyAttributeString()
            attStr.str = content
            attStr.font = dzy_Font(13)
            attStr.color = dzy_HexColor(0xa3a3a3)
            attStr.lineSpace = defaultLineSpace
            infoLB.attributedText = attStr.create()
        }else {
            infoLB.attributedText = nil
        }
    }
    
}
