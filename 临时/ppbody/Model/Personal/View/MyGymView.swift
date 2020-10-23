//
//  MyGymView.swift
//  PPBody
//
//  Created by edz on 2019/4/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol MyGymViewDelegate {
    func gymView(_ gymView: MyGymView, didSelected btn: UIButton)
}

class MyGymView: UIView {
    
    weak var delegate: MyGymViewDelegate?
    
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightLC.constant = dzy_imgHeight(
            "my_gym",
            width: ScreenWidth - 32.0)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        delegate?.gymView(self, didSelected: sender)
    }
}
