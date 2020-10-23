//
//  LGymPublicHeader.swift
//  PPBody
//
//  Created by edz on 2019/11/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymPublicHeader: UIView, InitFromNibEnable {

    @IBOutlet weak var leftBriefLB: UILabel!
    
    @IBOutlet weak var rightBriefLB: UILabel!
    
    @IBOutlet weak var iconLB: UILabel!
    
    @IBOutlet weak var titleLB: UILabel!
    
    func updateUI(_ type: LGymViewType) {
        switch type {
        case .ptExp:
            iconLB.text = "体"
            iconLB.backgroundColor = LocationVCHelper.expColor
            titleLB.text = "体验课"
            leftBriefLB.text = "随时预约"
            rightBriefLB.text = "可选教练"
        case .groupBuy:
            iconLB.text = "团"
            iconLB.backgroundColor = LocationVCHelper.gbColor
            titleLB.text = "团购"
            leftBriefLB.text = "随时退"
            rightBriefLB.text = "过期退"
        }
    }

}
