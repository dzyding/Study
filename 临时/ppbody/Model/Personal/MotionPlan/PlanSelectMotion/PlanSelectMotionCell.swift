//
//  PlanSelectMotionCell.swift
//  PPBody
//
//  Created by Mike on 2018/7/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PlanSelectMotionCell: UITableViewCell {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var pathSV: UIStackView!
    
    @IBOutlet weak var selectStatusBtn: UIButton!
    
    var motion:[String:Any]?
    
    func setData(_ dic: [String:Any]) {
        iconIV.setCoverImageUrl(dic.stringValue("cover"))
        nameLB.text = dic.stringValue("name")
        motion = dic
        
        while pathSV.arrangedSubviews.count > 0 {
            pathSV.arrangedSubviews.first?.removeFromSuperview()
        }
        let pathArr = dic.stringValue("trainingCore")?.components(separatedBy: "、") ?? []
        pathArr.forEach { (text) in
            let label = getLB(text)
            label.sizeToFit()
            let width = label.frame.width + 10
            label.snp.makeConstraints { (make) in
                make.width.equalTo(width)
            }
            pathSV.addArrangedSubview(label)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func getLB(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = dzy_Font(10)
        label.textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.5)
        label.text = text
        label.textAlignment = .center
        label.backgroundColor = CardColor
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }
}
