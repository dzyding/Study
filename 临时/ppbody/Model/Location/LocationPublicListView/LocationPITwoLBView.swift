//
//  LocationPITwoLBView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationPITwoLBView: UIView, InitFromNibEnable {
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var valueLB: UILabel!
    
    func updateUI(_ value: (String, String)) {
        titleLB.text = value.0
        valueLB.text = value.1
    }
    
    func colorUpdateUI(_ value: (String, String, UIColor)) {
        titleLB.text = value.0
        valueLB.text = value.1
        valueLB.textColor = value.2
    }

}
