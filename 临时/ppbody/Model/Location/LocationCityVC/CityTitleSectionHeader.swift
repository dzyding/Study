//
//  CityTitleSectionHeader.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CityTitleSectionHeader: UICollectionReusableView {

    @IBOutlet weak var titleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ title: String) {
        titleLB.text = title
    }
    
}
