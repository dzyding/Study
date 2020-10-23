//
//  CoachSettingTimeView.swift
//  PPBody
//
//  Created by edz on 2019/5/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachSettingTimeView: UIView {

    @IBOutlet weak var timeLB: UILabel!
    
    func updateUI(time: (Int, Int)) {
        let sTime = ToolClass.getTimeStr(time.0)
        let eTime = ToolClass.getTimeStr(time.1)
        timeLB.text = sTime + "-" + eTime
    }
}
