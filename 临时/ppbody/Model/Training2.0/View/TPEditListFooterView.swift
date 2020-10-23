//
//  TPEditListFooterView.swift
//  PPBody
//
//  Created by edz on 2019/12/21.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TPEditListFooterView: UIView, InitFromNibEnable {
    
    var handler: (()->())?

    @IBOutlet weak var btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btn.titleLabel?.font = dzy_FontBlod(15)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = YellowMainColor.cgColor
    }
    
    @IBAction func addAction(_ sender: Any) {
        handler?()
    }
}
