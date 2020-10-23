//
//  MessageListLinkCell.swift
//  YJF
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol MessageListLinkCellDelegate: class {
    func messageCell(_ cell: MessageListLinkCell, didClickJumpBtn btn: UIButton)
}

class MessageListLinkCell: UITableViewCell, CzzdMsgProtocol {
    
    private let twoDepositKey = "【缴纳交易保证金】"
    
    private let twoLockKey = "【申请装锁】"
    
    weak var delegate: MessageListLinkCellDelegate?

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var infoLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ msg: [String : Any]) {
        titleLB.text = msg.stringValue("title")
        timeLB.text = MessageHelper.time(msg.stringValue("createTime"))
        if let content = czzdShowMsg(msg) {
            var attStr = DzyAttributeString()
            attStr.str = content
            attStr.font = dzy_Font(13)
            attStr.color = dzy_HexColor(0xa3a3a3)
            attStr.lineSpace = defaultLineSpace
            infoLB.attributedText = attStr.create()
            
            let skipType = msg.intValue("skipType") ?? 0
            if skipType == 6 {
                msgLB.text = "前往评价"
            }
            if [25, 33, 29].contains(skipType) {
                msgLB.text = "缴纳交易保证金"
            }
            if skipType == 45 {
                msgLB.text = "交易进展"
            }
            if (skipType == 57 || skipType == 62),
                let parameList = msg.stringValue("parameList"),
                let type = MessageHelper
                    .openParameList(parameList).stringValue("urlType")
            {
                msgLB.text = czzdGetTypeMsg(type)
            }
            if skipType == 64 {
                if content.contains(twoDepositKey) {
                    msgLB.text = "缴纳交易保证金"
                }else if content.contains(twoLockKey) {
                    msgLB.text = "申请装锁"
                }
            }
        }else {
            msgLB.text = nil
            infoLB.attributedText = nil
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        delegate?.messageCell(self, didClickJumpBtn: sender)
    }
}
