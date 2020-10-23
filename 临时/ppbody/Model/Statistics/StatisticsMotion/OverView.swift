//
//  OverView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class OverView: UIView
{
    @IBOutlet weak var totalNumLB: UILabel!
    @IBOutlet weak var totalTimeUnitLB: UILabel!
    @IBOutlet weak var totalTimeLB: UILabel!
    @IBOutlet weak var aveWeightLB: UILabel!
    
    @IBOutlet weak var aveWeightTitleLB: UILabel!
    @IBOutlet weak var aveWeightUnitLB: UILabel!
    @IBOutlet var mostIVS: [UIImageView]!
    @IBOutlet weak var rankIV: UIImageView!
    
    
    class func instanceFromNib() -> OverView {
        return UINib(nibName: "StatisticsDataView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OverView
    }
    
    
    override func awakeFromNib() {

    }
    
    func setData(_ dic: [String:Any]) {
        let motion = dic["motionCount"] as! [String:Any]
        totalNumLB.text = "\(motion["totalNum"]!)"
        
        let weightFloat = (motion["weightAve"] as! NSNumber).floatValue
        
        aveWeightLB.text = "\(weightFloat)"
        
        let totalTime = motion["totalTime"] as! Int
        
        if totalTime < 60 {
            totalTimeLB.text = "\(totalTime)"
            totalTimeUnitLB.text = "秒"
        }else if totalTime < 3600
        {
            let min = Float(totalTime) / 60
            totalTimeLB.text = "\(min.format(f: 1))"
            totalTimeUnitLB.text = "分钟"
        }else{
            let hour = Float(totalTime) / 3600.0
            totalTimeLB.text = "\(hour.format(f: 1))"
            totalTimeUnitLB.text = "小时"
        }
        
        if let topMotion = dic["topMotion"] as? [String],
            !topMotion.isEmpty
        {
            rankIV.isHidden = false
            for i in 0..<mostIVS.count {
                if i < topMotion.count {
                    mostIVS[i].isHidden = false
                    mostIVS[i].setCoverImageUrl(topMotion[i])
                }else {
                    mostIVS[i].isHidden = true
                }
            }
        }else {
            rankIV.isHidden = true
            mostIVS.forEach({$0.isHidden = true})
        }
    }
}
