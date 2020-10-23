//
//  TopicTagDetailHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicTagDetailHeadView: UICollectionReusableView {
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var endIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var descLB: UILabel!
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var contentLB: UILabel!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    var initData = false
    
    var members = [[String:Any]]()
    
    class func instanceFromNib() -> TopicTagDetailHeadView {
        return UINib(nibName: "TopicTagDetailHeadView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopicTagDetailHeadView
    }
    
    override func awakeFromNib() {
        self.contentLB.isHidden = true
    }
    
    func setData(_ dic: [String:Any]) {
        if dic.isEmpty || initData {
            return
        }
        initData = true
        let cover = dic["cover"] as? String
        if cover != nil && !(cover?.isEmpty)! {
            coverIV.setCoverImageUrl(cover!)
            coverIV.isHidden = false
        }else{
            coverIV.isHidden = true
        }
        endIV.isHidden = dic.intValue("status") != 20
        nameLB.text = dic["name"] as? String
        descLB.text = dic["title"] as? String
        let joinNum = dic["joinNum"] as! Int
        let topicNum = dic["topicNum"] as! Int
        numLB.text = joinNum.compressValue + "人参与 " + topicNum.compressValue +  "条动态"
        let content = dic["content"] as? String
        if content != nil && !(content?.isEmpty)! {
            contentLB.attributedText = ToolClass.rowSpaceText(content!, system: 14)
            contentLB.isHidden = false
        }else{
            contentLB.isHidden = true
        }
    }
    
    @objc func tapHeadAction(_ tap: UITapGestureRecognizer)
    {
        let from = ToolClass.controller2(view: self)
        let tag = tap.view?.tag
        let user = self.members[tag!]
        let vc = PersonalPageVC()
        vc.user = user
        from?.navigationController?.pushViewController(vc, animated: true)
    }
}
