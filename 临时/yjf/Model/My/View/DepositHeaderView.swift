//
//  DepositHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DepositHeaderView: UIView {

    @IBOutlet weak var titleLB: UILabel!
    
    func updateUI(_ title: String) {
        titleLB.text = title
    }
    
}
