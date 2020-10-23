//
//  ReportListHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class ReportListHeaderView: UITableViewHeaderFooterView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = dzy_HexColor(0x999999)
        label.font = dzy_Font(15)
        return label
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
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(contentView)
        }
    }
    
}
