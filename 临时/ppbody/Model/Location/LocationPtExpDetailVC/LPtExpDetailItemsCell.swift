//
//  LPtExpDetailItemsCell.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpDetailItemsCell: UIView, InitFromNibEnable {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var infoLB: UILabel!
    
    func updateUI(_ data: [String : Any]) {
        titleLB.text = data.stringValue("title")
        infoLB.text = data.stringValue("content")
    }
}
