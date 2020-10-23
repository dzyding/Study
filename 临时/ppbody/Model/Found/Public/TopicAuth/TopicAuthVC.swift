//
//  TopicAuthVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol SelectTopicAuthDelegate: NSObjectProtocol {
    func selectAuth(_ auth : [String:String])
}

class TopicAuthVC: BaseVC
{
    @IBOutlet weak var publicView: UIView!
    @IBOutlet weak var publicBtn: UIButton!
    
    @IBOutlet weak var allTribeView: UIView!
    @IBOutlet weak var allTribeBtn: UIButton!
    @IBOutlet weak var stackview: UIStackView!
    
    weak var delegate : SelectTopicAuthDelegate?

    var display:String?
    var tribeIds:[String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "谁可以看"
        
        publicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(publicAction)))
        allTribeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allTribeAction)))
        
        if display == "30"
        {
            self.publicBtn.isSelected = true
        }else{
            self.publicBtn.isSelected = false
        }
        
        getData()
    }
    
    @objc func publicAction()
    {
        self.publicBtn.isSelected = true
        self.allTribeBtn.isSelected = false
        
        for view in self.stackview.subviews
        {
            let tribe = view as? TopicAuthTribeView
            tribe?.tribeBtn.isSelected = false
        }
        sendAuthToParent()
    }
    
    @objc func allTribeAction()
    {
        self.publicBtn.isSelected = false
        self.allTribeBtn.isSelected = true
        
        for view in self.stackview.subviews
        {
            let tribe = view as? TopicAuthTribeView
            tribe?.tribeBtn.isSelected = true
        }
        sendAuthToParent()
    }
    
    @objc func tribeAction(_ tap : UITapGestureRecognizer)
    {
        
        let tribe = tap.view as? TopicAuthTribeView
        tribe?.tribeBtn.isSelected = !(tribe?.tribeBtn.isSelected)!
        
        var selectNum = 0
        for view in self.stackview.subviews
        {
            let tribe = view as? TopicAuthTribeView
            if (tribe?.tribeBtn.isSelected)!
            {
                selectNum += 1
            }
        }
        
        if selectNum == 0 {
            self.publicBtn.isSelected = true
            self.allTribeBtn.isSelected = false

        }else if selectNum == self.stackview.subviews.count{
            self.allTribeBtn.isSelected = true
            self.publicBtn.isSelected = false
        }else{
            self.allTribeBtn.isSelected = false
            self.publicBtn.isSelected = false
        }
        
        sendAuthToParent()
    }
    
    //判断权限类型 代理出去
    func sendAuthToParent()
    {
        var data = [String:String]()
        if self.publicBtn.isSelected
        {
            data["display"] = "30"
        }else{
            data["display"] = "20"
            var tribeIds = [String]()
            for view in self.stackview.subviews
            {
                let tribe = view as? TopicAuthTribeView
                if (tribe?.tribeBtn.isSelected)!
                {
                    tribeIds.append((tribe?.ctid)!)
                }
            }
            data["tribeIds"] = ToolClass.toJSONString(dict: tribeIds)
        }
        
        self.delegate?.selectAuth(data)
    }
    
    func getData()
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
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            if listData.count > 0
            {
                self.allTribeView.isHidden = false
            }
            
            for dic in listData
            {
                let tribeview = TopicAuthTribeView.instanceFromNib()
                tribeview.setData(dic)
                tribeview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tribeAction(_:))))
                self.stackview.addArrangedSubview(tribeview)
                
                if self.tribeIds != nil
                {
                    if (self.tribeIds?.contains(dic["ctid"] as! String))!
                    {
                        tribeview.tribeBtn.isSelected = true
                    }
                }
            }
            
            if self.tribeIds?.count == listData.count
            {
                self.allTribeBtn.isSelected = true
            }
           
        }
    }
}
