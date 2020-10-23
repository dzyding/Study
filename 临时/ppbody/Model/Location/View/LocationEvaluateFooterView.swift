//
//  LocationEvaluateFooterView.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationEvaluateFooterView: UIView, InitFromNibEnable {
    
    var handler: (()->())?

    @IBOutlet weak var msgLB: UILabel!
    
    @IBAction func moreAction(_ sender: UIButton) {
        handler?()
    }
    
    func updateUI(_ count: Int) {
        msgLB.text = "查看\(count)条评论"
    }
}
