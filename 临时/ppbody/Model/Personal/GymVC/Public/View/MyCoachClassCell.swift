//
//  MyCoachClassCell.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol MyCoachClassCellDelegate {
    func classCell(_ classCell: MyCoachClassCell, didSelectDelBtn btn: UIButton, reserveId: Int, mid: String)
    func classCell(_ classCell: MyCoachClassCell, didSelectQrCodeBtn btn: UIButton, code: String)
}

class MyCoachClassCell: UITableViewCell {
    
    weak var delegate: MyCoachClassCellDelegate?

    @IBOutlet weak var topLine: UIView!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var timeLineLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var cancelMsgLB: UILabel!
    
    @IBOutlet weak var delBtn: UIButton!
    
    @IBOutlet weak var qrView: UIView!
    
    @IBOutlet weak var trailLC: NSLayoutConstraint!
    
    // 当前预约 Cell 对应的 ID
    private var reserveId: Int = 0
    // 当前预约 Cell 对应的 smid
    private var mid: String = ""
    // 核销code
    private var code: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func userUpdateUI(_ data: [String : Any], cancelTime: Int, ifToday: Bool) {
        reserveId = data.intValue("id") ?? 0
        let start = data.intValue("start") ?? 0
        let end   = data.intValue("end") ?? 0
        let own   = data.intValue("own") ?? 0
        // 10 为学员约的课
        let type   = data.intValue("type") ?? 0

        timeLineLB.text = start >= 720 ? "pm" : "am"
        timeLB.text     = "\(ToolClass.getTimeStr(start))" + "-" + "\(ToolClass.getTimeStr(end))"
        nameLB.text     = data.stringValue("nickname") ?? "暂无"
        cancelMsgLB.text = "(取消预约请在开课前\(cancelTime)小时)"
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        cancelMsgLB.isHidden = own != 1
        code = data.stringValue("code")
        qrView.isHidden = data.stringValue("code") == nil

        let times = dzy_date8().description.components(separatedBy: " ")
        guard times.count == 3 else {return}
        // 自己的课，以及是会员方约的课，才判断是否可以取消
        let canDel = own == 1 && type == 10
        if ifToday {
            let tNow = ToolClass.getIntTime(times[1])
            let color = tNow < start ? UIColor.white : dzy_HexColor(0x777777)
            timeLineLB.textColor = color
            timeLB.textColor = color
            if canDel {
                delBtn.isHidden = !(start - tNow >= cancelTime * 60)
            }else {
                delBtn.isHidden = true
            }
        }else {
            timeLineLB.textColor = .white
            timeLB.textColor = .white
            delBtn.isHidden = !canDel
        }
        
        var x: CGFloat = 80.0
        if delBtn.isHidden {x -= 35}
        if qrView.isHidden {x -= 30}
        trailLC.constant = x
    }
    
    func ptUpdateUI(_ data: [String : Any], date: Date, x: Int) {
        reserveId = data.intValue("reserveId") ?? 0
        mid = data.stringValue("mid") ?? ""
        let start = data.intValue("start") ?? 0
        let end   = data.intValue("end") ?? 0
        let reduce = data.intValue("isReduce") ?? 0
        // 20 为教练排的课
        let type   = data.intValue("type") ?? 0
        timeLineLB.text = start >= 720 ? "pm" : "am"
        timeLB.text     = "\(ToolClass.getTimeStr(start))" + "-" + "\(ToolClass.getTimeStr(end))"
        nameLB.text     = data.stringValue("realname") ?? "暂无"
        cancelMsgLB.text = reduce == 1 ? "(已核销)" : "(未核销)"
        cancelMsgLB.textColor = reduce == 1 ? YellowMainColor : dzy_HexColor(0x999999)
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        
        // 未核销，并且是教练排的课
        let canDel = reduce == 0 && type == 20
        if x < 0 {
            let color = dzy_HexColor(0x777777)
            timeLineLB.textColor = color
            timeLB.textColor = color
            delBtn.isHidden = true
        }else if x > 0 {
            let color = UIColor.white
            timeLineLB.textColor = color
            timeLB.textColor = color
            delBtn.isHidden = !canDel
        }else {
            let nowDate = dzy_date8().description.components(separatedBy: " ")
            guard nowDate.count == 3 else {return}
            let time = ToolClass.getIntTime(nowDate[1])
            if time < start {
                timeLineLB.textColor = UIColor.white
                timeLB.textColor = UIColor.white
                delBtn.isHidden = !canDel
            }else {
                timeLineLB.textColor = dzy_HexColor(0x777777)
                timeLB.textColor = dzy_HexColor(0x777777)
                delBtn.isHidden = true
            }
        }
        var x: CGFloat = 50.0
        if delBtn.isHidden {x -= 35}
        trailLC.constant = x
    }
    
    @IBAction func delAction(_ sender: UIButton) {
        delegate?.classCell(self, didSelectDelBtn: sender, reserveId: reserveId, mid: mid)
    }
    
    @IBAction func qrAction(_ sender: UIButton) {
        if let code = code {
            delegate?.classCell(self, didSelectQrCodeBtn: sender, code: code)
        }
    }
}
