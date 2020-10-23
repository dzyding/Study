//
//  PersonalMoreVC.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class PersonalMoreVC: BaseVC {
    
    @IBOutlet private weak var iconIV: UIImageView!
    
    @IBOutlet private weak var nameLB: UILabel!
    
    @IBOutlet private weak var briefLB: UILabel!
    
    private let uid: String
    
    private let data: [String : Any]

    @IBOutlet weak var removeView: UIView!
    
    init(_ uid: String, data: [String : Any]) {
        self.uid = uid
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "更多"
        initUI()
    }
    
    private func initUI() {
        guard let user = data["user"] as? [String : Any] else {return}
        nameLB.text = user.stringValue("nickname")
        iconIV.dzy_setCircleImg(user.stringValue("head") ?? "", 180)
        briefLB.text = user.stringValue("brief")
        
        if !DataManager.isCoach() {
            if let isMember = data.intValue("isMember"), isMember == 1 {
                removeView.isHidden = false
            }
        }
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        let vc = ReportListVC(.user, data: data)
        dzy_push(vc)
    }
    
    @IBAction func blackAction(_ sender: UIButton) {
        guard uid != DataManager.userAuth() else {
            ToolClass.showToast("不能拉黑自己", .Failure)
            return
        }
        let alert =  UIAlertController.init(title: "温馨提示", message: "TA将无法看到你在PPBody上的内容，确认要拉黑吗？", preferredStyle: .alert)
        let actionY = UIAlertAction.init(title: "确认", style: .destructive) { (_) in
            self.blackApi()
        }
        let actionN = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
            
        }
        alert.addAction(actionY)
        alert.addAction(actionN)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func removeAction(_ sender: UIButton) {
        let alert =  UIAlertController.init(title: "温馨提示", message: "解除关系会自动从教练部落退出，是否确定？", preferredStyle: .alert)
        let actionY = UIAlertAction.init(title: "确认", style: .destructive) { (_) in
            self.removeMemberApi()
        }
        let actionN = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
            
        }
        alert.addAction(actionY)
        alert.addAction(actionN)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func blackApi() {
        let request = BaseRequest()
        request.url = BaseURL.BecomeBlack
        request.dic = ["uid" : uid, "type" : "10"]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("拉黑成功", .Success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.dzy_pop()
            }
        }
    }
    
    //取消教练学员
    private func removeMemberApi() {
        let request = BaseRequest()
        request.dic = ["uid" : uid, "type" : "20"] //10 成为 20 取消
        request.url = BaseURL.CoachMember
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            // header 会接收通知进行 "申请会员" 按钮的隐藏和显示
            NotificationCenter.default.post(name: Config.Notify_ExitMember, object: nil)
            // 更新个人中的教练板块，发现板块中的部落部分
            NotificationCenter.default.post(name: Config.Notify_BeCoachMember, object: nil)
            
            ToolClass.showToast("解除成功", .Success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.dzy_pop()
            }
        }
    }
}
