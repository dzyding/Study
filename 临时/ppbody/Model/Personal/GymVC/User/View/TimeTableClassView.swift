//
//  TimeTableClassView.swift
//  PPBody
//
//  Created by edz on 2019/4/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol TimeTableClassViewDelegate {
    func classView(_ classView: TimeTableClassView, didSelected btn: UIButton)
}

class TimeTableClassView: UIView {
    
    @IBOutlet weak var limitLB: UILabel!
    
    @IBOutlet weak var coachLB: UILabel!
    
    @IBOutlet weak var classLB: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var selBtn: UIButton!
    
    @IBOutlet weak var reservedIV: UIImageView!
    weak var delegate: TimeTableClassViewDelegate?
    // 课程数据
    var data: [String : Any] = [:]
    // 星期几
    var week: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selBtn.enableInterval = true
    }

    @IBAction func clickAction(_ sender: UIButton) {
        delegate?.classView(self, didSelected: sender)
    }
    
    // 更新视图
    func updateViews(_ data: [String : Any], week: Int, color: UIColor) {
        self.data = data
        self.week = week
        // 今天星期几
        var today = dzy_weekNum(Date())
        today = today == 1 ? 7 : today - 1
        let x = today <= week ? (week - today) : (week + 7 - today)
        if x > 2 {
            let gray = dzy_HexColor(0x747474)
            colorView.backgroundColor = dzy_HexColor(0xC8C8C8)
            selBtn.isUserInteractionEnabled = false
            coachLB.textColor = gray
            classLB.textColor = gray
            limitLB.textColor = gray
        }else {
            selBtn.isUserInteractionEnabled = true
            colorView.backgroundColor = color
            let white = UIColor.white
            coachLB.textColor = white
            classLB.textColor = white
            limitLB.textColor = white
        }
        let reserved = data.intValue("isReserve") ?? 0
        coachLB.text = data.stringValue("coachName")
        classLB.text = data.stringValue("name")
        reservedIV.isHidden = reserved != 1
        if let limit = data.intValue("limit"),
            let num = data.intValue("reserveNum")
        {
            limitLB.text = limit == -1 ? "\(num)" : "\(num)/\(limit)"
        }
    }
    
    // 预约完成以后的操作
    func reserveClassEnd() {
        let type  = data.intValue("isReserve") ?? 0
        let num   = data.intValue("reserveNum") ?? 0
        let limit = data.intValue("limit") ?? -1
        let result = type == 0 ? num + 1 : num - 1
        DispatchQueue.main.async {
            ToolClass.showToast(type == 0 ? "预约成功" : "取消预约成功", .Success)
            self.data.updateValue(result, forKey: "reserveNum")
            self.data.updateValue(type == 0 ? 1 : 0, forKey: "isReserve")
            self.reservedIV.isHidden = type != 0 //这个地方时旧数据，所以是反的
            self.limitLB.text = limit == -1 ? "\(result)" : "\(result)/\(limit)"
        }
    }

}
