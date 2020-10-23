//
//  MineTribeDetailNoticeView.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MineTribeDetailNoticeView: UIView {

    @IBOutlet weak var lblContent: UILabel!

    
    func setData(_ dic:[String:Any])
    {
        let notice = dic["notice"] as! String
        if notice.isEmpty
        {
            self.lblContent.text = "暂无信息展示"
        }else{
             self.lblContent.attributedText = ToolClass.rowSpaceText(notice, system: 14)
        }
    }
    
    class func instanceFromNib() -> MineTribeDetailNoticeView {
        return UINib(nibName: "MineTribeDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! MineTribeDetailNoticeView
    }
}
