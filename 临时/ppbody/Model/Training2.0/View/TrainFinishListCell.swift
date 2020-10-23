//
//  TrainFinishListCell.swift
//  PPBody
//
//  Created by edz on 2020/6/1.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainFinishListCell: UIView, InitFromNibEnable {

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(14)
    }
    
    func initUI(_ dic: [String : Any], index: Int) {
        let motionId = dic.intValue("motionId") ?? 0
        let list = dic.arrValue("list") ?? []
        let height = 40 + CGFloat(list.count * 30)
        snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        let name = dic.stringValue("name") ?? ""
        nameLB.text = String(format: "%02ld.%@·%ld组", index + 1, name, list.count)
        list.forEach { (dic) in
            let view = getSbView(dic, motionId: motionId)
            stackView.addArrangedSubview(view)
        }
    }
    
    private func getSbView(_ dic: [String : Any],
                           motionId: Int) -> UIView
    {
        let view = UIView()
        view.backgroundColor = .clear

        let weight = dic.doubleValue("weight") ?? 0
        let num = dic.intValue("freNum") ?? 0
        let rest = dic.doubleValue("rest") ?? 0
        let time = dic.doubleValue("time") ?? 0
        let distance = dic.doubleValue("distance") ?? 0
        let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        
        let leftLB = UILabel()
        leftLB.textColor = color
        leftLB.font = dzy_FontBlod(12)
        view.addSubview(leftLB)
        
        let rightLB = UILabel()
        rightLB.textColor = color
        rightLB.font = dzy_FontBlod(12)
        rightLB.text = "\(rest.decimalStr)s"
        view.addSubview(rightLB)
        
        if motionId == 149 {
            if distance > 0 {
                leftLB.text = "\(time.decimalStr)s x \(distance.decimalStr)km"
            }else {
                leftLB.text = "\(time.decimalStr)s"
            }
        }else if num > 0 {
            if weight > 0 {
                leftLB.text = "\(weight.decimalStr)kg x \(num)"
            }else {
                leftLB.text = "x \(num)"
            }
        }else if time > 0 {
            leftLB.text = "\(time.decimalStr)s"
        }
        
        leftLB.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalTo(view)
        }
        
        rightLB.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(view)
        }
        
        return view
    }

}
