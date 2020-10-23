//
//  MessageTypeHeaderView.swift
//  YJF
//
//  Created by edz on 2019/7/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol MessageTypeHeaderViewDelegate: class {
    func typeHeader(_ header: MessageTypeHeaderView, didClickType type: MessageType)
}

class MessageTypeHeaderView: UIView {
    
    weak var delegate: MessageTypeHeaderViewDelegate?
    
    private var funcs = [MessageType]([
        .jsxx, .jytx, .swyy, .jjbg,
        .czzd, .cjbg, .xtxx
        ])

    @IBOutlet weak var topStackView: UIStackView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    private func initUI() {
        func baseFunc(_ index: Int, view: UIView) {
            let type = funcs[index]
            if let btn = view.viewWithTag(1) as? UIButton,
                let title = view.viewWithTag(2) as? UILabel
            {
                view.tag = type.rawValue
                title.text = type.name()
                btn.setImage(UIImage(named: type.image()), for: .normal)
                btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            }
        }
        topStackView.arrangedSubviews.enumerated().forEach { (index, view) in
            baseFunc(index, view: view)
        }
        bottomStackView.arrangedSubviews.enumerated().forEach { (index, view) in
            if index < 3 {
                baseFunc(index + 4, view: view)
            }
        }
    }
    
    @objc private func btnAction(_ btn: UIButton) {
        guard let tag = btn.superview?.tag,
            let type = MessageType(rawValue: tag)
        else {
            return
        }
        delegate?.typeHeader(self, didClickType: type)
    }
}
