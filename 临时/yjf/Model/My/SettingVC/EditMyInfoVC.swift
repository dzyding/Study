//
//  EditMyInfoVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum EditInfoType {
    case first      //初次设置密码
    case normal     //正常情况
    case notice     //初次设置密码，并且需要提示
}

class EditMyInfoVC: BaseVC {
    
    private let type: EditInfoType
    
    @IBOutlet weak var mainSView: UIStackView!
    
    @IBOutlet private weak var stackView: UIStackView!
    /// 男士
    @IBOutlet private weak var manBtn: UIButton!
    /// 女士
    @IBOutlet private weak var ladyBtn: UIButton!
    /// 姓
    @IBOutlet weak var familyNameTF: UITextField!
    /// 名
    @IBOutlet weak var lastNameTF: UITextField!
    /// 身份证
    @IBOutlet weak var idCardTF: UITextField!
    /// 密码
    @IBOutlet weak var pwdTF: UITextField!
    /// 确认密码
    @IBOutlet weak var secondPwdTF: UITextField!
    
    init(_ type: EditInfoType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case .normal:
            navigationItem.title = "实名信息"
            (0..<2).forEach { (_) in
                stackView.arrangedSubviews.last?.removeFromSuperview()
                let temp = UIView()
                temp.backgroundColor = .white
                stackView.insertArrangedSubview(temp, at: 3)
            }
        case .first:
            navigationItem.title = "实名信息及密码"
        case .notice:
            navigationItem.title = "实名信息及密码"
            mainSView.insertArrangedSubview(notiView, at: 0)
        }
    }
    
    func customBackAction() {
        switch type {
        case .notice:
            dzy_pop()
        default:
            dzy_customPopOrRootPop(MyInfoVC.self)
        }
    }
    
    //    MARK: - 选择性别
    @IBAction func manAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        ladyBtn.isSelected = false
    }
    
    @IBAction func ladyAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        manBtn.isSelected = false
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        guard let familyName = familyNameTF.text, familyName.count > 0 else {
            showMessage("请输入姓")
            return
        }
        guard let lastName = lastNameTF.text, lastName.count > 0 else {
            showMessage("请输入名")
            return
        }
        guard let idCard = idCardTF.text, idCard.count > 0 else {
            showMessage("请输入身份证")
            return
        }
        
        var dic: [String : Any] = [
            "idCard" : idCard,
            "surname"  : familyName,
            "name"   : lastName,
            "title"  : manBtn.isSelected ? "先生" : "女士",
            "sex"    : manBtn.isSelected ? 10 : 20,
            "type"   : 10
        ]
        if type == .first || type == .notice {
            guard let tempPwd = pwdTF.text, let pwd = PublicFunc.encryptPwd(tempPwd) else {
                showMessage(PublicConfig.Msg_Pwd)
                return
            }
            guard let spwd = secondPwdTF.text, spwd == tempPwd else {
                showMessage("两次密码不相同")
                return
            }
            dic.updateValue(pwd, forKey: "password")
            PublicFunc.userOperFooter(.setPwd)
        }
        editUserApi(dic) { result in
            if result {
                PublicFunc.updateUserDetail({ [weak self] (_, _, _) in
                    self?.customBackAction()
                })
            }
        }
    }
    
    //    MARK: - api
    func editUserApi(_ dic: [String : Any], handler: @escaping (Bool)->()) {
        let request = BaseRequest()
        request.url = BaseURL.editUser
        request.dic = dic
        request.isId = true
        request.dzy_start { (data, _) in
            handler(data != nil)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var notiView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        let bgView = UIView()
        bgView.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.7)
        view.addSubview(bgView)
        
        let lb = UILabel()
        lb.text = "为保障您的帐号及资金安全，请先完善您的个人实名信息。"
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.font = dzy_Font(14)
        lb.textAlignment = .center
        view.addSubview(lb)
        
        lb.snp.makeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        bgView.snp.makeConstraints({ (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
        })
        
        view.snp.makeConstraints({ (make) in
            make.height.equalTo(50)
        })
        return view
    }()
}
