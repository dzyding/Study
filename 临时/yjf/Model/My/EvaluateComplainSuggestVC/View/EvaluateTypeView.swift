//
//  EvaluateTypeView.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol EvaluateTypeViewDelegate {
    func typeView(_ typeView: EvaluateTypeView, didType type: Int)
}

class EvaluateTypeView: UIView {
    
    weak var delegate: EvaluateTypeViewDelegate?
    
    @IBOutlet private weak var orderServiceBtn: UIButton!
    
    @IBOutlet private weak var otherServiceBtn: UIButton!

    //    MARK: - 交易服务
    @IBAction private func orderServiceAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        otherServiceBtn.isSelected = false
        delegate?.typeView(self, didType: 0)
    }
    
    //    MARK: - 其他服务
    @IBAction private func otherServiceAction(_ sender: UIButton) {
        if sender.isSelected {return}
        sender.isSelected = true
        orderServiceBtn.isSelected = false
        delegate?.typeView(self, didType: 1)
    }
}
