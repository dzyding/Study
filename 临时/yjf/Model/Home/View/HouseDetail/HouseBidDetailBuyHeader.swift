//
//  HouseDidDetailBuyHeader.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseBidDetailBuyHeader: UIView {
    
    private weak var msgLB: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateNum(_ num: Int) {
        msgLB?.text = "共\(num)人次"
    }
    
    private func setUI() {
        let label = UILabel()
        label.text = "竞买价格"
        label.textColor = Font_Dark
        label.font = dzy_FontBlod(15)
        addSubview(label)
        
        let msgLB = UILabel()
        msgLB.text = "共177人次"
        msgLB.textColor = Font_Light
        msgLB.font = dzy_Font(11)
        addSubview(msgLB)
        self.msgLB = msgLB
        
        let line = UIView()
        line.backgroundColor = dzy_HexColor(0xE5E5E5)
        addSubview(line)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.centerY.equalTo(self)
        }
        
        msgLB.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right).offset(20)
            make.bottom.equalTo(label)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }

}
