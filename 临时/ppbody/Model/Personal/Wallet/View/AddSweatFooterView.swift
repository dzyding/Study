//
//  AddMoneyFooterView.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class AddSweatFooterView: UIView {
    
    var proHandler: (()->())?

    static func initFromNib() -> AddSweatFooterView {
        let footer = Bundle.main.loadNibNamed("AddSweatSubview", owner: self, options: nil)?.last as! AddSweatFooterView
        footer.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 100)
        return footer
    }

    @IBAction func protocolAction(_ sender: Any) {
        proHandler?()
    }
}
