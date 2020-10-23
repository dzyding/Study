//
//  ActionSheetCell.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ActionSheetCell: UIView {

    weak var label: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        basicStep()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func basicStep() {
        let label = UILabel()
        label.textColor = Font_Dark
        label.font = dzy_Font(14)
        label.textAlignment = .center
        addSubview(label)
        self.label = label

        label.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(self)
        }
    }
}
