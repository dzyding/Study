//
//  CustomWaitView.swift
//  YJF
//
//  Created by edz on 2019/6/28.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CustomWaitView: UIView {

    @IBOutlet private weak var hudView: UIActivityIndicatorView!
    
    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet private weak var msgLB: UILabel!
    
    func begin() {
        hudView.startAnimating()
    }
    
    func end() {
        hudView.stopAnimating()
    }
    
    // 上传图片用的
    func updateUI(_ current: Int, total: Int) {
        msgLB.text = "第\(current)张图，共\(total)张图"
    }
    
    // 通用方法
    func updateUI(_ str: String) {
        titleLB.isHidden = true
        msgLB.text = str
    }
}
