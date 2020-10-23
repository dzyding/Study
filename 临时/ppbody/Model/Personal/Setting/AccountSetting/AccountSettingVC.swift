//
//  AccountSettingVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import HBDNavigationBar

class AccountSettingVC: BaseVC {
    
    @IBOutlet weak var phoneLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "账号设置"

        let user = DataManager.userInfo()
        let mobile = user!["mobile"] as! String
        if mobile.contains("pp")
        {
            self.phoneLbl.text = mobile
        }else{
            self.phoneLbl.text = ToolClass.stringByX(str: mobile, startindex: 3, endindex: 7)
        }
    }
    
    @objc func switchTap(swt: UISwitch) {
        
    }

    @IBAction func logoutBtnClick(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "请确认是否退出？", message: "", preferredStyle: .alert)
        let actionN = UIAlertAction(title: "是", style: .default) { [weak self] (_) in
            alert.dismiss(animated: false, completion: nil)
            self?.logoutAction()
        }

        let actionY = UIAlertAction(title: "否", style: .cancel) { (_) in
            alert.dismiss(animated: false, completion: nil)
        }
        alert.addAction(actionN)
        alert.addAction(actionY)
        present(alert, animated: true, completion: nil)
    }
    
    func logoutAction() {
        if presentingViewController != nil {
            dismiss(animated: false, completion: nil)
        }
        DataManager.logout()
        let loginVC = LoginVC()
        loginVC.hbd_barAlpha = 0
        let vc = HBDNavigationController(rootViewController: loginVC)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @IBAction func modifyBtnClick(_ sender: UIButton) {
        let vc = ModifyPswdVC.init(nibName: "ModifyPswdVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
