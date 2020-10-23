//
//  EvaluateAndFBBaseVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class EvaluateAndFBBaseVC: ScrollBtnVC {
    
    override var btnsViewHeight: CGFloat {
        return 60
    }
    
    override var normalFont: UIFont {
        return dzy_FontBlod(13)
    }
    
    override var selectedFont: UIFont {
        return dzy_FontBlod(15)
    }
    
    override var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    override var selectedColor: UIColor {
        return Font_Dark
    }
    
    override var leftPadding: CGFloat {
        return 8.0
    }
    
    override var rightPadding: CGFloat {
        return (ScreenWidth / 2.0) + 10.0
    }
    
    override var lineToBottom: CGFloat {
        return 15.0
    }
    
    override var titles: [String] {
        return ["评价", "建议", "投诉"]
    }
    
    var task: [String : Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "评价与反馈"
        updateVCs()
    }
    
    override func getVCs() -> [UIViewController] {
        return [
            EvaluateVC(.evaluate), SuggestVC(), EvaluateVC(.complain)
        ]
    }
}
