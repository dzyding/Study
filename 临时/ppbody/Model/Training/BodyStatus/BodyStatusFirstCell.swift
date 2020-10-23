//
//  BodyStatusFirstCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BodyStatusFirstCell: UITableViewCell {

    @IBOutlet weak var unitLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var numLB: UILabel!
    @IBOutlet weak var minLB: UILabel!
    @IBOutlet weak var maxLB: UILabel!
    
    @IBOutlet weak var minLeftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var maxLeftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var progressview: LinearProgressBar!
    
    var timer:Timer!

    var progress:CGFloat = 0
    
    var index:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width3 = (ScreenWidth - 96) / 3
        self.minLeftMargin.constant = width3
        self.maxLeftMargin.constant = width3 * 2
    }
       
    func setData(_ dic:[String:Any])
    {
        self.titleLB.text = dic["name"] as? String
        
        let min = (dic["min"] as! NSNumber).floatValue
        let max = (dic["max"] as! NSNumber).floatValue
        let current = (dic["current"] as! NSNumber).floatValue
        
        let offset = (max - min)
        
        let ratio = (max - min) * 3 / 100
        
        progress = CGFloat((current - (min - offset))/ratio)
        
        
        self.numLB.text = current.removeDecimalPoint
        self.minLB.text = min.removeDecimalPoint
        self.maxLB.text = max.removeDecimalPoint
        
        let unit = dic["unit"] as! String
        if unit == ""
        {
            self.unitLB.isHidden = true
        }else{
            self.unitLB.isHidden = false
            self.unitLB.text = "单位：" + unit
        }
        
        progressview.barColor = dic["color"] as! UIColor
        
        progressview.progressValue = progress
        
        
    }
    
    @objc func updateTime()
    {
        let offset = progress/100
        
        index += offset
        
        index = index > progress ? progress : index
        self.progressview.progressValue = index
        
        if index == progress
        {
            if self.timer != nil
            {
                self.timer.invalidate()
                self.timer = nil
            }
        }
    }
}
