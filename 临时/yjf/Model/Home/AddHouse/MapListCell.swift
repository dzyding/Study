//
//  MapListCell.swift
//  YJF
//
//  Created by edz on 2019/6/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MapListCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        contentView.add(titleLB, line)
        
        titleLB.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(contentView)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
    
    //    MARK: - 懒加载
    lazy var titleLB: UILabel = {
        let lb = UILabel()
        lb.font = dzy_Font(14)
        lb.textColor = Font_Dark
        return lb
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = Line_Color
        return view
    }()
}
