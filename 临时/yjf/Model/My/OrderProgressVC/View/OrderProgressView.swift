//
//  OrderProgressView.swift
//  YJF
//
//  Created by edz on 2019/7/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class OrderProgressView: UIView {
    
    var handler: (()->())?
    
    @IBAction func btnAction(_ sender: UIButton) {
        handler?()
    }
}
