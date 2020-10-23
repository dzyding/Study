//
//  MessageListTwoLinkCell.swift
//  YJF
//
//  Created by edz on 2019/10/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol MessageListTwoLinkCellDelegate: class {
    func twoLinkCell(_ cell: MessageListTwoLinkCell, didClickTopLinkWithBtn btn: UIButton)
    func twoLinkCell(_ cell: MessageListTwoLinkCell, didClickBottomLinkWithBtn btn: UIButton)
}

class MessageListTwoLinkCell: UITableViewCell {
    
    weak var delegate: MessageListTwoLinkCellDelegate?

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var bottomLinkLB: UILabel!
    
    @IBOutlet weak var topLinkLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI(_ msg: [String : Any]) {
        let skipType = msg.intValue("skipType") ?? 0
        titleLB.text = msg.stringValue("title")
        timeLB.text = MessageHelper.time(msg.stringValue("createTime"))
        let content = msg.stringValue("content") ?? ""
        var attStr = DzyAttributeString()
        attStr.str = content
        attStr.font = dzy_Font(13)
        attStr.color = dzy_HexColor(0xa3a3a3)
        attStr.lineSpace = defaultLineSpace
        msgLB.attributedText = attStr.create()
        if skipType == 63 {
            topLinkLB.text = "修改房源"
            bottomLinkLB.text = "添加报价"
        }else if skipType == 64 {
            topLinkLB.text = "缴纳交易保证金"
            bottomLinkLB.text = "申请装锁"
        }
        
    }
    
    @IBAction func bottomLinkAction(_ sender: UIButton) {
        delegate?.twoLinkCell(self, didClickBottomLinkWithBtn: sender)
    }
    
    @IBAction func topLinkAction(_ sender: UIButton) {
        delegate?.twoLinkCell(self, didClickTopLinkWithBtn: sender)
    }
}
