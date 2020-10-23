//
//  TrainHistoryFooterView.swift
//  PPBody
//
//  Created by edz on 2020/1/7.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainHistoryFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var bgView: UIView!
    
    private var isInit: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initUI() {
        if isInit {return}
        isInit = true
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        bgView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
    }
}
