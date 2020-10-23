//
//  BodyStatusFirstVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BodyStatusFirstVC: BaseVC {
    
    @IBOutlet weak var tableList: UITableView!
    
    var headerView:BodyStatusHeaderView?
    
    private let itemInfo: IndicatorInfo
    
    init(_ itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView = BodyStatusHeaderView.instanceFromNib()
        tableList.tableHeaderView = headerView
        tableList.register(UINib.init(nibName: "BodyStatusFirstCell", bundle: nil), forCellReuseIdentifier: "BodyStatusFirstCell")
        tableList.showsVerticalScrollIndicator = false
    }
    
    func setBodyData(_ body:[String:Any]) {
        headerView?.lblHealthIndex.text = "\(body["score"]!)"
        
        if var weight = body["weight"] as? [String:Any]
        {
            weight["name"] = "体重"
            weight["unit"] = "kg"
            weight["color"] = UIColor.ColorHex("#6FB6CB")
            self.dataArr.append(weight)
        }
    
        if var muscle = body["muscle"] as? [String:Any]
        {
            let current = (muscle["current"] as! NSNumber).floatValue
            if current != 0
            {
                muscle["name"] = "骨骼肌"
                muscle["unit"] = "kg"
                muscle["color"] = UIColor.ColorHex("#5096F7")
                self.dataArr.append(muscle)
            }
        }
        
        if var fat = body["fat"] as? [String:Any]
        {
            let current = (fat["current"] as! NSNumber).floatValue
            if current != 0
            {
                fat["name"] = "脂肪"
                fat["unit"] = "kg"
                fat["color"] = UIColor.ColorHex("#4263D7")
                self.dataArr.append(fat)
            }
        }
        
        if var BMI = body["BMI"] as? [String:Any]
        {
            BMI["name"] = "BMI"
            BMI["unit"] = ""
            BMI["color"] = UIColor.ColorHex("#A5E06D")
            self.dataArr.append(BMI)
        }
        
        if var PBF = body["PBF"] as? [String:Any]
        {
            PBF["name"] = "PBF"
            PBF["unit"] = "%"
            PBF["color"] = UIColor.ColorHex("#B3EB53")
            self.dataArr.append(PBF)
        }
        
        if var WHR = body["WHR"] as? [String:Any]
        {
            WHR["name"] = "WHR"
            WHR["unit"] = ""
            WHR["color"] = UIColor.ColorHex("#8BCC9A")
            self.dataArr.append(WHR)
        }
        
        if var KCAL = body["KCAL"] as? [String:Any]
        {
            KCAL["name"] = "KCAL"
            KCAL["unit"] = ""
            KCAL["color"] = UIColor.ColorHex("#F8E71C")
            self.dataArr.append(KCAL)
        }
        
        self.tableList.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension BodyStatusFirstVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bodyStatusFirstCell = cell as! BodyStatusFirstCell
        bodyStatusFirstCell.setData(self.dataArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyStatusFirstCell") as! BodyStatusFirstCell
        return cell
    }
}

extension BodyStatusFirstVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
