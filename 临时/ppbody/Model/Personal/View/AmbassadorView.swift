//
//  AmbassadorView.swift
//  PPBody
//
//  Created by edz on 2018/12/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class AmbassadorView: UIView {
    
    var handler: (()->())?
    
    static func initFromNib() -> AmbassadorView? {
        return Bundle.main.loadNibNamed("AmbassadorView", owner: self, options: nil)?.first as? AmbassadorView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @objc func tapAction() {
        handler?()
    }
}
