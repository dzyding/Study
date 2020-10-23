//
//  MyOrderView.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum MyListFuncViewType: Int {
    case groupOrder = 1
    case goodsOrder
    case myCoach
    case becomeCoach
}

protocol MyListFuncViewDelegate: class {
    func listFuncView(_ listFuncView: MyListFuncView,
                      didClickActionType type: MyListFuncViewType)
}

class MyListFuncView: UIView, InitFromNibEnable {
    
    weak var delegate: MyListFuncViewDelegate?

    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func coachType() {
        heightLC.constant = 100
        (0..<2).forEach({ _ in
            stackView.arrangedSubviews.last?.removeFromSuperview()
        })
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        guard let type = MyListFuncViewType(rawValue: sender.tag) else {
            return
        }
        delegate?.listFuncView(self, didClickActionType: type)
    }
    
}
