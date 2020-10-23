//
//  RegisterSexView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterSexView: UIView {
    
    @IBOutlet weak var boyBtn: UIButton!
    @IBOutlet weak var girlBtn: UIButton!
    
    var nextAction:((String)->())?

    
    class func instanceFromNib() -> RegisterSexView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[4] as! RegisterSexView
    }
    
    @IBAction func selectSexAction(_ sender: UIButton) {
        if sender == self.boyBtn{
            self.boyBtn.isSelected = true
            self.girlBtn.isSelected = false
        }else{
            self.boyBtn.isSelected = false
            self.girlBtn.isSelected = true
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        if self.boyBtn.isSelected
        {
            self.nextAction!("10")
        }else{
            self.nextAction!("20")
        }
    }
    
}
