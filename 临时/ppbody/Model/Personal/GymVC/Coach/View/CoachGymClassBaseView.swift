//
//  CoachGymClassBaseView.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachGymClassBaseView: UIView {
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var reduceBtn: UIButton!
    
    private var classData: [String : Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        classData = data
        nameLB.text = data.stringValue("realname") ?? " "
        let start = data.intValue("start") ?? 0
        let end   = data.intValue("end") ?? 0
        timeLB.text = ToolClass.getTimeStr(start) + " ~ " + ToolClass.getTimeStr(end)
        let isReduce = data.intValue("isReduce") ?? 0
        reduceBtn.setTitle(isReduce == 0 ? "未核销" : "已核销", for: .normal)
        if isReduce == 0 {
            layer.borderWidth = 0.5
            layer.borderColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.1).cgColor
        }else {
            layer.borderWidth = 0.5
            layer.borderColor = YellowMainColor.cgColor
        }
    }
}
