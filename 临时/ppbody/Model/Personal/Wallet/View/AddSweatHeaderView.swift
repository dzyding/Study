//
//  AddMoneyHeaderView.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class AddSweatHeaderView: UIView {
    
    @IBOutlet weak var sweatLB: UILabel!
    static func initFromNib() -> AddSweatHeaderView {
        let header = Bundle.main.loadNibNamed("AddSweatSubview", owner: self, options: nil)?.first as! AddSweatHeaderView
        header.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 59)
        return header
    }
    
}
