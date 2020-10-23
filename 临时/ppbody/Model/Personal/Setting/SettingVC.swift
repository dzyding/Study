//
//  SettingVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SettingVC: BaseVC {

    @IBOutlet weak var viewAccountSet: UIView!
    @IBOutlet weak var viewMessageNot: UIView!
    @IBOutlet weak var viewSwitch: UISwitch!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewSystem: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var helpView: UIView!
    /// 用户协议
    @IBOutlet weak var userProtocolView: UIView!
    /// 隐私协议
    @IBOutlet weak var secretProtocolView: UIView!
    @IBOutlet weak var tirbeProtocolView: UIView!
    @IBOutlet weak var viewBlack: UIView!
    @IBOutlet weak var viewAddress: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        viewSwitch.backgroundColor = UIColor.ColorHex("#4a4a4a")
        viewSwitch.tintColor = UIColor.ColorHex("#4a4a4a")
        viewSwitch.layer.masksToBounds = true
        viewSwitch.layer.cornerRadius = viewSwitch.bounds.size.height/2.0
        
        viewSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
        
        if DataManager.notifySwitch() == 0
        {
            viewSwitch.isOn = true
        }else{
            viewSwitch.isOn = false
        }
        [
            viewAccountSet, viewSystem, aboutView, scoreView,
            secretProtocolView, userProtocolView, tirbeProtocolView,
            helpView, viewBlack, viewAddress
        ].forEach({ (view) in
            view?.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(tapView(tap:)))
            )
        })
    }
    
    @objc func tapView(tap: UITapGestureRecognizer) {
        if tap.view == viewAccountSet {
            let vc = AccountSettingVC.init(nibName: "AccountSettingVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == viewSystem {
            let vc = SystemSettingVC.init(nibName: "SystemSettingVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == userProtocolView
        {
            let vc = UserProtocolSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if tap.view == secretProtocolView {
            let vc = SecretProtocolVC()
            dzy_push(vc)
        }else if tap.view == tirbeProtocolView
        {
            let vc = TribeProtocolSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if tap.view == helpView
        {
            let vc = HandbookVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == aboutView
        {
            let vc = AboutSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if tap.view == scoreView
        {
            let appStore = String(format: "itms-apps://itunes.apple.com/app/id%@?action=write-review", "1417785073")
            UIApplication.shared.open(URL(string: appStore)!, options: [:], completionHandler: nil)
        }else if tap.view == viewBlack {
            let vc = BlackListVC()
            dzy_push(vc)
        }else if tap.view == viewAddress {
            let vc = AddressListVC()
            dzy_push(vc)
        }
    }
    
    @objc func switchDidChange(){
        //打印当前值
        
        if viewSwitch.isOn
        {
            RCIM.shared().disableMessageNotificaiton = false
            DataManager.saveNotifySwitch(0)
        }else{
            RCIM.shared().disableMessageNotificaiton = true
            DataManager.saveNotifySwitch(1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
