//
//  StatisticItemView.swift
//  PPBody
//
//  Created by edz on 2019/11/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class StatisticItemView: UIView {
    
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    var handler: (()->())?
    
    static func initFromNib() -> StatisticItemView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[5] as! StatisticItemView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightLC.constant = dzy_imgHeight(
            "home_statistic_bg",
            width: dzy_SW - 32.0)
    }

    @IBAction func clickAction(_ sender: Any) {
        handler?()
    }
    
}
