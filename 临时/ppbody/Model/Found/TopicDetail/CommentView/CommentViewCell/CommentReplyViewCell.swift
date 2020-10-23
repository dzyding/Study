//
//  CommentReplyViewCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


class CommentReplyViewCell: UITableViewCell{
    
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var supportBtn: FaveButton!
    @IBOutlet weak var supportNumLB: UILabel!
    
    @IBOutlet weak var replyNameLB: UILabel!
    @IBOutlet weak var replyContentLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var oweLB: UILabel!
    @IBOutlet weak var replyOweLB: UILabel!
    
    var indexPath:IndexPath!
    
    weak var delegate:TopicCommentActionDelegate?
    
    override func awakeFromNib() {
        self.headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHead)))
    }
    
    @objc func tapHead()
    {
        self.delegate?.tapHeadForIndex(self.indexPath)
    }

    @IBAction func supportAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var supportNum = Int(self.supportNumLB.text!)!
        
        if sender.isSelected
        {
            supportNum += 1
        }else{
            supportNum -= 1
        }
        
        self.supportNumLB.text = "\(supportNum)"
        
        self.delegate?.supportComment(self, isSelect: sender.isSelected, indexPath: self.indexPath)

    }
    
    func setData(_ dic:[String:Any], indexPath:IndexPath, uid: String)
    {
        let user = dic["user"] as! [String:Any]
        
        self.indexPath = indexPath
        
        self.headIV.setHeadImageUrl(user["head"] as! String)
        self.nameLB.text = user["nickname"] as? String
        self.contentLB.text = dic["content"] as? String
        
        self.supportNumLB.text = "\(dic["supportNum"] as! Int)"
        let support = dic["isSupport"] as? Int
        if support != nil
        {
            self.supportBtn.isSelected = support == 1 ? true : false
        }
        
        let own = dic["author"] as? Int
        
        if own != nil && own == 1
        {
            self.oweLB.isHidden = false
        }else{
            self.oweLB.isHidden = true
        }
        
        let reply = dic["reply"] as! [String:Any]
        let originUser = reply["user"] as! [String:Any]
        self.replyNameLB.text = "@" + (originUser["nickname"] as! String)
        self.replyContentLB.text = reply["content"] as? String
        
        let replyOwn = reply["author"] as? Int
        
        if replyOwn != nil && replyOwn == 1
        {
            self.replyOweLB.isHidden = false
        }else{
            self.replyOweLB.isHidden = true
        }
        
        self.timeLB.text = ToolClass.compareCurrentTime(date: dic["createTime"] as! String)
    }
}
