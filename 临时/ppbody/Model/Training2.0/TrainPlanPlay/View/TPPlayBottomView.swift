//
//  TPPlayBottomView.swift
//  PPBody
//
//  Created by edz on 2020/1/14.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TPPlayBottomView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var btn: UIButton!
    
    var handler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btn.titleLabel?.font = dzy_FontBlod(15)
    }

    @IBAction func btnAction(_ sender: Any) {
        handler?()
    }
    
}
