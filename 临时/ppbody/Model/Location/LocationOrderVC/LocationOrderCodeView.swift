//
//  LocationOrderCodeView.swift
//  PPBody
//
//  Created by edz on 2019/11/1.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderCodeView: UIView, InitFromNibEnable {

    @IBOutlet weak var codeLB: UILabel!
    
    func updateUI(_ code: String) {
        codeLB.text = code
    }

    @IBAction func copyAction(_ sender: Any) {
        codeLB.text.flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }
}
