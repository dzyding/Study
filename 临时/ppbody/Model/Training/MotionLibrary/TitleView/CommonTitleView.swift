//
//  CommonTitleView.swift
//  PPBody
//
//  Created by Mike on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit


class CommonTitleView: UIView {

    @IBOutlet weak var btnTitle: UIButton!

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 200, height: 44.0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

}
