//
//  CoachMemberHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachMemberHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    var handler: (()->())?
    
    func updateUI(_ data: [String : Any]) {
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        nameLB.text = data.stringValue("realname")
        numLB.text = "\(data.intValue("classNum") ?? 0)"
    }
    
    @IBAction private func btnAction(_ sender: UIButton) {
        handler?()
    }
}
