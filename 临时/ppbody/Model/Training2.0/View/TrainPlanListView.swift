//
//  TrainPlanListView.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanListView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var groupNumLB: UILabel!
    var handler: (()->())?

    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupNumLB.font = dzy_FontBlod(11)
    }
    
    @IBAction func clickAction(_ sender: Any) {
        handler?()
    }
    
    func initUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("name")
        groupNumLB.text = "\(data.intValue("motionNum") ?? 1)组动作"
        let weeks = data["weeks"] as? [Int] ?? []
        (1...7).forEach { (week) in
            let label = getLB(week, isLight: weeks.contains(week))
            stackView.addArrangedSubview(label)
        }
    }
    
    private func getLB(_ num: Int, isLight: Bool) -> UILabel {
        var text = ""
        switch num {
        case 1:
            text = "一"
        case 2:
            text = "二"
        case 3:
            text = "三"
        case 4:
            text = "四"
        case 5:
            text = "五"
        case 6:
            text = "六"
        case 7:
            text = "七"
        default:
            break
        }
        let label = UILabel()
        label.font = dzy_Font(11)
        label.textColor = isLight ?
            YellowMainColor :
            RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        label.text = text
        return label
    }
}
