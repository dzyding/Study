//
//  StudentCourseCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class StudentCourseCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnType: UIButton!
    
    @IBOutlet weak var lblContent: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var viewCorner: UIView!
    @IBOutlet weak var viewContent: UIView!
    
    var type = "1"
    
    override func awakeFromNib() {
        
    }
    
 
    func setData(data: [String: Any]) {
        lblTitle.text = data["planName"] as? String
        lblContent.text = data["planContent"] as? String
        imgIcon.setHeadImageUrl((data["coach"] as! [String: Any])["head"] as? String ?? "")
        lblName.text = (data["coach"] as! [String: Any])["nickname"] as? String
        let date = ToolClass.getDateFormDateStr(date: data["addTime"] as! String , format: "yyyy-MM-dd")
        lblTime.text = ToolClass.getStringFormDate(date: date, format: "MM/dd")  + " " + (data["timeLine"] as! String)
        
        if type == "1" {
            self.btnType.layer.borderColor = YellowMainColor.cgColor
            self.btnType.setTitleColor(YellowMainColor, for: .normal)
            self.btnType.setTitle("待学习", for: .normal)
            self.btnType.layer.borderWidth = 1.0
        }
        else {
            self.btnType.layer.borderColor = nil
            self.btnType.setTitleColor(Text1Color, for: .normal)
            self.btnType.setTitle("已学习", for: .normal)
            self.btnType.layer.borderWidth = 0.0
            self.btnType.backgroundColor = UIColor.ColorHex("#4a4a4a")
            
        }
    }
    
    
}
