//
//  LocationOrderCodeAndQrView.swift
//  PPBody
//
//  Created by edz on 2019/11/1.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderCodeAndQrView: UIView, InitFromNibEnable {

    @IBOutlet weak var imgIV: UIImageView!
    
    @IBOutlet weak var codeLB: UILabel!
    
    @IBAction func copyAction(_ sender: Any) {
        codeLB.text.flatMap({
            UIPasteboard.general.string = $0
            ToolClass.showToast("复制成功", .Success)
        })
    }
    
    func updateUI(_ code: String, orderId: Int) {
        var temp = code
        let sIndex = temp.startIndex
        if temp.count > 8 {
            temp.insert(" ", at: code.index(sIndex, offsetBy: 4))
            temp.insert(" ", at: code.index(sIndex, offsetBy: 9))
        }
        codeLB.text = temp
        
        let orderStr = "\(orderId)"
        var leftStr = ""
        var rightStr = ""
        var index = orderStr.startIndex
        // 奇偶
        var isJi = true
        while index < orderStr.endIndex {
            if isJi {
                leftStr.append(orderStr[index])
            }else {
                rightStr.append(orderStr[index])
            }
            isJi = !isJi
            index = orderStr.index(after: index)
        }
        var ncode = String(code.reversed())
        var tindex = ncode.index(ncode.startIndex, offsetBy: 8)
        ncode.insert(contentsOf: rightStr, at: tindex)
        tindex = ncode.index(ncode.startIndex, offsetBy: 4)
        ncode.insert(contentsOf: leftStr, at: tindex)
        let img = dzy_QrCode(ncode, size: 115.0 * ScreenScale)
        imgIV.image = img
    }
}
