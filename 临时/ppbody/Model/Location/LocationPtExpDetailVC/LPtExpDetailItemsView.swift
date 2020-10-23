//
//  LPtExpDetailItemsView.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpDetailItemsView: UIView, InitFromNibEnable {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    func initUI(_ data: [String : Any]) {
        titleLB.text = data.stringValue("title")
        data.arrValue("items")?.forEach({ (data) in
            let cell = LPtExpDetailItemsCell.initFromNib()
            cell.updateUI(data)
            stackView.addArrangedSubview(cell)
        })
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }
}
