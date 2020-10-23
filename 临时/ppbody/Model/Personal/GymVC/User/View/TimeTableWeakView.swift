//
//  TimeTableWeakView.swift
//  PPBody
//
//  Created by edz on 2019/4/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TimeTableWeakView: UIView {

    @IBOutlet weak var mondayLB: UILabel!
    
    @IBOutlet weak var mondaySubLB: UILabel!
    
    @IBOutlet weak var tuesdayLB: UILabel!
    
    @IBOutlet weak var tuesdaySubLB: UILabel!
    
    @IBOutlet weak var wednesdayLB: UILabel!
    
    @IBOutlet weak var wednesdaySubLB: UILabel!
    
    @IBOutlet weak var thursdayLB: UILabel!
    
    @IBOutlet weak var thursdaySubLB: UILabel!
    
    @IBOutlet weak var fridayLB: UILabel!
    
    @IBOutlet weak var fridaySubLB: UILabel!
    
    @IBOutlet weak var saturdayLB: UILabel!
    
    @IBOutlet weak var saturdaySubLB: UILabel!
    
    @IBOutlet weak var sundayLB: UILabel!
    
    @IBOutlet weak var sundaySubLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let now = Date()
        let calendar = Calendar.current
        var todayWeek = calendar.component(.weekday, from: now)
        todayWeek = todayWeek == 1 ? 7 : todayWeek - 1
        let todayMonth = calendar.component(.month, from: now)
        let todayDay   = calendar.component(.day, from: now)
        
        getLBAndSubLB(todayWeek).0.text = "今日"
        getLBAndSubLB(todayWeek).1.text = "\(todayMonth)-\(todayDay)"

        ((todayWeek + 1)...(todayWeek + 6)).forEach { (week) in
            let x = week - todayWeek
            var components = DateComponents()
            components.day = x
            setOtherDay(components, week: week % 7)
        }
        
        func setOtherDay(_ components: DateComponents, week: Int) {
            if let time = calendar.date(byAdding: components, to: now) {
                let month = calendar.component(.month, from: time)
                let day   = calendar.component(.day, from: time)
                getLBAndSubLB(week).1.text = "\(month)-\(day)"
            }
        }
    }
    
    func getLBAndSubLB(_ week: Int) -> (UILabel, UILabel) {
        switch week {
        case 1:
            return (mondayLB, mondaySubLB)
        case 2:
            return (tuesdayLB, tuesdaySubLB)
        case 3:
            return (wednesdayLB, wednesdaySubLB)
        case 4:
            return (thursdayLB, thursdaySubLB)
        case 5:
            return (fridayLB, fridaySubLB)
        case 6:
            return (saturdayLB, saturdaySubLB)
        default:
            return (sundayLB, sundaySubLB)
        }
    }
}
