//
//  LocationCityCell.swift
//  PPBody
//
//  Created by edz on 2019/11/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationCityCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        titleLB.text = data.stringValue("city")
    }
}
