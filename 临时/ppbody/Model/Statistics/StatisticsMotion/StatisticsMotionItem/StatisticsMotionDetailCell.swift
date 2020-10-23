//
//  StatisticsOverviewDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsMotionDetailCell: UITableViewCell
{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var numLB: UILabel!
    @IBOutlet weak var freNumLB: UILabel!
    @IBOutlet weak var weightLB: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        self.bgView.layer.borderColor = CardColor.cgColor
        self.bgView.layer.borderWidth = 1
    }
    
    func setData(_ dic:[String:Any], index:Int)
    {
        self.numLB.text = "\(index + 1)"
        self.freNumLB.text = "\(dic["freNum"]!)个"
        
        let weight = (dic["weight"] as! NSNumber).floatValue
        self.weightLB.text = weight.removeDecimalPoint + "kg"
    }
}
