//
//  SOVNumBaseView.swift
//  PPBody
//
//  Created by edz on 2020/1/6.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class SOVNumBaseView: UIView, InitFromNibEnable {

    @IBOutlet weak var widthLC: NSLayoutConstraint!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numView: UIView!
    
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameView.layer.cornerRadius = 6
        nameView.layer.masksToBounds = true
        nameView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        numView.layer.cornerRadius = 6
        numView.layer.masksToBounds = true
        numView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    func updateUI(_ name: String, current: Int, total: Int) {
        nameLB.text = name
        let width = ScreenWidth - 32.0 - 51.0 - 51.0
        var result = total == 0 ? 0 : (CGFloat(current) / CGFloat(total) * width)
        result += 51.0
        widthLC.constant = result
        numLB.text = "\(current)次"
        let alp: CGFloat = result > 51.0 ? 1.0 : 0.45
        numView.backgroundColor = RGBA(r: 246, g: 148, b: 73, a: alp)
    }
}
