//
//  HotFoundCellUIProtocol.swift
//  PPBody
//
//  Created by dingzhiyuan on 2020/7/22.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import Foundation

public protocol HotFoundCellUIProtocol: class {
    var p_nameLB: UILabel? {get}
    var p_briefLB: UILabel? {get}
    var p_logoIV: UIImageView? {get}
    var p_contentLB: UILabel? {get}
    var p_lookNumLB: UILabel? {get}
    var p_commentLB: UILabel? {get}
    var p_topCommentLB: UILabel? {get}
    var p_bottomCommentLB: UILabel? {get}
    var p_commentHLC: NSLayoutConstraint? {get}
    
    func baseUpdateUI(_ dic: [String : Any])
}

extension HotFoundCellUIProtocol {
    
    func baseUpdateUI(_ dic: [String : Any]) {
        let user = dic.dicValue("user")
        p_nameLB?.text = user?.stringValue("nickname") ?? user?.stringValue("realname")
        p_briefLB?.text = user?.stringValue("brief")
        p_logoIV?.setHeadImageUrl(user?.stringValue("head"))
        
        p_contentLB?.text = dic.stringValue("content")
        p_lookNumLB?.text = "0人浏览"
        
        let commentNum = dic.intValue("commentNum") ?? 0
        p_commentLB?.text = "共\(commentNum)条评论"
        let commentArr = dic.arrValue("comments") ?? []
        if commentArr.count >= 2 {
            p_commentHLC?.constant = 80
            updateLB(p_topCommentLB, dic: commentArr[0])
            updateLB(p_bottomCommentLB, dic: commentArr[1])
        }else if commentArr.count == 1 {
            p_commentHLC?.constant = 50
            updateLB(p_topCommentLB, dic: commentArr[0])
            p_bottomCommentLB?.text = nil
        }else {
            p_commentHLC?.constant = 0
            p_topCommentLB?.text = nil
            p_bottomCommentLB?.text = nil
        }
    }
    
    private func updateLB(_ lb: UILabel?, dic: [String : Any]) {
        let name = dic.stringValue("userName") ?? ""
        if let _ = dic.dicValue("gift") {
            lb?.text = "\(name)：赠送了礼物"
        }else {
            lb?.text = "\(name)：" + (dic.stringValue("content") ?? "")
        }
    }
}
