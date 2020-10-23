//
//  AddPlanMsgView.swift
//  PPBody
//
//  Created by edz on 2019/12/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class AddPlanMsgView: UIView, InitFromNibEnable {

    @IBOutlet weak var titleTF: UITextField!
    
    @IBOutlet weak var inputTX: IQTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.35)
        titleTF.setPlaceholderColor(color)
    }
    
    func msg() -> [String : String]? {
        guard let title = titleTF.text, title.count > 0 else {
            ToolClass.showToast("请输入计划的名称", .Failure)
            return nil
        }
        guard let msg = inputTX.text, msg.count > 0 else {
            ToolClass.showToast("请输入计划的描述", .Failure)
            return nil
        }
        return ["name" : title, "content" : msg]
    }
}
