//
//  StatisticsOverviewDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsOverviewDetailCell: UITableViewCell
{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var numLB: UILabel!
    @IBOutlet weak var freNumLB: UILabel!
    @IBOutlet weak var weightLB: UILabel!
    
    func setData(_ dic:[String:Any], index:Int) {
        bgView.layer.cornerRadius = 6
        bgView.layer.borderColor = CardColor.cgColor
        bgView.layer.borderWidth = 1
        
        numLB.text = "\(index + 1)"
        freNumLB.text = "\(dic["freNum"]!)个"
        
        let weight = (dic["weight"] as! NSNumber).floatValue
        weightLB.text = weight.removeDecimalPoint + "kg"
    }
}
