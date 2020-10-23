//
//  CoachHomeTribeView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachHomeTribeView: UIView {

    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblTribeName: UILabel!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    var dataDic:[String:Any]?
 
    class func instanceFromNib() -> CoachHomeTribeView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! CoachHomeTribeView
    }
    
    override func awakeFromNib() {
        
    }
    
    
    func setData(_ dic: [String:Any], isMember: Bool)
    {
        self.dataDic = dic
        
        self.lblTribeName.text = dic["name"] as! String + "(\(dic["memberNum"] as! Int)人)"
        let city = dic["city"] as? String
        if city == nil || city == ""
        {
            self.lblArea.text = "未知城市"
        }else{
            self.lblArea.text = city
        }
        self.lblDesc.text = dic["slogan"] as? String
        self.lblActive.text = "成长值：" + (dic["contributionNum"] as! NSNumber).floatValue.removeDecimalPoint
        
        if isMember
        {
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tribeDetailAction)))
        }
    }
    
    @objc func tribeDetailAction()
    {
        let vc = TribeTrendsVC()
        vc.ctid = self.dataDic!["ctid"] as! String
        vc.title = self.dataDic!["name"] as? String
        
        ToolClass.controller2(view: self)!.navigationController?.pushViewController(vc, animated: true)
    }
}
