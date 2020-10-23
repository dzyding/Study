//
//  MessageHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/12.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MessageHead: UIView {
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followNumLB: UILabel!
    @IBOutlet weak var supportNumLB: UILabel!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var directView: UIView!
    @IBOutlet weak var directNumLB: UILabel!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentNumLB: UILabel!
    
    class func instanceFromNib() -> MessageHead {
        return UINib(nibName: "MessageHead", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageHead
    }
    
    override func awakeFromNib() {
        self.followView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(followAction)))
        self.supportView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(supportAction)))
        self.directView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(directAction)))
        self.commentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentAction)))
    }
    
    func refreshNoRead() {
        if let message = DataManager.messageNotify() {
            if let followNum = message.intValue("followNum"), followNum > 0 {
                self.followNumLB.isHidden = false
                self.followNumLB.text = "\(followNum)"
            }else{
                self.followNumLB.isHidden = true
            }
            
            if let topicSupportNum = message.intValue("topicSupportNum"), topicSupportNum > 0 {
                self.supportNumLB.isHidden = false
                self.supportNumLB.text = "\(topicSupportNum)"
            }else{
                self.supportNumLB.isHidden = true
            }
            
            if let topicDirectNum = message.intValue("topicDirectNum"), topicDirectNum > 0 {
                self.directNumLB.isHidden = false
                self.directNumLB.text = "\(topicDirectNum)"
            }else{
                self.directNumLB.isHidden = true
            }
            
            if let topicCommentNum = message.intValue("topicCommentNum"), topicCommentNum > 0 {
                self.commentNumLB.isHidden = false
                self.commentNumLB.text = "\(topicCommentNum)"
            }else{
                self.commentNumLB.isHidden = true
            }
        }
    }
    
    @objc func followAction() {
        let from = ToolClass.controller2(view: self)
        let vc = MsgAttentionVC()
        vc.hbd_barAlpha = 0
        from?.navigationController?.pushViewController(vc, animated: true)
        self.clearMessageNotify(10)
    }
    
    @objc func supportAction() {
        let from = ToolClass.controller2(view: self)
        let vc = MsgSupportTopicVC()
        vc.hbd_barAlpha = 0
        from?.navigationController?.pushViewController(vc, animated: true)
        self.clearMessageNotify(20)
    }
    
    @objc func directAction() {
        let from = ToolClass.controller2(view: self)
        let vc = MsgDirectTopicVC()
        vc.hbd_barAlpha = 0
        from?.navigationController?.pushViewController(vc, animated: true)
        self.clearMessageNotify(30)
    }
    
    @objc func commentAction() {
        let from = ToolClass.controller2(view: self)
        let vc = MsgCommentTopicVC()
        vc.hbd_barAlpha = 0
        from?.navigationController?.pushViewController(vc, animated: true)
        self.clearMessageNotify(40)
    }
    
    //获取未读消息通知
    func getMessageNotify() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MessageNotify
        request.start { (data, error) in
            guard error == nil else {
                return
            }
            if let msgNum = data?.dicValue("msgNum") {
                DataManager.saveMessageNotify(msgNum)
                self.refreshNoRead()
            }
        }
    }
    
    //清除消息通知
    func clearMessageNotify(_ type: Int) {
        let request = BaseRequest()
        request.dic = ["type": "\(type)"]
        request.isUser = true
        request.url = BaseURL.MsgClearNotify
        request.start { (data, error) in
            guard error == nil else {
                return
            }
            if data != nil {
                NotificationCenter.default.post(
                    name: Config.Notify_ClearMessage,
                    object: nil)
            }
        }
    }
}
