//
//  MyGymClassBaseView.swift
//  PPBody
//
//  Created by edz on 2019/4/17.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymClassBaseView: UIView {
    // 所在房间
    @IBOutlet weak var roomLB: UILabel!
    // 教练名字
    @IBOutlet weak var coachNameLB: UILabel!
    // 课程名字
    @IBOutlet weak var classNameLB: UILabel!
    // 预约、取消预约
    @IBOutlet weak var typeLB: UILabel!
    // 预约人数
    @IBOutlet weak var limitLB: UILabel!
    // 时间
    @IBOutlet weak var timeLB: UILabel!
    
    var classData: [String : Any] = [:]
    
    var handler: (([String : Any])->())?
    
    @IBOutlet weak var reserveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reserveBtn.enableInterval = true
    }
    
    @IBAction func clickAction(_ sender: UIButton) {
        handler?(classData)
    }
    
    func updateViews(_ data: [String : Any]) {
        classData = data
        let isReserve = data.intValue("isReserve") ?? 0
        if isReserve == 1 {
            layer.borderWidth = 0.5
            layer.borderColor = YellowMainColor.cgColor
        }else {
            layer.borderWidth = 0.5
            layer.borderColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.1).cgColor
        }   
        roomLB.text         = data.stringValue("spaceName")
        coachNameLB.text    = data.stringValue("coachName")
        classNameLB.text    = data.stringValue("name")
        typeLB.text         = isReserve == 0 ? "预约" : "取消预约"
        timeLB.text         = ToolClass.getTimeStr(data.intValue("start") ?? 0)
        
        if let limit = data.intValue("limit"),
            let num = data.intValue("reserveNum")
        {
            limitLB.text = limit == -1 ? "\(num)" : "\(num)/\(limit)"
        }
    }
}
