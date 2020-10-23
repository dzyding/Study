//
//  LocationRCUserInfoView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpRCUserInfoView: UIView, InitFromNibEnable, AttPriceProtocol {
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var memoTF: UITextField!
    
    func initUI() {
        nameTF.attributedPlaceholder = getPlaceHolder("请输入您的姓名")
        memoTF.attributedPlaceholder = getPlaceHolder("可填写附加要求，我们会尽快安排")
    }
    
    private func getPlaceHolder(_ str: String) -> NSAttributedString {
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.2)
        let attPlaceHolder = NSAttributedString(
            string: str,
            attributes: [
                NSAttributedString.Key.font : dzy_Font(14),
                NSAttributedString.Key.foregroundColor : color
        ])
        return attPlaceHolder
    }
}
