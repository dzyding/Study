//
//  CoachCourseCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol CoachCourseCellDelegate:NSObjectProtocol {
    func deleteCourseAction(_ cell: CoachCourseCell)
}

class CoachCourseCell: UITableViewCell {

    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTimeDetail: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    weak var delegate: CoachCourseCellDelegate?
    
    func setData(_ data: [String: Any], history: Bool = false) {
        
        let user = data["user"] as! [String: Any]
        imgIcon.setHeadImageUrl(user["head"] as! String)
        lblName.text = user["nickname"] as? String
        
        
        lblTitle.text = data["planName"] as? String
        lblDesc.text = data["planContent"] as? String
        lblTimeDetail.text = data["timeLine"] as? String
        var addTime = data["addTime"] as! String
        let timeline = data["timeLine"] as! String
        addTime = addTime +  " " + timeline.components(separatedBy: "-")[0] + ":00"
        if history
        {
            lblTime.text = ToolClass.compareCurrentTime(date: addTime)
            
        }else{
            let secondStr = timeline[0..<1]
            if (secondStr as NSString).intValue >= 12 {
                lblTime.text = "pm"
            }
            else {
                lblTime.text = "am"
            }
        }
        

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeDate = formatter.date(from: addTime)
        
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(timeDate!)
        
        if timeInterval < 0
        {
            self.deleteBtn.isHidden = false
            
            lblTimeDetail.textColor = UIColor.white
            lblTime.textColor = UIColor.white
        }else{
             self.deleteBtn.isHidden = true
            lblTimeDetail.textColor = Text1Color
            lblTime.textColor = Text1Color
        }

    }

    @IBAction func deleteAction(_ sender: UIButton) {
        self.delegate?.deleteCourseAction(self)
    }
    
}
