//
//  EvaluateServiceView.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol EvaluateServiceViewDelegate {
    func serviceView(_ serviceView: EvaluateServiceView, didSelectShowBtn btn: UIButton)
}

class EvaluateServiceView: UIView {
    
    weak var delegate: EvaluateServiceViewDelegate?
    
    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet private weak var nameLB: UILabel!
    
    @IBOutlet private weak var valueLB: UILabel!
    
    @IBOutlet private weak var showBtn: UIButton!
    
    @IBAction private func showAction(_ sender: UIButton) {
        sender.isSelected = true
        delegate?.serviceView(self, didSelectShowBtn: sender)
    }
    
    /// 修改成投诉的样式
    func changeToComplainType() {
        titleLB.text = "投诉服务"
    }
    
    func updateUI(_ name: String?, time: String?) {
        nameLB.text = name
        valueLB.text = time
    }
    
    func closeAction() {
        showBtn.isSelected = false
    }
}
