//
//  StatisticsBodyDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsBodyDetailCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var dataLB: UILabel!
    
    var kgUnit = ["weight","muscle","fat"]
    var bodyPart = ["weight","muscle","fat","bust","arm","waist","hipline","thigh"]

    override func awakeFromNib() {
        bgView.layer.borderColor = CardColor.cgColor
        bgView.layer.borderWidth = 1
    }
    
    func setData(_ dic:[String:Any], _ txt: String)
    {
        timeLB.text = ToolClass.compareCurrentTime(date: dic["createTime"] as! String)
        
        let type = dic["type"] as! Int
        typeLB.isHidden = type == 20 ? false : true
        
        var unit = ""
    
        if kgUnit.contains(txt)
        {
            unit = "kg"
        }else if txt == "time"{
            unit = "min"
        }else{
            unit = "cm"
        }
        
        let keys = Array(dic.keys)
        
        var dataKey = ""
        
        for key in keys {
            if bodyPart.contains(key) {
                dataKey = key
                break
            }
        }
        
        if dataKey == "" {
            dataKey = "time"
            let dataValue = (dic[dataKey] as! NSNumber).floatValue/Float(60)

            self.dataLB.text = dataValue.removeDecimalPoint + unit
            return

        }
        
        let dataValue = (dic[dataKey] as! NSNumber).floatValue
        
        dataLB.text = dataValue.removeDecimalPoint + unit
    }
}
