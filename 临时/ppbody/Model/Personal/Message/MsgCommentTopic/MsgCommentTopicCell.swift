//
//  MsgCommentTopicCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MsgCommentTopicCell: UITableViewCell {
    
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var coverIV: UIImageView!
    
    var uid:String?
    
    override func awakeFromNib() {
        self.headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(personalDetailAction)))
    }
    
    @objc func personalDetailAction()
    {
        if self.uid != nil
        {
            let fromVC = ToolClass.controller2(view: self)
            
            let vc = PersonalPageVC()
            vc.uid = self.uid
            fromVC?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func setData(_ dic: [String:Any])
    {
        let user = dic["user"] as! [String:Any]
        self.uid = user["uid"] as? String

        self.headIV.setHeadImageUrl(user["head"] as! String)
        self.nameLB.text = user["nickname"] as? String
        
        let type = dic["type"] as! Int
        
        if type == 10
        {
            //评论
            self.typeLB.text = "评论了你的作品"
        }else{
            //回复
            self.typeLB.text = "回复了你的评论"
        }
        
        self.timeLB.text = ToolClass.compareCurrentTime(date: dic["createTime"] as! String)
        
        let topic = dic["topic"] as! [String:Any]
        
        self.coverIV.setCoverImageUrl(topic["cover"] as! String)
        self.titleLB.text = dic["content"] as? String
    }
    
    
}
