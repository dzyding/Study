//
//  MessageVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MessageVC: RCConversationListViewController {

    lazy var head = MessageHead.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackWhiteItem()
        title = "消息中心"
        view.backgroundColor = BackgroundColor
        conversationListTableView.tableHeaderView = head
        ininStyle()
        setDisplayConversationTypes([
            RCConversationType
                .ConversationType_PRIVATE.rawValue,
            RCConversationType
                .ConversationType_DISCUSSION.rawValue,
            RCConversationType
                .ConversationType_CHATROOM.rawValue,
            RCConversationType
                .ConversationType_GROUP.rawValue,
            RCConversationType
                .ConversationType_APPSERVICE.rawValue,
            RCConversationType
                .ConversationType_SYSTEM.rawValue
        ])
        setCollectionConversationType([
            RCConversationType.ConversationType_SYSTEM.rawValue
        ])
    }
    
    func ininStyle(){
        conversationListTableView.separatorColor = ColorLine
        conversationListTableView.tableFooterView = UIView()
        conversationListTableView.backgroundColor = BackgroundColor
        cellBackgroundColor = BackgroundColor
        
        topCellBackgroundColor = BackgroundColor
//        self.emptyConversationView = UIImageView(image: UIImage(named: "common_empty"))
        emptyConversationView = UIView()
    }
    
    func setBackWhiteItem() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_n")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_n")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        head.getMessageNotify()
        let user = DataManager.userInfo()
        let userId = ToolClass
            .decryptUserId(DataManager.userAuth())
        let groupNotify = RCUserInfo(userId: "\(userId!)",
            name: user!["nickname"] as? String,
            portrait: user!["head"] as? String)
        RCIM.shared().refreshUserInfoCache(groupNotify, withUserId: "\(userId!)")
    }
    
    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        if model.unreadMessageCount > 0 {
            NotificationCenter.default.post(
            name: Config.Notify_ClearMessage,
            object: nil)
        }
        let conversationVC = MessageChatVC()
        conversationVC.conversationType = model.conversationType
        conversationVC.targetId = model.targetId
        conversationVC.title = model.conversationTitle
        conversationVC.hbd_barTintColor = BackgroundColor
        conversationVC.hbd_barHidden = false
        
        if let userId = Int(model!.targetId),
            let resultId = ToolClass.encryptUserId(userId)
        {
            conversationVC.userInfo = [
                "uid" : resultId,
                "nickname" : model.conversationTitle ?? ""
            ]
        }
        conversationVC.view.backgroundColor = BackgroundColor
        navigationController?
            .pushViewController(conversationVC, animated: true)
        
    }
    

    override func willDisplayConversationTableCell(_ cell: RCConversationBaseCell!, at indexPath: IndexPath!) {
        if let conversionCell = cell as? RCConversationCell
        {
            conversionCell.conversationTitle.textColor = UIColor.white
            conversionCell.messageContentLabel.textColor = Text1Color
            conversionCell.selectionStyle = .none
            conversionCell.backgroundColor = BackgroundColor
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}


