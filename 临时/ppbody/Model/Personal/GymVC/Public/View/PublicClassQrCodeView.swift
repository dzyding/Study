//
//  PublicClassQrCodeView.swift
//  PPBody
//
//  Created by edz on 2019/7/27.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class PublicClassQrCodeView: UIView {

    @IBOutlet weak var qrIV: UIImageView!
    
    var code: String = ""
    
    func updateUI(_ code: String) {
        self.code = code
        qrIV.image = dzy_QrCode(code, size: bounds.size.width)
    }
}
