//
//  MyMotionTrainKeyView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MyMotionTrainKeyView: UIView {
    @IBOutlet weak var txtDesc: IQTextView!
        
    
    override func awakeFromNib() {
        txtDesc.placeholder = "请输入该动作的训练重点..."
        if let placeholder = txtDesc.placeholder,
            let font = txtDesc.font
        {
            txtDesc.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : Text1Color
            ])
        }
    }
    
    func setData(_ dic:[String:Any])
    {
        self.txtDesc.text = dic["trainingCore"] as? String
    }
    
    func getInfo()->[String:Any]?
    {
        if txtDesc.text.isEmpty
        {
            ToolClass.showToast("请输入训练重点", .Failure)
            return nil
        }
        
        return ["trainingCore" : txtDesc.text ?? ""]
    }
    
    class func instanceFromNib() -> MyMotionTrainKeyView {
        return UINib(nibName: "MyMotionAddView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! MyMotionTrainKeyView
    }

}
