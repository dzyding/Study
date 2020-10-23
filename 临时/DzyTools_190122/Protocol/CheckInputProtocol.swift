//
//  CheckInputProtocol.swift
//  ZHYQ-FsZc
//
//  Created by edz on 2019/1/31.
//  Copyright © 2019 dzy. All rights reserved.
//

import Foundation

class CheckInputObject {
    
    static let `default` = CheckInputObject()
    
    var textFields: [UITextField] = []
    
    var handler: ((Bool)->())?
    
    @objc func editChange() {
        var ifAll = true
        for i in (0..<textFields.count) {
            if let text = textFields[i].text, text.isEmpty {
                ifAll = false
                break
            }
        }
        handler?(ifAll)
    }
}

protocol CheckInputProtocol where Self: UIViewController {
    /// 设置监控
    func setCheckAction(_ textFields: [UITextField])
    /// 当全部有输入时触发
    func updateTargetStatus(_ ifAll: Bool)
}

extension CheckInputProtocol {
    func setCheckAction(_ textFields: [UITextField]) {
        CheckInputObject.default.textFields = textFields
        CheckInputObject.default.handler = { [weak self] (ifAll) in
            self?.updateTargetStatus(ifAll)
        }
        textFields.forEach { (textField) in
            textField.addTarget(CheckInputObject.default, action: #selector(CheckInputObject.editChange), for: .editingChanged)
        }
    }
}
