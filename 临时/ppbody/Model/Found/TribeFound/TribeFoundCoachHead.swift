//
//  TribeFoundCoachHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeFoundCoachHead: UICollectionReusableView{

    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var cityLB: UILabel!
    @IBOutlet weak var dataLB: UILabel!
    
    var dataDic:[String:Any]?
    
    override func awakeFromNib() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTribeView(_:))))
    }
    
    func setData(_ dic: [String:Any])
    {
        dataDic = dic
        
        self.coverIV.setCoverImageUrl(dic["cover"] as! String)
        self.cityLB.text = dic["city"] as? String
        self.nameLB.text = dic["name"] as? String
        
        let memberNum = dic["memberNum"] as! Int
        let topicNum = dic["topicNum"] as! Int
        let contributionNum = (dic["contributionNum"] as! NSNumber).floatValue.removeDecimalPoint
        
        self.dataLB.text = "成员:\(memberNum)  话题量:\(topicNum)  成长值:" + contributionNum
        
    }
    
    @objc func tapTribeView(_ tap: UITapGestureRecognizer)
    {
        
        if self.dataDic == nil
        {
            return
        }
        
        let fromVC = ToolClass.controller2(view: self)
        
        let vc = TribeTrendsVC.init(nibName: "TribeTrendsVC", bundle: nil)
        vc.ctid = self.dataDic!["ctid"] as! String
        vc.title = self.dataDic!["name"] as? String
        fromVC?.tabBarController?.navigationController?.pushViewController(vc, animated: true)
        
    }
}
