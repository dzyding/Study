//
//  LocationBannerHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/11/6.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationBannerHeaderView: UIView, InitFromNibEnable {
    
    var handler: (()->())?

    @IBAction func clickAction(_ sender: UIButton) {
        handler?()
    }
    
}
