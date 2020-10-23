//
//  RelationLabel.swift
//  PPBody
//
//  Created by edz on 2018/12/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class RelationLabel: UILabel {
    
    var handler: ((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTap()
    }
    
    func addTap() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        handler?(tag)
    }
}
