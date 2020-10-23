//
//  ReportListFooterView.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class ReportListFooterView: UITableViewHeaderFooterView {
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = RGBA(r: 31.0, g: 31.0, b: 31.0, a: 0.3)
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        contentView.backgroundColor = dzy_HexColor(0x232327)
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(1)
            make.bottom.equalTo(0)
        }
    }
    
}
