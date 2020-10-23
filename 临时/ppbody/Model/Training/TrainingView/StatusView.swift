//
//  StatusView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatusView: UIView
{
    @IBOutlet weak var statusIV: UIImageView!
    @IBOutlet weak var radarView: RadarChartView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    @IBOutlet weak var bmiView: UIView!
    @IBOutlet weak var bmiLB: UILabel!
    
    @IBOutlet weak var pbfView: UIView!
    @IBOutlet weak var pbfLB: UILabel!
    
    @IBOutlet weak var whrView: UIView!
    @IBOutlet weak var whrLB: UILabel!
    
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var weightLB: UILabel!
    
    @IBOutlet weak var muscleView: UIView!
    @IBOutlet weak var muscleLB: UILabel!
    
    @IBOutlet weak var fatView: UIView!
    @IBOutlet weak var fatLB: UILabel!
    
    @IBOutlet weak var tipIV: UIImageView!
    
    
    class func instanceFromNib() -> StatusView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! StatusView
    }
    
    override func awakeFromNib() {

        radarView.titles = ["体重", "BMI", "骨骼肌", "PBF", "体脂肪", "WHR"]
        radarView.webTitles = ["20", "40", "60", "80", "100"]
        
        if DataManager.firstRegister() == 1
        {
            self.tipIV.isHidden = false
            ToolClass.dispatchAfter(after: 8) {
                self.tipIV.isHidden = true
            }
        }else{
            self.tipIV.removeFromSuperview()
        }
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStatusClick(_:))))
    }
    
    func setData(_ dic:[String:Any])
    {
        self.statusIV.setCoverImageUrl(dic["cover"] as! String)
        
        var dataSet = [ChartDataRadarEntry]()
        
        if let weight = dic["weight"] as? [String:Any]
        {
            let min = (weight["min"] as! NSNumber).floatValue
            let max = (weight["max"] as! NSNumber).floatValue
            let current = (weight["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.weightLB.text = current.removeDecimalPoint + "kg"
            self.weightView.isHidden = false
        }else{
            self.weightView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        
        if let bmi = dic["BMI"] as? [String:Any]
        {
            let min = (bmi["min"] as! NSNumber).floatValue
            let max = (bmi["max"] as! NSNumber).floatValue
            let current = (bmi["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.bmiLB.text = current.removeDecimalPoint
            
            self.bmiView.isHidden = false
        }else{
            self.bmiView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        
        if let muscle = dic["muscle"] as? [String:Any]
        {
            let min = (muscle["min"] as! NSNumber).floatValue
            let max = (muscle["max"] as! NSNumber).floatValue
            let current = (muscle["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.muscleLB.text = current.removeDecimalPoint + "kg"
            
            self.muscleView.isHidden = false
        }else{
            self.muscleView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        
        if let pbf = dic["PBF"] as? [String:Any]
        {
            let min = (pbf["min"] as! NSNumber).floatValue
            let max = (pbf["max"] as! NSNumber).floatValue
            let current = (pbf["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.pbfLB.text = current.removeDecimalPoint + "%"
            
            self.pbfView.isHidden = false
        }else{
            self.pbfView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        
        if let fat = dic["fat"] as? [String:Any]
        {
            let min = (fat["min"] as! NSNumber).floatValue
            let max = (fat["max"] as! NSNumber).floatValue
            let current = (fat["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.fatLB.text = current.removeDecimalPoint + "kg"
            
            self.fatView.isHidden = false
        }else{
            self.fatView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        
        if let whr = dic["WHR"] as? [String:Any]
        {
            let min = (whr["min"] as! NSNumber).floatValue
            let max = (whr["max"] as! NSNumber).floatValue
            let current = (whr["current"] as! NSNumber).floatValue
            
            let offset = (max - min)
            
            let ratio = (max - min) * 3 / 100
            
            let progress = CGFloat((current - (min - offset))/ratio)
            
            dataSet.append(ChartDataRadarEntry(value: progress))
            self.whrLB.text = current.removeDecimalPoint + ""
            self.whrView.isHidden = false
        }else{
            self.whrView.isHidden = true
            dataSet.append(ChartDataRadarEntry(value: 0))
        }
        var dataSetRadar = ChartDataSet()
        dataSetRadar.entries = dataSet
        dataSetRadar.strokeColor = UIColor.ColorHex("#F8E71C")
        dataSetRadar.fillColor = UIColor.ColorHexWithAlpha("#F8E71C",0.5)
        radarView.dataSets = [dataSetRadar]
    }
    
    @IBAction func onStatusClick(_ sender: Any) {
        let vc = ToolClass.controller2(view: self)
        let toVC = BodyStatusVC()
        vc?.tabBarController?.navigationController?.pushViewController(toVC, animated: true)
    }
    
}
