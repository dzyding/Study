//
//  MyInfoVC.swift
//  YJF
//
//  Created by edz on 2019/5/15.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import WebKit

class MyInfoVC: BaseVC, TrainNextJumpProtocol {
    /// 昵称
    @IBOutlet weak var nicknameLB: UILabel!
    /// 电话
    @IBOutlet weak var mobileLB: UILabel!
    /// 身份状态
    @IBOutlet weak var identityLB: UILabel!
    /// 提示是否已经设置密码
    @IBOutlet weak var hasPassWordLB: UILabel!
    /// 姓
    @IBOutlet weak var familyNameLB: UILabel!
    /// 名
    @IBOutlet weak var firstName: UILabel!
    /// 性别
    @IBOutlet weak var sexLB: UILabel!
    /// 身份证
    @IBOutlet weak var idCardLB: UILabel!
    /// 冻结按钮
    @IBOutlet weak var frostBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "个人资料"
        frostBtn.layer.borderWidth = 1
        frostBtn.layer.borderColor = MainColor.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTarinNextJump()
    }
    
    private func updateUI() {
        let user = DataManager.user()
        nicknameLB.text = user?.stringValue("nickname")
        if let mobile = user?.stringValue("mobile"),
            mobile.count == 11
        {
            let start = mobile.index(mobile.startIndex, offsetBy: 3)
            let end   = mobile.index(start, offsetBy: 3)
            mobileLB.text = mobile.replacingCharacters(
                in: start...end,
                with: "＊＊＊＊"
            )
        }else {
            mobileLB.text = nil
        }
        identityLB.text = IDENTITY == .buyer ? "我要买房" : "我有房要卖"
        hasPassWordLB.text = DataManager.isPwd() == true ? "＊＊＊＊＊＊" : ""
        familyNameLB.text  = user?.stringValue("surname")
        if let name = user?.stringValue("name"),
            name.count > 0
        {
            firstName.text = "＊＊"
        }else {
            firstName.text = nil
        }
        sexLB.text      = user?.stringValue("title")
        if let idCard = user?.stringValue("idCard"),
            idCard.count > 10
        {
            let fn = idCard.index(idCard.startIndex, offsetBy: 2)
            let ss = idCard.index(idCard.endIndex, offsetBy: -3)
            idCardLB.text = idCard.replacingCharacters(
                in: fn...ss, with: "＊＊＊＊＊＊＊＊＊＊＊＊"
            )
        }else {
            idCardLB.text = nil
        }
    }
    
    //    MARK: - 修改实名信息
    @IBAction func editAction(_ sender: UIButton) {
        if DataManager.isPwd() == true {
            let vc = SingleInputVC(.loginPwd)
            dzy_push(vc)
        }else {
            let vc = EditMyInfoVC(.first)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 退出登录
    @IBAction func loginOutAction(_ sender: UIButton) {
        func baseAction() {
            DataManager.logout()
            if presentingViewController != nil {
                dismiss(animated: true, completion: nil)
            }else {
                let vc = BaseNavVC(rootViewController: LoginRegistBaseVC(.topCustom))
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
        let alert = dzy_normalAlert("确认退出", msg: "是否确认退出当前账号", sureClick: { (_) in
            baseAction()
        }, cancelClick: nil)
        present(alert, animated: true, completion: nil)
    }
    //    MARK: - 冻结操作
    @IBAction func frostAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "冻结账号", message: """
    冻结账户需要客服确认您的相关信息，长期冻结需要您亲自到服务中心，当面人工核实
""", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
        action1.setTextColor(dzy_HexColor(0xA3A3A3))
        let action2 = UIAlertAction(title: "联系客服", style: .default) { [weak self] (_) in
            self?.telPhoneAction()
        }
        action2.setTextColor(dzy_HexColor(0xFD7E25))
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    private func telPhoneAction() {
        let phoneStr = "tel:027-87750030"
        if let url = URL(string: phoneStr) {
            UIApplication.shared.open(url)
        }
    }
    
    //    MARK: - 修改昵称
    @IBAction func nickNameAction(_ sender: UIButton) {
        let vc = SingleInputVC(.nickName)
        dzy_push(vc)
    }
    
    //    MARK: - 修改密码
    @IBAction func pwdAction(_ sender: UIButton) {
        if DataManager.isPwd() == true {
            let vc = UpdatePwdVC()
            dzy_push(vc)
        }else {
            showMessage("请先进行实名认证，并设置密码")
            let vc = EditMyInfoVC(.first)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 手机号码
    @IBAction func phoneAction(_ sender: UIButton) {
        let vc = UpdatePhoneFirstVC()
        dzy_push(vc)
    }
    
    //    MAKR: - 身份选择
    @IBAction func identityAction(_ sender: UIButton) {
        let vc = SelfTypeVC(.changeType)
        present(
            BaseNavVC(rootViewController: vc),
            animated: true,
            completion: nil
        )
    }
}
