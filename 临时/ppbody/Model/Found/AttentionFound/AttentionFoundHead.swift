//
//  TribeFoundHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AttentionFoundHead: UICollectionReusableView{
    
    @IBOutlet weak var stackview: UIStackView!
    
    var dataArr = [[String:Any]]()
    
    @IBOutlet weak var scrollview: UIScrollView!
    override func awakeFromNib() {
        getData()
    }
    
    func setData(_ list:[[String:Any]])
    {
        for view in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for i in 0..<list.count
        {
            let dic = list[i]
            let item = AttentionView.instanceFromNib()
            item.setData(dic)
            item.tag = i
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeadView(_:))))
            item.attentionAction = { (uid,isAttention) ->() in
                self.attentionAPI(uid: uid, isAttention)
            }
            self.stackview.addArrangedSubview(item)
            item.snp.makeConstraints { (make) in
                make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                make.height.equalToSuperview()
            }
            
        }
        
        let offset = 3 - list.count % 3
        
        if offset == 3
        {
            return
        }
        
        for _ in 0..<offset
        {
            let item = UIView()
            self.stackview.addArrangedSubview(item)
            item.snp.makeConstraints { (make) in
                make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                make.height.equalToSuperview()
            }
        }

    }
    
    @objc func tapHeadView(_ tap: UITapGestureRecognizer)
    {
        let tag = tap.view?.tag
        let fromVC = ToolClass.controller2(view: self)
        let user = self.dataArr[tag!]
        let vc = PersonalPageVC()
        vc.user = user
        fromVC?.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func refreshAction(_ sender: UIButton) {
        getData()
    }
    
    func getData()
    {
        let request = BaseRequest()
        request.url = BaseURL.RecommondUser
        request.isUser = true
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.dataArr = data?["list"] as! Array<Dictionary<String,Any>>
         
            self.setData(self.dataArr)
        }
    }
    
    //关注用户 和取消
    func attentionAPI(uid: String, _ isAttention: Bool)
    {
        let request = BaseRequest()
        request.dic = ["uid":uid,"type":isAttention ? "10" : "20"]
        request.url = BaseURL.Attention
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            NotificationCenter.default.post(name: Config.Notify_AttentionPersonal, object: nil)
            
        }
    }
    
}
