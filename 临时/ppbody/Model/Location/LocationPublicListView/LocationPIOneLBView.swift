//
//  LocationPIOneLBView.swift
//  PPBody
//
//  Created by edz on 2019/10/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationPIOneLBView: UIView, InitFromNibEnable {

    @IBOutlet weak var infoLB: UILabel!
    
    func updateUI(_ data: String) {
        infoLB.text = data
    }
    
}
