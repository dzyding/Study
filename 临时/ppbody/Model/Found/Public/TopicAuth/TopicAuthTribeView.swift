//
//  TopicAuthTribeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicAuthTribeView: UIView
{
    @IBOutlet weak var tribeBtn: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    
    var ctid: String?
    
    class func instanceFromNib() -> TopicAuthTribeView {
        return UINib(nibName: "TopicAuthTribeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopicAuthTribeView
    }
    
    func setData(_ dic:[String:Any])
    {
        self.nameLB.text = dic["name"] as? String
        self.ctid = dic["ctid"] as? String
    }
}
