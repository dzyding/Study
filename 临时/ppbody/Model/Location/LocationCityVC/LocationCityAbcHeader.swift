//
//  LocationCityAbcHeader.swift
//  PPBody
//
//  Created by edz on 2019/11/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationCityAbcHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLB: UILabel!
    
    func updateUI(_ title: String) {
        titleLB.text = title
    }
    
}
