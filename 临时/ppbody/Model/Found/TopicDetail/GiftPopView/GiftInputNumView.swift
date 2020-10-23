//
//  GiftInputNumView.swift
//  PPBody
//
//  Created by edz on 2018/12/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class GiftInputNumView: UIView {

    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
    var handler: ((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = RGB(r: 250.0, g: 250.0, b: 250.0).cgColor
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        sureBtn.layer.cornerRadius = 2
        sureBtn.layer.masksToBounds = true
        
        inputTF.setPlaceholderColor(.gray)
//        inputTF.delegate = self
        inputTF.keyboardAppearance = .dark
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        inputTF.resignFirstResponder()
        if let text = inputTF.text, text.count > 0 {
            handler?(text)
        }else {
            handler?("1")
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension GiftInputNumView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if text.count > 0 && range.location == 0 {
                // 不可用
            }else {
                // 可用
            }
        }
        return true
    }
}
