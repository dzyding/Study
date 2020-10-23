//
//  MotionCardioInputView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MotionCardioInputView: UIView {
    
    @IBOutlet weak var timeTF: UITextField!
    
     var complete: ((Int) ->())?
    
    class func instanceFromNib() -> MotionCardioInputView {
        return UINib(nibName: "MotionCardioInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MotionCardioInputView
    }
    
    override func awakeFromNib() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        
        self.timeTF.becomeFirstResponder()
        self.timeTF.delegate = self
        
    }
    
    
    @IBAction func okAction(_ sender: UIButton) {
        let txt = self.timeTF.text
        
        if txt == "0"
        {
            self.dismiss()
            return
        }
        
        
        self.complete?(Int(txt!)!)
        
        self.dismiss()
    }
    
    @objc func dismiss()
    {
        self.removeFromSuperview()
    }
}

extension MotionCardioInputView:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let origin = textField.text!
    
        
        if string.count > 0
        {
            let temp = CharacterSet(charactersIn: "0123456789")
            if string.rangeOfCharacter(from: temp) != nil
            {

                let newText = (origin as NSString).replacingCharacters(in: range, with: string) as String
                let floatNum = Float(newText)
                if floatNum! > 1000
                {
                    return false
                }
                
            }else{
                return false
            }
            
        }
        
        
        return true
        
    }
    
}
