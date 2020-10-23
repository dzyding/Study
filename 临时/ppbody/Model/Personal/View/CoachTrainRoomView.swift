//
//  CoachTrainRoomView.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachTrainRoomView: UIView {
    
    @IBOutlet weak var viewYellow: UIView!
    @IBOutlet weak var viewGreen: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    var dataDic:[String:Any]?


    class func instanceFromNib() -> CoachTrainRoomView {
        return UINib(nibName: "CoachTrainRoomView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CoachTrainRoomView
    }
    
    override func awakeFromNib() {
        getCoachTribe()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tribeAction)))
    }
    
    @objc func tribeAction()
    {
        let toVC = TribeTrendsVC()
        toVC.ctid = dataDic!["ctid"] as! String
        toVC.title = dataDic!["name"] as? String
        
        let vc = ToolClass.controller2(view: self)
        vc?.tabBarController?.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func setData(_ dic: [String:Any])
    {
        dataDic = dic
        self.lblTitle.text = dic["name"] as! String + "(\(dic["memberNum"] as! Int)人)"
        let city = dic["city"] as? String
        if city == nil || (city?.isEmpty)!
        {
            self.lblArea.text = "未知城市"
        }else{
            self.lblArea.text = dic["city"] as? String
        }
        self.lblDesc.text = dic["slogan"] as? String
        self.lblActive.text = "成长值：" + (dic["contributionNum"] as! NSNumber).floatValue.removeDecimalPoint

    }
    
    func getCoachTribe()
    {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MyTribe
        request.start { (data, error) in
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }

            let listData = data!["list"] as! [[String:Any]]

            let dic = listData[0]
            
            self.setData(dic)
            
            
        }
    }
}
