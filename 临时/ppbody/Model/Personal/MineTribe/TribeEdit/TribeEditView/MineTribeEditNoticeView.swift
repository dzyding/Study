//
//  MineTribeEditNoticeView.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MineTribeEditNoticeView: UIView {
    
    @IBOutlet weak var txtContent: IQTextView!
    @IBOutlet weak var viewContent: UIView!

    override func awakeFromNib() {
        txtContent.placeholder = "请输入部落公告"
    }

    class func instanceFromNib() -> MineTribeEditNoticeView {
        return UINib(nibName: "TribeEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MineTribeEditNoticeView
    }
    
    func getNotice() -> [String: Any]? {
        if txtContent.text.count == 0 {
            ToolClass.showToast("请输入通告", .Failure)
            return nil
        }
        return ["notice": txtContent.text ?? ""]
    }
}
