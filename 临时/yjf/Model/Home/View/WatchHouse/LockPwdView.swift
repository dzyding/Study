//
//  LockPwdView.swift
//  YJF
//
//  Created by edz on 2019/8/2.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol LockPwdViewDelegate: class {
    /// 已开门
    func pwdView(_ pwdView: LockPwdView, didClickOepnBtn btn: UIButton)
    /// 报告门锁故障
    func pwdView(_ pwdView: LockPwdView, didClickReportBtn btn: UIButton)
    /// 更新密码
    func pwdView(_ pwdView: LockPwdView, didClickUpdateBtn btn: UIButton)
}

class LockPwdView: UIView {

    @IBOutlet private weak var pwdLB: UILabel!
    
    @IBOutlet private weak var openBtn: UIButton!
    
    @IBOutlet private weak var updateBtn: UIButton!
    
    weak var delegate: LockPwdViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateBtn.layer.cornerRadius = 5
        updateBtn.layer.borderWidth = 1
        updateBtn.layer.borderColor = MainColor.cgColor
        updateBtn.layer.cornerRadius = 3
    }
    
    func updatePwd(_ string: String) {
        var temp = ""
        for (index, c) in string.enumerated() {
            temp += String(c) + " "
            if index == string.count - 1 {
                temp += "#"
            }
        }
        pwdLB.text = temp
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        delegate?.pwdView(self, didClickOepnBtn: sender)
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        delegate?.pwdView(self, didClickReportBtn: sender)
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        delegate?.pwdView(self, didClickUpdateBtn: sender)
    }
}
