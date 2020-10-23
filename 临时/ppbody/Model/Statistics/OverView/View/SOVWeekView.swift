//
//  SOVWeekView.swift
//  PPBody
//
//  Created by edz on 2020/1/6.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class SOVWeekView: UIView, InitFromNibEnable {

    @IBOutlet weak var totalNumLB: UILabel!
    
    @IBOutlet weak var changeLB: UILabel!
    
    @IBOutlet weak var totalTimeLB: UILabel!
    
    @IBOutlet weak var totalWeightLB: UILabel!
    
    func initUI(_ dic: [String : Any]) {
        totalNumLB.text = "\(dic.intValue("totalNum") ?? 0)"
        changeLB.text = dic.stringValue("change")
        totalTimeLB.text = "\(dic.intValue("totalTime") ?? 0)"
        totalWeightLB.text = (dic.doubleValue("totalWeight") ?? 0).decimalStr
    }
}
