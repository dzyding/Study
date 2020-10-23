//
//  HouseDidDetailSellHeader.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseBidDetailSellHeader: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let label = UILabel()
        label.text = IDENTITY == .buyer ? "竞卖价格" : "卖方报价"
        label.textColor = Font_Dark
        label.font = dzy_FontBlod(15)
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.centerY.equalTo(self)
        }
    }

}
