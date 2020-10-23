//
//  HouseInfoView.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseInfoView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    
    private weak var addressLB: UILabel?
    
    private weak var houseTypeLB: UILabel?
    
    private weak var areaLB: UILabel?
    
    private weak var numLB: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func updateUI(_ house: [String : Any]) {
        addressLB?.text = house.stringValue("houseTitle")
        houseTypeLB?.text = house.stringValue("layout")
        areaLB?.text = "\(house.doubleValue("area"), optStyle: .price)㎡"
        numLB?.text = house.stringValue("code")
    }
    
    private func setUI() {
        ["地址：", "户型：", "面积：", "编号："].enumerated().forEach { (index, text) in
            let view = UIView()
            view.backgroundColor = .white
            
            let titleLB = UILabel()
            titleLB.font = dzy_Font(14)
            titleLB.textColor = Font_Dark
            titleLB.text = text
            view.addSubview(titleLB)
            
            let valueLB = UILabel()
            valueLB.font = dzy_Font(14)
            valueLB.textColor = Font_Dark
            valueLB.text = "temp"
            view.addSubview(valueLB)
            
            titleLB.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.centerY.equalTo(view)
            })
            
            valueLB.snp.makeConstraints({ (make) in
                make.left.equalTo(titleLB.snp.right)
                make.right.lessThanOrEqualTo(0)
                make.centerY.equalTo(titleLB)
            })
            
            stackView.addArrangedSubview(view)
            
            switch index {
            case 0:
                addressLB = valueLB
            case 1:
                houseTypeLB = valueLB
            case 2:
                areaLB = valueLB
            default:
                numLB = valueLB
            }
        }
    }
}
