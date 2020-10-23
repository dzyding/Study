//
//  MotionWeightInputView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class MotionWeightInputView: UIView {
    
    @IBOutlet weak var weightTF: UITextField!
    
    var complete: ((String) ->())?

    
    class func instanceFromNib() -> MotionWeightInputView {
        return UINib(nibName: "MotionWeightInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MotionWeightInputView
    }
    
    
    
    override func awakeFromNib() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        
        self.weightTF.becomeFirstResponder()
        self.weightTF.delegate = self

    }
    @IBAction func okAction(_ sender: UIButton) {
        var txt = self.weightTF.text
        
        if txt == "0" || txt == "0."
        {
            self.dismiss()
            return
        }
        
        if txt!.hasSuffix(".")
        {
           txt = txt?.replacingOccurrences(of: ".", with: "")
        }
        
        self.complete?(txt!)
        
        self.dismiss()
    }
    
    @objc func dismiss()
    {
        self.removeFromSuperview()
    }
}

extension MotionWeightInputView:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var origin = textField.text ?? ""
        let isHaveDian = origin.contains(".")
        if string.count > 0 {
            let temp = CharacterSet(charactersIn: "0123456789.")
            if string.rangeOfCharacter(from: temp) != nil {
               //输入是数字和点
                //只能有一个小数点
                if isHaveDian && string == "." {
                    return false
                }
                //如果第一位是. 则后面加上0
                if origin.count == 0 && string == "." {
                    textField.text = "0"
                    origin = "0"
                    return true
                }
                //第一位是0 后面必须是点
                if origin == "0" && string != "." {
                    return false
                }
                // 只能是一位小数
                if isHaveDian,
                    let randian = origin.range(of: "."),
                    range.location > origin.toNSRange(randian).location
                {
                    let arr = origin.components(separatedBy: ".")
                    if arr[1].count > 0
                    {
                        return false
                    }
                }
                var newText = (origin as NSString).replacingCharacters(in: range, with: string) as String
                if newText.hasSuffix(".")
                {
                    newText = newText.replacingOccurrences(of: ".", with: "")
                }
                let floatNum = Float(newText)
                if floatNum! > 1000 {
                    return false
                }
            }else{
                return false
            }
        }
        return true
    }
    
}
