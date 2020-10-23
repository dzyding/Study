//
//  TribeProtocolSettingVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/17.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeProtocolSettingVC: BaseVC {
    
    @IBOutlet weak var contentLB: UILabel!
    override func viewDidLoad() {
        self.title = "部落用户管理公约"
        self.contentLB.preferredMaxLayoutWidth = ScreenWidth - 32
        
        self.view.layoutIfNeeded()

    }
}
