//
//  AboutSettingVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/16.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AboutSettingVC: BaseVC
{
    @IBOutlet weak var versionLB: UILabel!
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var cooperationView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var serviceView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于PPbody"
        
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        self.versionLB.text = "版本号：V" + currentVersion
        aboutView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        cooperationView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        feedbackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
        serviceView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:))))
    }
    
    @objc func tapView(tap: UITapGestureRecognizer) {
        if tap.view == aboutView {
            let vc = AboutSettingUsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == cooperationView {
            let alertController = UIAlertController(
                title: "",
                message: "合作和报道请使用以下邮箱，如需反馈PPbody使用问题或建议，请返回进入「意见反馈」提交反馈",
                preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil)
            alertController.addAction(cancelAction)
            let okAction = UIAlertAction(
                title: "商务合作：business@ppbody.com",
                style: .default,
                handler: nil)
            alertController.addAction(okAction)
            alertController.popoverPresentationController?.sourceView = tap.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 80, y:(tap.view?.na_height)!/2, width: 0.0, height: 0.0)
            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)
        }else if tap.view == feedbackView
        {
            let vc = AboutSettingFeedbackVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if tap.view == serviceView
        {
            let alertController = UIAlertController(
                title: "",
                message: "客服热线服务时间：工作日9:00-18:00，如需反馈PPbody使用问题或建议，请返回进入「意见反馈」提交反馈",
                preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil)
            alertController.addAction(cancelAction)
            let okAction = UIAlertAction(title: "客服热线：400-027-0986", style: .default) { (action) in
                ToolClass.callMobile("400-027-0986")
            }

        
            alertController.popoverPresentationController?.sourceView = tap.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 80, y:(tap.view?.na_height)!/2, width: 0.0, height: 0.0)
 
            alertController.addAction(okAction)
            
            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)
        }
    }
    
}
