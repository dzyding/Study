//
//  SetGetWayView.swift
//  PPBody
//
//  Created by Mike on 2018/6/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SetGetWayView: UIView {

    
    @IBOutlet weak var codeTF: UITextField!
    func getInviteCode() -> String? {
        return self.codeTF.text
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        let vc = QRScanCodeVC();
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
        style.photoframeLineW = 2;
        style.photoframeAngleW = 18;
        style.photoframeAngleH = 18;
        style.isNeedShowRetangle = false;
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove;
        
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")
        
        vc.scanStyle = style
        vc.delegate = self
        
        let from = ToolClass.controller2(view: self)
        from?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    class func instanceFromNib() -> SetGetWayView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[4] as! SetGetWayView
    }
}

extension SetGetWayView:QRScanCodeDelegate
{
    func qrScanCode(_ code: String) {
        self.codeTF.text = code
    }
    
    
}
