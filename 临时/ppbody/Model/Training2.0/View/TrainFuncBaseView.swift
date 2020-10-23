//
//  TrainFuncBaseView.swift
//  PPBody
//
//  Created by edz on 2019/12/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainFuncBaseView: UIView, InitFromNibEnable {

    @IBOutlet weak var btn: UIButton!
    
    private var handler: (()->())?
    
    private var dmHandler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btn.titleLabel?.font = dzy_Font(13)
    }
    
    func initUI(_ title: (String, String),
                handler: @escaping ()->(),
                dmHandler: @escaping ()->())
    {
        self.handler = handler
        self.dmHandler = dmHandler
        btn.setTitle(title.0, for: .normal)
        btn.setImage(UIImage(named: title.1), for: .normal)
    }

    @IBAction func clickAction(_ sender: Any) {
        handler?()
        dmHandler?()
    }
}
