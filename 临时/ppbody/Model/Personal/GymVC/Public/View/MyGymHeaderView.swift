//
//  MyGymHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymHeaderView: UIView {
    
    @IBOutlet weak var coverIV: UIImageView!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var valueFrontLB: UILabel!
    
    @IBOutlet weak var valueBehindLB: UILabel!
    
    private var handler: (()->())?
    
    func userSetUI(_ club: [String : Any],
                   num: Int,
                   handler:@escaping () -> ()) {
        self.handler = handler
        coverIV.setCoverImageUrl(club.stringValue("cover") ?? "")
        iconIV.setCoverImageUrl(club.stringValue("logo") ?? "")
        nameLB.text = club.stringValue("name")
        valueFrontLB.text = "打卡"
        numLB.text = "\(num)"
        valueBehindLB.text = "次"
    }

    func ptSetUI(_ club: [String : Any],
                 num: Int,
                 handler:@escaping () -> ()) {
        self.handler = handler
        coverIV.setCoverImageUrl(club.stringValue("cover") ?? "")
        iconIV.setCoverImageUrl(club.stringValue("logo") ?? "")
        nameLB.text = club.stringValue("name")
        valueFrontLB.text = "会员"
        numLB.text = "\(num)"
        valueBehindLB.text = "人"
    }
    
    @IBAction private func clickAction(_ sender: UIButton) {
        handler?()
    }
}
