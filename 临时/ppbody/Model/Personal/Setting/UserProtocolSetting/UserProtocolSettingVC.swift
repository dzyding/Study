//
//  UserProtocolSettingVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/17.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
class UserProtocolSettingVC: BaseVC {
    
    @IBOutlet weak var contentLB: UILabel!

    
    override func viewDidLoad() {
        self.title = "用户协议"
        
        self.contentLB.preferredMaxLayoutWidth = ScreenWidth - 32
    }
}
