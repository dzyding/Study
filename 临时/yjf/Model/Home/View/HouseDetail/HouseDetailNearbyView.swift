//
//  HouseDetailNearbyView.swift
//  YJF
//
//  Created by edz on 2019/5/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseDetailNearbyView: UIView {
    
    var height: CGFloat = 500.0
    
    @IBOutlet private weak var infoLB: UILabel!

    func updateUI(_ str: String) {
        let text = str.isEmpty ? "暂无" : str
        var attStr = DzyAttributeString()
        attStr.str = text
        attStr.font = dzy_Font(13)
        attStr.color = dzy_HexColor(0xa3a3a3)
        attStr.lineSpace = defaultLineSpace
        infoLB.attributedText = attStr.create()
        infoLB.sizeToFit()
        
        height = infoLB.frame.size.height + 36
    }
}
