//
//  MessageChatVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/11/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MessageChatVC: RCConversationViewController {
    
    var userInfo:[String:Any]?
    
    override func didTapCellPortrait(_ userId: String!) {
        
        if userId == self.targetId, Int(userId) != nil  {
            let vc = PersonalPageVC()
            vc.user = userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
