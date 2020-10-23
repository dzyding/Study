//
//  CommentViewCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class CommentViewCell: UITableViewCell{
    
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var supportBtn: FaveButton!
    @IBOutlet weak var supportNumLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var oweLB: UILabel!
    
    var indexPath:IndexPath!
    
    var delegate:TopicCommentActionDelegate?
    
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
    
    func setData(_ dic:[String:Any], indexPath:IndexPath,  uid: String)
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
        
        
        self.timeLB.text = ToolClass.compareCurrentTime(date: dic["createTime"] as! String)
     }
}
