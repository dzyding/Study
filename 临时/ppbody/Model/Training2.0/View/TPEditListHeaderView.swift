//
//  TPEditListHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/12/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TPEditListHeaderView: UIView, InitFromNibEnable {

    @IBOutlet weak var titleLB: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLB.font = dzy_FontBlod(18)
    }
}
