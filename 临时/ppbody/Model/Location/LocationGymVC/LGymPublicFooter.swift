//
//  LGymPublicFooter.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymPublicFooter: UIView, InitFromNibEnable {
    
    var handler: ((Bool)->())?
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var moreLB: UILabel!
    
    @IBOutlet weak var moreIV: UIImageView!
    
    private var type: LGymViewType = .ptExp
    
    private var count: Int = 0
    
    var isOpen = false
    
    private var moreStr: String {
        switch type {
        case .ptExp:
            return "查看其它\(count - 2)个体验课"
        case .groupBuy:
            return "查看其它\(count - 2)个团购"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        bgView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
    }
    
    func initUI(_ type: LGymViewType, count: Int) {
        self.type = type
        self.count = count
        moreLB.text = moreStr
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        isOpen = !isOpen
        handler?(isOpen)
        if isOpen {
            moreLB.text = "收起"
            moreIV.image = UIImage(named: "lgym_arrrow_top")
        }else {
            moreLB.text = moreStr
            moreIV.image = UIImage(named: "lgym_arrrow_bottom")
        }
    }
}
