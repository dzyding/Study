//
//  FootMarkDateHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class FootMarkDateHeaderView: UIView {

    @IBOutlet weak var dateLB: UILabel!
    
    func updateUI(_ date: String) {
        dateLB.text = date
    }
}
