//
//  RecordDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

class RecordDetailCell: UITableViewCell {
    
    @IBOutlet weak var numOfGroupLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(data: [String: Any]) {
        let motion = data["motion"] as! [String: Any]
        
        titleLbl.text = motion["name"] as? String
        iconImg.setHeadImageUrl(motion["cover"] as! String)
        
        let groupNum = data.intValue("groupNum") ?? 0
        if groupNum <= 0,
            let time = data.intValue("time")
        {
            groupLbl.text = ToolClass.secondToText(time)
            weightLbl.isHidden = true
            numOfGroupLbl.isHidden = true
        }else{
            weightLbl.isHidden = false
            numOfGroupLbl.isHidden = false
            groupLbl.text = "\(groupNum)组"
            weightLbl.text = (data["weightAve"] as! NSNumber).floatValue.removeDecimalPoint + "kg/均负重"
            numOfGroupLbl.text = "\(data["freNumAve"] ?? 0)/均次"
        }
    
    }
}
