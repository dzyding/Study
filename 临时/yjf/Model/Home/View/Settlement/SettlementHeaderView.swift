//
//  SettlementHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SettlementHeaderView: UIView {
    
    @IBOutlet weak var priceLB: UILabel!
    
    func updateUI(_ str: String?) {
        priceLB.text = str
    }
}
