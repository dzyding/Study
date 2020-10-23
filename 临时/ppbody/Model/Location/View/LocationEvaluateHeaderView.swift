//
//  LocationEvaluateHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationEvaluateHeaderView: UIView, InitFromNibEnable {
    
    var handler: (()->())?

    @IBOutlet weak var msgLB: UILabel!
    
    @IBAction func moreAction(_ sender: UIButton) {
        handler?()
    }
    
    func updateUI(_ count: Int) {
        msgLB.text = "共\(count)条评论"
    }
    
}
