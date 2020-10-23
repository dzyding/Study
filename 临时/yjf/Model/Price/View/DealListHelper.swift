//
//  DealListHelper.swift
//  YJF
//
//  Created by edz on 2019/7/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

struct DealListHelper {
    
    static func getFilterBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(dzy_HexColor(0xfd7e25), for: .selected)
        btn.setTitleColor(dzy_HexColor(0x646464), for: .normal)
        btn.titleLabel?.font = dzy_Font(11)
        btn.setBackgroundImage(
            UIImage(named: "fliter_selected"), for: .selected
        )
        btn.setBackgroundImage(
            UIImage(named: "fliter_selected_no"), for: .normal
        )
        return btn
    }
}
