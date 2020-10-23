//
//  TakeSweatSuccessView.swift
//  PPBody
//
//  Created by edz on 2019/1/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TakeSweatSuccessView: UIView {
    
    var handler: (()->())?

    @IBAction func sureAction(_ sender: Any) {
        handler?()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if let popView = superview as? DzyPopView {
            popView.hide()
        }
    }
}
