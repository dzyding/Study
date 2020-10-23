//
//  LFreeOrderView.swift
//  PPBody
//
//  Created by edz on 2019/11/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LFreeOrderView: UIView, InitFromNibEnable {
    
    var handler: (()->())?
    
    @IBAction func closeAction(_ sender: Any) {
        handler?()
        (superview as? DzyPopView)?.hide()
    }
}
