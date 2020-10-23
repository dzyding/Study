//
//  MyMotionAddView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MyMotionAddView: UIView {

    @IBOutlet weak var txtMotionName: UITextField!
    @IBOutlet weak var txtDesc: IQTextView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var nameBgView: UIView!
    
    class func instanceFromNib() -> MyMotionAddView {
        return UINib(nibName: "MyMotionAddView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MyMotionAddView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameBgView.layer.borderColor = YellowMainColor.cgColor
        nameBgView.layer.borderWidth = 1.0
        txtMotionName.delegate = self
        
        txtDesc.placeholder = "请输入该动作要点..."
        
        txtMotionName.setPlaceholderColor(Text1Color)
    }
    
    func initForPlan()
    {
        self.lblTitle.text = "计划描述（必填）"
        self.txtDesc.placeholder = "请输入计划描述3-32字"
        self.txtMotionName.placeholder = "请输入计划名称"
    }
    
    func setData(_ dic:[String:Any], type: Int)
    {
        self.txtMotionName.text = dic["name"] as? String
        self.txtDesc.text = dic[type == 10 ? "actionPoint" : "content"] as? String
    }
    
    func getInfo(_ type: Int)->[String:String]?
    {
        if (self.txtMotionName.text?.isEmpty)!
        {
            ToolClass.showToast(type == 10 ? "请输入要创建的动作名称" : "请输入计划的名称", .Failure)
            return nil
        }
        
        if self.txtDesc.text.isEmpty
        {
            ToolClass.showToast(type == 10 ? "请输入动作要点" : "请输入计划的描述", .Failure)
            return nil
        }
        
        return [
            "name" : self.txtMotionName.text!,
            type == 10 ? "actionPoint" : "content"
                : self.txtDesc.text]
    }
    
    
    @objc func textDidChange(sender: UITextField)
    {
        
    }
    

}

extension MyMotionAddView:UITextFieldDelegate
{
    func  textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String) ->Bool{
        
        if  (textField.text?.count)!>16{
            return  false
        }else{
            return  true
        }
    }
}
